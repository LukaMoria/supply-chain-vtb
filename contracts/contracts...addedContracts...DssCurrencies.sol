pragma solidity ^0.4.18;

import 'contracts/addedContracts/Ownable.sol';
import 'contracts/addedContracts/DssErrors.sol';

contract DssCurrencies is Ownable {

    struct Currency {
        // Currency name
        bytes32 name;
        // Currency code
        uint16 code;
        // Currency symbol
        bytes3 symbol;
        // Currency decimals
        uint8 decimals;
        // Business contract address
        address businessContract;
        // Business contract address
        address withdrawContract;
        // Clearing contract address
        address clearingContract;
        // Currency index in array
        uint index;
    }

    // СК ошибок
    DssErrors  internal errors;

    // code => Currency
    mapping(uint16 => Currency) private currencies;

    // codes
    uint16[] private currencyCodesIndex;

    // Business Contracts Index
    address[] private businessContractsIndex;

    // Business withdraw Contracts Index
    address[] private withdrawContractsIndex;

    // Clearing Contracts Index
    address[] private clearingContractsIndex;

    event EventErrorCurrency(uint16 indexed code, uint errorCode);

    event EventNewCurrency(uint16 indexed code, uint index);

    event EventUpdateCurrency(uint16 indexed code, uint index);

    /**
    *   Конструктор СК
    **/
    function DssCurrencies(address _errors) public {
        require(_errors != 0x0);

        errors = DssErrors(_errors);
    }

    /*
    * Currency API
    */

    // Check if currency exist
    function isExist(uint16 code) internal constant returns (bool){
        if (code == 0) return false;
        if (currencyCodesIndex.length == 0) return false;
        return (currencyCodesIndex[currencies[code].index] == code);
    }

    // Check if currency exist and return index
    function getCurrencyIndexByBusinessContract(address businessContract) internal constant returns (int){
        if (businessContract == 0x0) return - 1;
        if (businessContractsIndex.length == 0) return - 1;
        for (uint i = 0; i < businessContractsIndex.length; i++) {
            if (businessContractsIndex[i] == businessContract) return int(i);
        }
        return - 1;
    }

    // Check if currency exist and return index
    function getCurrencyIndexByWithdrawContract(address businessWithdrawContract) internal constant returns (int){
        if (businessWithdrawContract == 0x0) return - 1;
        if (withdrawContractsIndex.length == 0) return - 1;
        for (uint i = 0; i < withdrawContractsIndex.length; i++) {
            if (withdrawContractsIndex[i] == businessWithdrawContract) return int(i);
        }
        return - 1;
    }

    // Check if currency exist and return index
    function getCurrencyIndexByClearingContract(address clearingContract) internal constant returns (int){
        if (clearingContract == 0x0) return - 1;
        if (clearingContractsIndex.length == 0) return - 1;
        for (uint i = 0; i < clearingContractsIndex.length; i++) {
            if (clearingContractsIndex[i] == clearingContract) return int(i);
        }
        return - 1;
    }

    // Get currencies count
    function getCount() public constant returns (uint){
        return currencyCodesIndex.length;
    }

    // Get currencies list
    function getList(uint skip) public constant returns (bytes32[10], uint16[10], bytes3[10], uint8[10]) {

        bytes32[10] memory names;
        uint16[10] memory codes;
        bytes3[10] memory symbols;
        uint8[10] memory decimals;

        if (currencyCodesIndex.length <= skip) return (
        names,
        codes,
        symbols,
        decimals
        );

        uint total = skip + 10;
        uint i = 0;

        while (i < total && i < currencyCodesIndex.length) {
            if (i >= skip) {
                uint index = i - skip;
                names[index] = currencies[currencyCodesIndex[i]].name;
                codes[index] = currencies[currencyCodesIndex[i]].code;
                symbols[index] = currencies[currencyCodesIndex[i]].symbol;
                decimals[index] = currencies[currencyCodesIndex[i]].decimals;
            }
            i++;
        }

        return (
        names,
        codes,
        symbols,
        decimals
        );
    }

    // Get currencies by code
    function getByCode(uint16 code) public constant returns (bytes32, uint16, bytes3, uint8, address, address, address) {
        require(isExist(code));

        return (
        currencies[code].name,
        currencies[code].code,
        currencies[code].symbol,
        currencies[code].decimals,
        currencies[code].businessContract,
        currencies[code].withdrawContract,
        currencies[code].clearingContract
        );
    }

    // Get currencies by contract address
    function getByBusinessContract(address businessContract) public constant returns (bytes32, uint16, bytes3, uint8, address) {

        int currencyIndex = getCurrencyIndexByBusinessContract(businessContract);

        require(currencyIndex >= 0);

        uint16 code = currencyCodesIndex[uint(currencyIndex)];

        return (
        currencies[code].name,
        currencies[code].code,
        currencies[code].symbol,
        currencies[code].decimals,
        currencies[code].businessContract
        );
    }

    // Create new Currency
    function create(bytes32 name, uint16 code, bytes3 symbol, uint8 decimals, address businessContract, address withdrawContract, address clearingContract) public onlyOwner returns (bool){

        if (isExist(code)) {
            EventErrorCurrency(code, errors.ERROR_CURRENCY_EXIST());
            return false;
        }
        if (businessContract == address(0)) {
            EventErrorCurrency(code, errors.ERROR_VALIDATE_REQUIRED());
            return false;
        }
        if (withdrawContract == address(0)) {
            EventErrorCurrency(code, errors.ERROR_VALIDATE_REQUIRED());
            return false;
        }
        if (clearingContract == address(0)) {
            EventErrorCurrency(code, errors.ERROR_VALIDATE_REQUIRED());
            return false;
        }
        int currencyIndex = getCurrencyIndexByBusinessContract(businessContract);
        if (currencyIndex >= 0) {
            EventErrorCurrency(code, errors.ERROR_CURRENCY_BUSINESS_CONTRACT_EXIST());
            return false;
        }
        currencyIndex = getCurrencyIndexByWithdrawContract(withdrawContract);
        if (currencyIndex >= 0) {
            EventErrorCurrency(code, errors.ERROR_CURRENCY_BUSINESS_WITHDRAW_CONTRACT_EXIST());
            return false;
        }
        currencyIndex = getCurrencyIndexByClearingContract(clearingContract);
        if (currencyIndex >= 0) {
            EventErrorCurrency(code, errors.ERROR_CURRENCY_CLEARING_CONTRACT_EXIST());
            return false;
        }

        currencyCodesIndex.push(code);
        businessContractsIndex.push(businessContract);
        withdrawContractsIndex.push(withdrawContract);
        clearingContractsIndex.push(clearingContract);

        currencies[code].name = name;
        currencies[code].code = code;
        currencies[code].symbol = symbol;
        currencies[code].decimals = decimals;
        currencies[code].businessContract = businessContract;
        currencies[code].withdrawContract = withdrawContract;
        currencies[code].clearingContract = clearingContract;
        currencies[code].index = currencyCodesIndex.length - 1;

        EventNewCurrency(code, currencies[code].index);

        return true;
    }

    // Update Currency business contract address
    function updateBusinessContract(uint16 code, address oldAddress, address newAddress) public onlyOwner returns (bool){
        if (!isExist(code)) {
            EventErrorCurrency(code, errors.ERROR_CURRENCY_NOT_EXIST());
            return false;
        }

        int currencyIndex = getCurrencyIndexByBusinessContract(oldAddress);
        if (currencyIndex < 0) {
            EventErrorCurrency(code, errors.ERROR_CURRENCY_BUSINESS_CONTRACT_NOT_EXIST());
            return false;
        }
        if (newAddress == 0x0) {
            EventErrorCurrency(code, errors.ERROR_VALIDATE_REQUIRED());
            return false;
        }

        if (getCurrencyIndexByBusinessContract(newAddress) >= 0) {
            EventErrorCurrency(code, errors.ERROR_CURRENCY_BUSINESS_CONTRACT_EXIST());
            return false;
        }

        currencies[code].businessContract = newAddress;

        EventUpdateCurrency(code, currencies[code].index);

        return true;
    }

    // Update Currency business withdraw contract address
    function updateWithdrawContract(uint16 code, address oldAddress, address newAddress) public onlyOwner returns (bool){
        if (!isExist(code)) {
            EventErrorCurrency(code, errors.ERROR_CURRENCY_NOT_EXIST());
            return false;
        }

        int currencyIndex = getCurrencyIndexByWithdrawContract(oldAddress);
        if (currencyIndex < 0) {
            EventErrorCurrency(code, errors.ERROR_CURRENCY_BUSINESS_WITHDRAW_CONTRACT_NOT_EXIST());
            return false;
        }
        if (newAddress == 0x0) {
            EventErrorCurrency(code, errors.ERROR_VALIDATE_REQUIRED());
            return false;
        }

        if (getCurrencyIndexByWithdrawContract(newAddress) >= 0) {
            EventErrorCurrency(code, errors.ERROR_CURRENCY_BUSINESS_WITHDRAW_CONTRACT_EXIST());
            return false;
        }

        currencies[code].withdrawContract = newAddress;

        EventUpdateCurrency(code, currencies[code].index);

        return true;
    }

    // Update Currency clearing contract address
    function updateClearingContract(uint16 code, address oldAddress, address newAddress) public onlyOwner returns (bool){
        if (!isExist(code)) {
            EventErrorCurrency(code, errors.ERROR_CURRENCY_NOT_EXIST());
            return false;
        }

        int currencyIndex = getCurrencyIndexByClearingContract(oldAddress);
        if (currencyIndex < 0) {
            EventErrorCurrency(code, errors.ERROR_CURRENCY_CLEARING_CONTRACT_NOT_EXIST());
            return false;
        }
        if (newAddress == 0x0) {
            EventErrorCurrency(code, errors.ERROR_VALIDATE_REQUIRED());
            return false;
        }

        if (getCurrencyIndexByClearingContract(newAddress) >= 0) {
            EventErrorCurrency(code, errors.ERROR_CURRENCY_CLEARING_CONTRACT_EXIST());
            return false;
        }

        currencies[code].clearingContract = newAddress;

        EventUpdateCurrency(code, currencies[code].index);

        return true;
    }

    /*
    * End Currency API
    */

    function remove() public onlyOwner {
        selfdestruct(owner);
    }
}
