pragma solidity ^0.4.18;

import 'contracts/addedContracts/Ownable.sol';
import 'contracts/addedContracts/SafeMath.sol';
import 'contracts/addedContracts/DssBanks.sol';
import 'contracts/addedContracts/DssAccounts.sol';
import 'contracts/addedContracts/DssBusinessStorage.sol';
import 'contracts/addedContracts/DssRefundVault.sol';
import 'contracts/addedContracts/DssLimits.sol';
import 'contracts/addedContracts/DssTransactionEvent.sol';
import 'contracts/addedContracts/DssErrors.sol';
import 'contracts/addedContracts/DssIInvoiceStorage.sol';

/**
*   @title DssBusinessBase
*   @dev Базовый функционал бизнес логики
*/
contract DssBusinessBase is Ownable {
    using SafeMath for uint256;

    // Тип лимита для аккаунта «операционный»,«ежедневный»,«ежемесячный»,«баланс»,
    enum AccountLimitType {Operation, Daily, Monthly, Balance}

    // Код валюты
    uint16 internal currencyCode;

    // СК банков
    DssBanks internal banks;

    // СК аккаунтов
    DssAccounts internal accounts;

    // СК лимитов
    DssLimits internal limits;

    // СК депозитов по списанию средств с аккаунта
    DssRefundVault internal vault;

    // СК балансов
    DssBusinessStorage  internal dataStorage;

    // СК лога транзакций
    DssTransactionEvent  internal transactionEvent;

    // СК ошибок
    DssErrors  internal errors;

    // СК счетов
    DssIInvoiceStorage  internal invoices;


    function validateAccount(address addr) internal constant returns (bool){
        return (accounts.isAccount(addr) && accounts.isAccountAvailable(addr));
    }

    function validateBank(address addr) internal constant returns (bool){
        return (banks.isBank(addr) && banks.isBankAvailable(addr));
    }

    /*
     * События транзакций. Начало
    */

    event UpdateBankIssuesLimitLog(address indexed bank, uint oldLimit, uint newLimit);

    /*
     * События транзакций. Конец
    */

    // Получаем баланс банка в разрезе других банков для клиринга
    function getBankBalance(address bankAddress, address refBankAddress) public constant returns (uint){
        uint256 amount = dataStorage.getBankBalance(bankAddress, refBankAddress);
        // Возвращаем баланс по банку за вычитом "замороженных"  средств на депозите для операции withdraw
        return amount.sub(vault.getTotalDepositByBank(bankAddress, refBankAddress));
    }

    // Получаем баланс аккаунта по банку
    function getAccountBalance(address accountAddress, address bankAddress) public constant returns (uint){
        return dataStorage.getAccountBalance(accountAddress, bankAddress);
    }

    // Получаем суммарный баланс аккаунта
    function getAccountTotalBalance(address accountAddress) public constant returns (uint){
        return dataStorage.getAccountTotalBalance(accountAddress);
    }

    // Получение суммы эмиссии денег банка по его адресу
    function getBankIssues(address bankAddress) public constant returns (uint){
        return dataStorage.getBankIssues(bankAddress);
    }

    // Получение лимита суммы эмиссии денег банка по его адресу
    function getBankIssuesLimit(address bankAddress) public constant returns (uint){
        return dataStorage.getBankIssuesLimit(bankAddress);
    }

    // Получение суммы эмиссии денег всех банков для этой валюты
    function getTotalIssues() public constant returns (uint){
        return dataStorage.getTotalIssues();
    }

    // Получение лимитов аккаунта в зависимости от типа идентификации
    function getAccountLimits(uint8 _identityType, address _accountAddress) public constant returns (uint256,uint256,uint256,uint256) {
        return limits.getAccountLimits(_identityType, _accountAddress);
    }
}