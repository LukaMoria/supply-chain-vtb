pragma solidity ^0.4.18;

import 'contracts/addedContracts/Ownable.sol';
import 'contracts/addedContracts/DssErrors.sol';

contract DssBanks is Ownable {

    // State for workflow  “Доступен”,”Блокирован”,”Временная блокировка
    enum State {Available, Blocked, TempBlocked}

    struct Bank {
        // Bank account address
        address bankAddress;
        // Bank name
        bytes32 name;
        // Bank name
        bytes32 bik;
        // Bank current state
        State state;
        // Bank index in array
        uint index;
        // Owner
        address owner;
    }

    // СК ошибок
    DssErrors  internal errors;

    mapping(address => Bank) private banks;

    address[] private banksIndex;
    // Bik => Bank address
    mapping(bytes32 => address) private biksIndex;

    address public bankVotingAddress;

    event EventErrorBank(address indexed bankAddress, uint errorCode);

    event EventNewBank(address indexed bankAddress, uint index);

    event EventUpdateBank(address indexed bankAddress, uint index);

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyBankVoting() {
        require(msg.sender == bankVotingAddress);
        _;
    }

    /**
    *   Конструктор СК
    **/
    function DssBanks(address _errors) public {
        require(_errors != 0x0);

        errors = DssErrors(_errors);
    }

    function setBanksVotingAddress(address _bankVotingAddress) public onlyOwner {
        bankVotingAddress = _bankVotingAddress;
    }

    function isBank(address bankAddress) public constant returns (bool isIndeed){
        if (bankAddress == 0x0) return false;
        if (banksIndex.length == 0) return false;
        return (banksIndex[banks[bankAddress].index] == bankAddress);
    }

    function isBankAvailable(address bankAddress) public constant returns (bool){
        require(isBank(bankAddress));
        return banks[bankAddress].state == State.Available;
    }

    // Получаем количество банков
    function getBanksCount() public constant returns (uint){
        return banksIndex.length;
    }

    // Получаем список банков постранично по 10
    function getBanksList(uint skip) public constant returns (address[10], bytes32[10], bytes32[10], uint[10]){
        address[10] memory addressResult;
        bytes32[10] memory nameResult;
        bytes32[10] memory bikResult;
        uint[10] memory stateResult;

        if (banksIndex.length <= skip) return (
        addressResult,
        nameResult,
        bikResult,
        stateResult
        );
        uint total = skip + 10;
        uint i = 0;

        while (i < total && i < banksIndex.length) {
            if (i >= skip) {
                uint index = i - skip;
                addressResult[index] = banksIndex[i];
                nameResult[index] = banks[addressResult[index]].name;
                bikResult[index] = banks[addressResult[index]].bik;
                stateResult[index] = uint(banks[addressResult[index]].state);
            }
            i++;
        }

        return (
        addressResult,
        nameResult,
        bikResult,
        stateResult
        );
    }

    // Получение информации о банке по его адресу
    function getBank(address bankAddress) public constant returns (address, bytes32, bytes32, uint8, address){
        require(isBank(bankAddress));

        return (
        banks[bankAddress].bankAddress,
        banks[bankAddress].name,
        banks[bankAddress].bik,
        uint8(banks[bankAddress].state),
        banks[bankAddress].owner
        );
    }

    // Получение адреса банка по его индексу в массиве
    function getBankAddressByIndex(uint index) public constant returns (address){
        require(index >= 0 && index < banksIndex.length);

        return banksIndex[index];
    }

    // Создание банка
    function createBank(address bankAddress, bytes32 name, bytes32 bik, uint state) public onlyOwner returns (bool){

        if (isBank(bankAddress)) {
            EventErrorBank(bankAddress, errors.ERROR_BANK_EXIST());
            return false;
        }

        if (name == '' || name == '0x0') {
            EventErrorBank(bankAddress, errors.ERROR_VALIDATE_REQUIRED());
            return false;
        }

        if (bik == '' || bik == '0x0') {
            EventErrorBank(bankAddress, errors.ERROR_VALIDATE_REQUIRED());
            return false;
        }

        banksIndex.push(bankAddress);

        banks[bankAddress].bankAddress = bankAddress;
        banks[bankAddress].name = name;
        banks[bankAddress].bik = bik;
        banks[bankAddress].state = State(state);
        banks[bankAddress].owner = msg.sender;
        banks[bankAddress].index = banksIndex.length - 1;

        biksIndex[bik] = bankAddress;

        EventNewBank(bankAddress, banks[bankAddress].index);

        return true;
    }

    // Обновление статуса банка
    function updateBankState(address bankAddress, uint bankState) public onlyBankVoting returns (bool){
        if (!isBank(bankAddress)) {
            EventErrorBank(bankAddress, errors.ERROR_BANK_NOT_EXIST());
            return false;
        }
        State state = State(bankState);
        if (banks[bankAddress].state != state) {
            banks[bankAddress].state = state;
        }
        EventUpdateBank(bankAddress, banks[bankAddress].index);
        return true;
    }
}
