pragma solidity ^0.4.18;

import 'contracts/addedContracts/Ownable.sol';
import 'contracts/addedContracts/DssErrors.sol';
import 'contracts/addedContracts/DssBanks.sol';
import 'contracts/addedContracts/DssVotingAction.sol';
import 'contracts/addedContracts/DssVotingEvent.sol';

/**
*   @title DssVoting
*   @dev Голосование по смене регулятора
*/
contract DssVoting is Ownable {

    // This declares a new complex type which will
    // be used for variables later.
    // It will represent a single voter.
    struct Voter {
        bool voted;  // if true, that person already voted
        uint vote;   // index of the voted proposal
    }

    // Структура вариантов голосования
    struct Proposal {
        bytes32 name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
        address contractAction;
    }

    mapping(address => Voter) public voters;

    // Массив вариантов голосования
    Proposal[2] public proposals;

    address public creator;
    uint8 public votingType;
    uint public endTime;
    bytes32 public oldValue;
    bytes32 public newValue;

    bool public isFinalized = false;
    // СК банков
    DssBanks banks;
    // СК событий
    DssVotingEvent votingEvent;
    // СК ошибок
    DssErrors errors;

    modifier isBankOwner() {
        require(banks.isBank(msg.sender));
        _;
    }

    // Конструктор
    function DssVoting(address _votingEventAddr, address _errorsAddr, address _banksAddr, uint _endTime, address _creator, uint8 _votingType, bytes32 _oldValue, bytes32 _newValue) public {
        require(_votingEventAddr != address(0));
        require(_errorsAddr != address(0));
        require(_banksAddr != address(0));
        require(_endTime < 9999999999999);

        // Проверяем что время задано в секундах, а не в миллисекундах
        if (_endTime > 9999999999) {
            _endTime = _endTime / 1000;
        }
        require(_endTime > now);

        votingEvent = DssVotingEvent(_votingEventAddr);
        errors = DssErrors(_errorsAddr);
        banks = DssBanks(_banksAddr);
        require(banks.isBank(_creator));

        creator = _creator;
        votingType = _votingType;
        endTime = _endTime;
        oldValue = _oldValue;
        newValue = _newValue;

        proposals[0] = Proposal({name : 'yes', voteCount : 0, contractAction : msg.sender});
        proposals[1] = Proposal({name : 'no', voteCount : 0, contractAction : address(0)});

        votingEvent.EmitVoting(address(this), creator, votingType, endTime, oldValue, newValue, 0, 0, 0);

        makeVote(0, _creator);
    }

    function vote(uint proposal) public isBankOwner {
        makeVote(proposal, msg.sender);
    }

    function makeVote(uint proposal, address bankAddr) internal {
        require(!isFinalized);
        Voter storage sender = voters[bankAddr];
        require(!sender.voted);

        address _addressBank;
        bytes32 _nameBank;
        bytes32 _bikBank;
        uint _stateBank;
        (_addressBank, _nameBank, _bikBank, _stateBank,) = banks.getBank(bankAddr);

        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += 1;

        votingEvent.EmitVotingProcess(address(this), _addressBank, _nameBank, _bikBank, uint8(proposal + 1), 0, (hasEnded() && !isFinalized));

    }

    /// @dev Computes the winning proposal taking all
    function winningProposal() public view returns (int winningProposal_) {
        winningProposal_ = - 1;
        uint banksCount = banks.getBanksCount();
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > banksCount - proposals[p].voteCount) {
                winningProposal_ = int(p);
                break;
            }
        }
    }

    function hasEnded() public constant returns (bool) {
        bool votesReached = false;
        uint banksCount = banks.getBanksCount();
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > banksCount - proposals[p].voteCount) {
                votesReached = true;
                break;
            }
        }
        bool timeIsUp = now > endTime;
        return timeIsUp || votesReached;
    }

    function finalize() public {
        require(!isFinalized);
        require(hasEnded());

        isFinalized = true;

        int winProposal = winningProposal();
        if (winProposal >= 0) {
            address action = proposals[uint(winProposal)].contractAction;
            if (action != address(0)) {
                DssVotingAction(action).voteResult();
            }
            votingEvent.EmitVoting(address(this), creator, votingType, endTime, oldValue, newValue, 1, uint8(winProposal + 1), 0);
        } else {
            votingEvent.EmitVoting(address(this), creator, votingType, endTime, oldValue, newValue, 1, 0, errors.ERROR_VOTING_WINNING_PROPOSAL_UNDEFINED());
        }
    }
}
