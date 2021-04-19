pragma solidity ^0.4.18;

import 'contracts/addedContracts/Ownable.sol';
import 'contracts/addedContracts/DssErrors.sol';

contract DssAccounts is Ownable {

    // State for workflow  “Доступен”,”Блокирован”,”Временная блокировка
    enum State {Available, Blocked, TempBlocked}

    enum AccountType {Client, Escrow}

    // Account type  «Не определено», «Юр.лицо», «Физ.лицо», «ИП»
    enum JuridicalType {Undefined, LegalEntity, Individual, IndividualEntrepreneur}

    // Account identity type «не идентифицирован», «упрощенная идентификация», «идентифицирован»
    enum IdentityType {None, Simple, Identified}

    struct Account {
        // Account address
        address accountAddress;
        // Account index in array
        uint index;
        // Account current state
        State state;
        //  Account juridical type
        JuridicalType juridicalType;
        //  Account's juridical type bank setter
        bytes32 juridicalTypeBankSetter;
        // Account identity
        IdentityType identityType;
        // Account type
        AccountType accountType;
        // Owner
        address owner;
        // Identifiers of account
        bytes32[] identifiers;
        // Encrypted account flag
        bool encrypted;
        // account transactions count
        uint atc;
    }

    // СК ошибок
    DssErrors  internal errors;

    mapping(address => Account) private accounts;

    address[] private accountsIndex;

    mapping(bytes32 => address) private accountsIdentifierIndex;

    event EventErrorAccount(address indexed accountAddress, uint errorCode);

    event EventNewAccount(address indexed accountAddress, uint index, bool identifier, uint reason);

    event EventUpdateAccount(address indexed accountAddress, uint index);

    event EventNewIdentifier(address indexed accountAddress, bytes32 identifier);

    event EventDeleteIdentifier(address indexed accountAddress, bytes32 identifier);

    /**
    *   Конструктор СК
    **/
    function DssAccounts(address _errors) public {
        require(_errors != 0x0);

        errors = DssErrors(_errors);
    }

    function EmitEventErrorAccount(address accountAddress, uint errorCode) public onlyOwner {
        EventErrorAccount(accountAddress, errorCode);
    }

    function isAccount(address accountAddress) public constant returns (bool){
        if (accountAddress == 0x0) return false;
        if (accountsIndex.length == 0) return false;
        return (accountsIndex[accounts[accountAddress].index] == accountAddress);
    }

    function isAccountAvailable(address accountAddress) public constant returns (bool){
        require(isAccount(accountAddress));
        return accounts[accountAddress].state == State.Available;
    }

    // Получаем количество аккаунтов
    function getAccountsCount() public constant returns (uint){
        return accountsIndex.length;
    }

    // Получаем список аккаунтов постранично по 10
    function getAccountsList(uint skip) constant public returns (address[10], uint8[10], uint8[10], uint8[10]){

        address[10] memory addressResult;
        uint8[10] memory stateResult;
        uint8[10] memory juridicalTypeResult;
        uint8[10] memory identityTypeResult;

        if (accountsIndex.length <= skip) return (
        addressResult,
        stateResult,
        juridicalTypeResult,
        identityTypeResult
        );
        uint total = skip + 10;
        uint i = 0;

        while (i < total && i < accountsIndex.length) {
            if (i >= skip) {
                uint index = i - skip;
                addressResult[index] = accountsIndex[i];
                stateResult[index] = uint8(accounts[addressResult[index]].state);
                juridicalTypeResult[index] = uint8(accounts[addressResult[index]].juridicalType);
                identityTypeResult[index] = uint8(accounts[addressResult[index]].identityType);
            }
            i++;
        }

        return (
        addressResult,
        stateResult,
        juridicalTypeResult,
        identityTypeResult
        );
    }

    // Получение информации об аккаунте по его адресу
    function getAccount(address accountAddress) public constant returns (address, uint, uint8, uint8, uint8, address, bytes32[10]){
        require(isAccount(accountAddress));

        return (
        accounts[accountAddress].accountAddress,
        accounts[accountAddress].index,
        uint8(accounts[accountAddress].state),
        uint8(accounts[accountAddress].juridicalType),
        uint8(accounts[accountAddress].identityType),
        accounts[accountAddress].owner,
        getAccountIdentifiers(accountAddress)
        );
    }

    // Получаем информации об аккаунте по идентификатору
    function getAccountByIdentifier(bytes32 identifier) public constant returns (address, uint, uint8, uint8, uint8, address, bytes32[10]){

        address addr = accountsIdentifierIndex[identifier];
        return getAccount(addr);
    }

    // Получаем информации об аккаунте по идентификатору
    function getAccountAddressByIdentifier(bytes32 identifier) public constant returns (address){

        return accountsIdentifierIndex[identifier];
    }

    // Получаем информации о идентификационном статусе аккаунта по адресу
    function getAccountIdentityType(address accountAddress) public constant returns (uint8){
        require(isAccount(accountAddress));
        return uint8(accounts[accountAddress].identityType);
    }

    function getAccountType(address accountAddress) public constant returns (uint8){
        require(isAccount(accountAddress));
        return uint8(accounts[accountAddress].accountType);
    }

    function getOwner(address accountAddress) public constant returns (address){
        require(isAccount(accountAddress));
        return accounts[accountAddress].owner;
    }

    // Получаем информации о юридическом статусе аккаунта по адресу
    function getAccountJuridicalType(address accountAddress) public constant returns (uint8){
        require(isAccount(accountAddress));
        return uint8(accounts[accountAddress].juridicalType);
    }

    // Получаем информации о юридическом статусе аккаунта по адресу
    function getAccountJuridicalTypeDetails(address accountAddress) public constant returns (uint8, bytes32){
        require(isAccount(accountAddress));

        return (
        uint8(accounts[accountAddress].juridicalType),
        accounts[accountAddress].juridicalTypeBankSetter
        );
    }

    // Получаем идентификаторы аккаунта
    function getAccountIdentifiers(address accountAddress) public constant returns (bytes32[10]){

        require(isAccount(accountAddress));

        bytes32[10] memory identifiersResult;
        for (uint i = 0; i < accounts[accountAddress].identifiers.length && i < 10; i++) {
            identifiersResult[i] = accounts[accountAddress].identifiers[i];
        }
        return identifiersResult;
    }

    // Создание аккаунта
    function createAccount(
        address accountAddress,
        bytes32 identifier,
        uint8 state,
        uint8 juridicalType,
        bytes32 juridicalTypeBankSetter,
        uint8 identityType) public onlyOwner returns (bool){
        if (isAccount(accountAddress)) {
            // "Account already exist"
            EventErrorAccount(accountAddress, errors.ERROR_ACCOUNT_EXIST());
            return false;
        }

        bool addIdentifier = false;
        uint reasonCode = 0;
        if (identifier != "" && identifier != 0x0) {
            addIdentifier = true;
            if (accountsIdentifierIndex[identifier] != 0x0) {
                reasonCode = errors.ERROR_ACCOUNT_CREATED_WITHOUT_IDENTIFIER();
                addIdentifier = false;
            }
        }

        accountsIndex.push(accountAddress);

        accounts[accountAddress].accountAddress = accountAddress;
        accounts[accountAddress].index = accountsIndex.length - 1;
        accounts[accountAddress].state = State(state);
        accounts[accountAddress].accountType = AccountType(0);
        accounts[accountAddress].juridicalType = JuridicalType(juridicalType);
        accounts[accountAddress].juridicalTypeBankSetter = juridicalTypeBankSetter;
        accounts[accountAddress].identityType = IdentityType(identityType);
        accounts[accountAddress].owner = msg.sender;
        if (addIdentifier) {
            accounts[accountAddress].identifiers.push(identifier);
            accountsIdentifierIndex[identifier] = accountAddress;
        }
        EventNewAccount(accountAddress, accounts[accountAddress].index, addIdentifier, reasonCode);

        return true;
    }

    // Создание ескроу-аккаунта
    function createEscrowAccount(
        address accountAddress,
        bytes32 identifier
       ) public returns (bool){
        if (isAccount(accountAddress)) {
            // "Account already exist"
            EventErrorAccount(accountAddress, errors.ERROR_ACCOUNT_EXIST());
            return false;
        }

        if(msg.sender == tx.origin){
            EventErrorAccount(accountAddress, errors.ERROR_AVAILABLE_ONLY_INTERNAL_CONTRACT());
            return false;
        }

        bool addIdentifier = false;
        uint reasonCode = 0;
        if (identifier != "" && identifier != 0x0) {
            addIdentifier = true;
            if (accountsIdentifierIndex[identifier] != 0x0) {
                reasonCode = errors.ERROR_ACCOUNT_CREATED_WITHOUT_IDENTIFIER();
                addIdentifier = false;
            }
        }

        accountsIndex.push(accountAddress);

        accounts[accountAddress].accountAddress = accountAddress;
        accounts[accountAddress].index = accountsIndex.length - 1;
        accounts[accountAddress].state = State(0);
        accounts[accountAddress].accountType = AccountType(1);
        accounts[accountAddress].juridicalType = JuridicalType(0);
        accounts[accountAddress].juridicalTypeBankSetter = "";
        accounts[accountAddress].identityType = IdentityType(0);
        accounts[accountAddress].owner = msg.sender;
        if (addIdentifier) {
            accounts[accountAddress].identifiers.push(identifier);
            accountsIdentifierIndex[identifier] = accountAddress;
        }
        EventNewAccount(accountAddress, accounts[accountAddress].index, addIdentifier, reasonCode);

        return true;
    }

    // Привязка идентификатора к аккаунту
    function addIdentifierForAccount(
        address accountAddress,
        bytes32 identifier) public onlyOwner returns (bool){

        if (!isAccount(accountAddress)) {
            // "Account doesn't exist yet"
            EventErrorAccount(accountAddress, errors.ERROR_ACCOUNT_NOT_EXIST());
            return false;
        }

        if (accountsIdentifierIndex[identifier] != 0x0) {
            // "Identifier already exist"
            EventErrorAccount(accountAddress, errors.ERROR_IDENTIFIER_EXIST());
            return false;
        }

        accountsIdentifierIndex[identifier] = accountAddress;
        accounts[accountAddress].identifiers.push(identifier);

        EventNewIdentifier(accountAddress, identifier);

        return true;
    }

    // Удаление идентификатора из аккаунта
    function removeIdentifierFromAccount(address accountAddress, bytes32 identifier) public onlyOwner returns (bool){

        if (!isAccount(accountAddress)) {
            EventErrorAccount(accountAddress, errors.ERROR_ACCOUNT_NOT_EXIST());
            return false;
        }

        if (accountsIdentifierIndex[identifier] == 0x0) {
            // "Identifier not exist"
            EventErrorAccount(accountAddress, errors.ERROR_IDENTIFIER_NOT_EXIST());
            return false;
        }

        if (accountsIdentifierIndex[identifier] != accountAddress) {
            // does not match identifier
            EventErrorAccount(accountAddress, errors.ERROR_VALIDATE_REQUIRED());
            return false;
        }

        accountsIdentifierIndex[identifier] = 0x0;
        bool isMatched = false;
        for (uint i = 0; i < accounts[accountAddress].identifiers.length; i++) {
            if (!isMatched) {
                isMatched = accounts[accountAddress].identifiers[i] == identifier;
            }
            if (isMatched && i < accounts[accountAddress].identifiers.length - 1) {
                accounts[accountAddress].identifiers[i] = accounts[accountAddress].identifiers[i + 1];
            }
        }
        if (isMatched) {
            delete accounts[accountAddress].identifiers[accounts[accountAddress].identifiers.length - 1];
            accounts[accountAddress].identifiers.length--;
        }
        EventDeleteIdentifier(accountAddress, identifier);
        return true;
    }

    // Обновление статуса аккаунта
    function updateAccountState(address accountAddress, uint8 accountState) public onlyOwner returns (bool){
        if (!isAccount(accountAddress)) {
            // "Account doesn't exist yet"
            EventErrorAccount(accountAddress, errors.ERROR_ACCOUNT_NOT_EXIST());
            return false;
        }
        State state = State(accountState);
        if (accounts[accountAddress].state != state) {
            accounts[accountAddress].state = state;
        }
        EventUpdateAccount(accountAddress, accounts[accountAddress].index);
        return true;
    }

    // Обновление юридического типа аккаунта
    function updateAccountJuridical(address accountAddress, uint8 juridicalTypeValue, bytes32 juridicalTypeBankSetter) public onlyOwner returns (bool){
        if (!isAccount(accountAddress)) {
            // "Account doesn't exist yet"
            EventErrorAccount(accountAddress, errors.ERROR_ACCOUNT_NOT_EXIST());
            return false;
        }
        JuridicalType jurType = JuridicalType(juridicalTypeValue);
        if (accounts[accountAddress].juridicalType == JuridicalType.Undefined) {
            accounts[accountAddress].juridicalType = jurType;
            accounts[accountAddress].juridicalTypeBankSetter = juridicalTypeBankSetter;
        }
        EventUpdateAccount(accountAddress, accounts[accountAddress].index);
        return true;
    }

    // Обновление статуса идентификации аккаунта
    function updateAccountIdentity(address accountAddress, uint8 identityTypeValue) public onlyOwner returns (bool){
        if (!isAccount(accountAddress)) {
            // "Account doesn't exist yet"
            EventErrorAccount(accountAddress, errors.ERROR_ACCOUNT_NOT_EXIST());
            return false;
        }
        IdentityType identityType = IdentityType(identityTypeValue);
        if (accounts[accountAddress].identityType != identityType) {
            accounts[accountAddress].identityType = identityType;
        }
        EventUpdateAccount(accountAddress, accounts[accountAddress].index);
        return true;
    }

    function incrementAccountAct(address accountAddress) public returns (uint){
        require(isAccount(accountAddress));
        accounts[accountAddress].atc += 1;
        return accounts[accountAddress].atc;
    }
}




