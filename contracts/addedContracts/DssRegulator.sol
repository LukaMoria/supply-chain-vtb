pragma solidity ^0.4.18;

import 'contracts/addedContracts/Ownable.sol';
import 'contracts/addedContracts/DssBanks.sol';
import 'contracts/addedContracts/DssVoting.sol';
import 'contracts/addedContracts/DssVotingAction.sol';
import 'contracts/addedContracts/DssVotingEvent.sol';
import 'contracts/addedContracts/DssErrors.sol';
/**
*   @title DssRegulator
*   @dev Хранение регулятора
*/
contract DssRegulator is Ownable, DssVotingAction {

    // Адрес регулятора
    address public regulator;

    // СК голосования выбора регулятора
    address public voting = address(0);

    // адрес СК банков
    address private banks;

    // адрес СК событий голосований
    address votingEvent;

    // СК ошибок
    DssErrors  errors;

    // адрес нового регулятора (кандидатура)
    address private newRegulator = address(0);

    /**
     * @dev Модификатор проверки адреса СК голосования.
     */
    modifier onlyVoting() {
        require(msg.sender == voting);
        _;
    }

    function DssRegulator(address _votingEvent, address _banks, address _errors) public {
        votingEvent = _votingEvent;
        banks = _banks;
        errors = DssErrors(_errors);
    }

    /**
     * @dev Инициализация процедуры по смене регулятора
     * @param _newRegulator address адрес нового регулятора.
     * @param _endTime uint256 дата окончания голосования.
     * @param _creator address адрес Банка инициатора голосования.
     */
    function setRegulator(address _newRegulator, uint256 _endTime, address _creator) public onlyOwner() returns (address) {
        // Проверим, может голосование уже(еще) идет
        if (voting != address(0) && !DssVoting(voting).isFinalized()) {
            DssVotingEvent(votingEvent).EmitVoting(voting, _creator, 1, _endTime, bytes32(regulator), bytes32(_newRegulator), 2, 0, errors.ERROR_VOTING_ALREADY_EXIST());
            return voting;
        }

        if (regulator != _newRegulator) {
            // это можеть быть только банк из списка банков
            if(!DssBanks(banks).isBank(_newRegulator)){
                DssVotingEvent(votingEvent).EmitVoting(address(0), _creator, 1, _endTime, bytes32(regulator), bytes32(_newRegulator), 2, 0, errors.ERROR_VOTING_BAD_VALUE());
                return address(0);
            }

            newRegulator = _newRegulator;
            if (voting == address(0) || DssVoting(voting).isFinalized()) {
                voting = new DssVoting(votingEvent, errors, banks, _endTime, _creator, 1, bytes32(regulator), bytes32(_newRegulator));
            } else if (DssVoting(voting).hasEnded()) {
                DssVoting(voting).finalize();
                voting = new DssVoting(votingEvent, errors, banks, _endTime, _creator, 1, bytes32(regulator), bytes32(_newRegulator));
            }
        } else {
            DssVotingEvent(votingEvent).EmitVoting(address(0), _creator, 1, _endTime, bytes32(regulator), bytes32(_newRegulator), 2, 0, errors.ERROR_VOTING_CONFLICT_VALUE());
        }

        return voting;
    }

    /**
     * @dev Результат голосования
     */
    function voteResult() public onlyVoting() returns (bool){
        if (DssVoting(voting).isFinalized()) {
            regulator = newRegulator;
            newRegulator = address(0);
            voting = address(0);
        }
    }
}

