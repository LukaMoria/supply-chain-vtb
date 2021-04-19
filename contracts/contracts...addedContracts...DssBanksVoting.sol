pragma solidity ^0.4.18;

import 'contracts/addedContracts/Ownable.sol';
import 'contracts/addedContracts/DssBanks.sol';
import 'contracts/addedContracts/DssVoting.sol';
import 'contracts/addedContracts/DssVotingAction.sol';
import 'contracts/addedContracts/DssVotingEvent.sol';
import 'contracts/addedContracts/DssErrors.sol';

contract DssBanksVoting is Ownable, DssVotingAction {

    // адрес СК банков
    address private banks;

    // адрес СК событий голосований
    address votingEvent;

    // СК ошибок
    DssErrors  errors;

    // Хранение информации для завершения голосования
    struct VotingItem {
        address bank;
        uint8 bankState;
    }
    // bank => voting
    mapping(address => address) votings;

    // voting => VotingItem
    mapping(address => VotingItem) votingResultData;

    /**
     * @dev Модификатор проверки адреса СК голосования.
     */
    modifier onlyVoting() {
        require(msg.sender == votings[votingResultData[msg.sender].bank]);
        _;
    }

    function DssBanksVoting(address _votingEvent, address _banks, address _errors) public {
        votingEvent = _votingEvent;
        banks = _banks;
        errors = DssErrors(_errors);
    }

    /**
     * @dev Инициализация процедуры по смене статуса банка
     * @param _bank address адрес банка.
     * @param _newBankState uint8 новый статус банка.
     * @param _endTime uint256 дата окончания голосования.
     * @param _creator address адрес Банка инициатора голосования.
     */
    function setBankState(address _bank, uint8 _newBankState, uint256 _endTime, address _creator) public onlyOwner() returns (address) {
        uint8 bankState;
        (, ,, bankState,) = DssBanks(banks).getBank(_bank);

        bytes32 oldValue;
        bytes32 newValue;
        (oldValue, newValue) = convertValuesToBytes(_bank, bankState, _newBankState);

        // Проверим, может голосование уже(еще) идет
        if (votings[_bank] != address(0) && !DssVoting(votings[_bank]).isFinalized()) {
            DssVotingEvent(votingEvent).EmitVoting(votings[_bank], _creator, 2, _endTime, oldValue, newValue, 2, 0, errors.ERROR_VOTING_ALREADY_EXIST());
            return votings[_bank];
        }

        if (bankState != _newBankState) {
            if (votings[_bank] == address(0) || DssVoting(votings[_bank]).isFinalized()) {
                votings[_bank] = new DssVoting(votingEvent, errors, banks, _endTime, _creator, 2, oldValue, newValue);
            } else if (DssVoting(votings[_bank]).hasEnded()) {
                DssVoting(votings[_bank]).finalize();
                votings[_bank] = new DssVoting(votingEvent, errors, banks, _endTime, _creator, 2, oldValue, newValue);
            }
        } else {
            DssVotingEvent(votingEvent).EmitVoting(address(0), _creator, 2, _endTime, oldValue, newValue, 2, 0, errors.ERROR_VOTING_CONFLICT_VALUE());
            return address(0);
        }
        votingResultData[votings[_bank]].bank = _bank;
        votingResultData[votings[_bank]].bankState = _newBankState;

        return votings[_bank];
    }

    /**
    * @dev Конкатенация адреса банка и статуса в bytes32
    * @param _bank address адрес банка.
    * @param _oldBankState uint8 старый статус банка.
    * @param _newBankState uint8 новый статус банка.
    */
    function convertValuesToBytes(address _bank, uint8 _oldBankState, uint8 _newBankState) internal pure returns (bytes32 oldValue, bytes32 newValue) {
        bytes memory oldValueArr = new bytes(32);
        bytes memory newValueArr = new bytes(32);
        oldValueArr[31] = byte(_oldBankState);
        newValueArr[31] = byte(_newBankState);
        for (uint i = 0; i < 20; i++) {
            byte b = byte(uint8(uint(_bank) / (2 ** (8 * (19 - i)))));
            oldValueArr[i] = b;
            newValueArr[i] = b;
        }
        assembly {
            oldValue := mload(add(oldValueArr, 32))
        }
        assembly {
            newValue := mload(add(newValueArr, 32))
        }
    }

    /**
     * @dev Результат голосования
     */
    function voteResult() public onlyVoting() returns (bool){
        if (DssVoting(msg.sender).isFinalized()) {
            // Устанавливаем новое значение
            DssBanks(banks).updateBankState(votingResultData[msg.sender].bank, votingResultData[msg.sender].bankState);
            // Обнуляем все
            votings[votingResultData[msg.sender].bank] = address(0);
            votingResultData[msg.sender].bank = address(0);
            votingResultData[msg.sender].bankState = 0;
        }
    }

}
