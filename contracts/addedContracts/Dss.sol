pragma solidity ^0.4.18;

import 'contracts/addedContracts/Ownable.sol';
import 'contracts/addedContracts/DssCurrencies.sol';
import 'contracts/addedContracts/DssBanks.sol';
import 'contracts/addedContracts/DssBanksVoting.sol';
import 'contracts/addedContracts/DssAccounts.sol';
import 'contracts/addedContracts/DssRegulator.sol';
import 'contracts/addedContracts/DssTransactionEvent.sol';
import 'contracts/addedContracts/DssIBusiness.sol';
import 'contracts/addedContracts/DssIBusinessWithdraw.sol';
import 'contracts/addedContracts/DssIClearing.sol';
import 'contracts/addedContracts/DssIInvoiceStorage.sol';
import 'contracts/addedContracts/DssHistory.sol';

contract Dss is Ownable {

    // СК валют
    DssCurrencies private currencies;

    // СК кошельков
    DssAccounts private accounts;

    // СК банков
    DssBanks private banks;

    // СК Регулятора
    DssRegulator private regulator;

    // СК лога транзакций
    DssTransactionEvent  private transactionEvent;

    // СК счетов
    DssIInvoiceStorage private invoices;

    // СК истории
    DssHistory private history;

    modifier isBankOnly() {
        require(banks.isBank(msg.sender));
        _;
    }

    modifier isBankOrInternal() {
        require(msg.sender != tx.origin || banks.isBank(msg.sender));
        _;
    }

    modifier isBankOrOwner() {
        require(banks.isBank(msg.sender) || msg.sender == owner);
        _;
    }

    // set children contracts
    function set(address currenciesAddr, address banksAddr, address accountsAddr,
        address regulatorAddr, address transactionEventAddr, address invoicesAddr, address historyAddr)
    public onlyOwner returns (bool result) {

        require(currenciesAddr != 0x0);
        require(banksAddr != 0x0);
        require(accountsAddr != 0x0);
        require(regulatorAddr != 0x0);
        require(transactionEventAddr != 0x0);
        require(invoicesAddr != 0x0);
        require(historyAddr != 0x0);

        currencies = DssCurrencies(currenciesAddr);
        banks = DssBanks(banksAddr);
        accounts = DssAccounts(accountsAddr);
        regulator = DssRegulator(regulatorAddr);
        transactionEvent = DssTransactionEvent(transactionEventAddr);
        invoices = DssIInvoiceStorage(invoicesAddr);
        history = DssHistory(historyAddr);

        return true;
    }

    function remove() public onlyOwner {
        selfdestruct(owner);
    }

    // установка нового регулятора
    function setRegulator(address newRegulator, uint256 endTime) public isBankOnly returns (address) {
        return regulator.setRegulator(newRegulator, endTime, msg.sender);
    }

    /* utilities */

    function isSigned(address addr, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public pure returns (bool) {
        return ecrecover(msgHash, v, r, s) == addr;
    }

    function recoverAddress(bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public pure returns (address) {
        return ecrecover(msgHash, v, r, s);
    }

    /* end utilities */

    /*
        Start Currencies API
    */

    // Cretate new Currency
    function createCurrency(bytes32 name, uint16 code, bytes3 symbol, uint8 decimals, address businessContract, address withdrawContract, address clearingContract) public onlyOwner returns (bool){
        return currencies.create(name, code, symbol, decimals, businessContract, withdrawContract, clearingContract);
    }

    // Update Currency Business contract address
    function updateCurrencyBusinessContract(uint16 code, address oldAddress, address newAddress) public onlyOwner returns (bool){
        return currencies.updateBusinessContract(code, oldAddress, newAddress);
    }

    // Update Currency Business contract address
    function updateCurrencyClearingContract(uint16 code, address oldAddress, address newAddress) public onlyOwner returns (bool){
        return currencies.updateClearingContract(code, oldAddress, newAddress);
    }

    // Получаем СК бизнес логики по коду валюты
    function getDssBusinessByCurrencyCode(uint16 code) internal constant returns (bool, DssIBusiness) {
        address contractAddr = 0x0;
        (,,,, contractAddr,,) = currencies.getByCode(code);
        if (contractAddr == 0x0) {
            return (false, DssIBusiness(0x0));
        }
        return (true, DssIBusiness(contractAddr));
    }

    // Получаем СК бизнес логики по коду валюты
    function getDssBusinessWithdrawByCurrencyCode(uint16 code) internal constant returns (bool, DssIBusinessWithdraw) {
        address contractAddr = 0x0;
        (,,,,, contractAddr,) = currencies.getByCode(code);
        if (contractAddr == 0x0) {
            return (false, DssIBusinessWithdraw(0x0));
        }
        return (true, DssIBusinessWithdraw(contractAddr));
    }

    // Получаем СК клиринга по коду валюты
    function getDssClearingByCurrencyCode(uint16 code) internal constant returns (bool, DssIClearing) {
        address contractAddr = 0x0;
        (,,,,,, contractAddr) = currencies.getByCode(code);
        if (contractAddr == 0x0) {
            return (false, DssIClearing(0x0));
        }
        return (true, DssIClearing(contractAddr));
    }

    /*
        End Currencies API
    */

    /*
        Start Banks API
    */

    // Получение суммы имиссии денег банка по его адресу
    function getBankIssues(uint16 code, address bankAddress) public isBankOnly constant returns (uint){

        // Информацию может получить сам банк про себя или регулятор про всех
        if (msg.sender != bankAddress && msg.sender != regulator.regulator()) {
            return 0;
        }

        bool isExist;
        DssIBusiness trContract;
        (isExist, trContract) = getDssBusinessByCurrencyCode(code);
        if (!isExist) {
            return 0;
        }
        return trContract.getBankIssues(bankAddress);
    }

    // Получение лимита суммы имиссии денег банка по его адресу
    function getBankIssuesLimit(uint16 code, address bankAddress) public constant returns (uint){
        bool isExist;
        DssIBusiness trContract;
        (isExist, trContract) = getDssBusinessByCurrencyCode(code);
        if (!isExist) {
            return 0;
        }
        return trContract.getBankIssuesLimit(bankAddress);
    }

    // Получаем баланс банка для клиринга (требования)
    function getBankBalance(uint16 code, address bankAddress) public isBankOnly constant returns (address[], uint[], uint[]){

        uint n = banks.getBanksCount();

        address[] memory addressResult = new address[](n - 1);
        uint[] memory claimsResult = new uint[](n - 1);
        uint[] memory liabilitiesResult = new uint[](n - 1);

        // проверяем, что адрес запроса является адресом банка
        if (!banks.isBank(bankAddress)) {
            return (
            addressResult,
            claimsResult,
            liabilitiesResult
            );
        }
        // Информацию может получить сам банк про себя или регулятор про всех
        if (msg.sender != bankAddress && msg.sender != regulator.regulator()) {
            return (
            addressResult,
            claimsResult,
            liabilitiesResult
            );
        }

        address contractAddr = 0x0;
        (,,,, contractAddr,,) = currencies.getByCode(code);
        if (contractAddr == 0x0) {
            return (
            addressResult,
            claimsResult,
            liabilitiesResult
            );
        }
        uint index = 0;
        for (uint i = 0; i < n; i++) {
            address _addr = banks.getBankAddressByIndex(i);
            if (_addr != bankAddress) {
                // uint amount = DssIBusiness(contractAddr).getBankBalance(bankAddress, _addr);
                addressResult[index] = _addr;
                claimsResult[index] = DssIBusiness(contractAddr).getBankBalance(bankAddress, _addr);
                liabilitiesResult[index] = DssIBusiness(contractAddr).getBankBalance(_addr, bankAddress);
                index += 1;
            }
        }

        return (
        addressResult,
        claimsResult,
        liabilitiesResult
        );
    }

    function createBank(address bankAddress, bytes32 name, bytes32 bik, uint state) public isBankOrOwner returns (bool){
        return banks.createBank(bankAddress, name, bik, state);
    }

    // Обновление статуса банка
    function updateBankState(address bankAddress, uint8 bankState, uint256 endTime) public isBankOnly returns (address){
        return DssBanksVoting(banks.bankVotingAddress()).setBankState(bankAddress, bankState, endTime, msg.sender);
    }

    // Обновление лимита суммы имиссии денег банка
    function updateBankIssuesLimit(uint16 code, address bankAddress, uint limit) public isBankOnly returns (bool){
        bool isExist;
        DssIBusiness trContract;
        (isExist, trContract) = getDssBusinessByCurrencyCode(code);
        if (!isExist) {
            return false;
        }
        return trContract.updateBankIssuesLimit(bankAddress, limit);
    }

    function setBanksVotingAddress(address _bankVotingAddress) public isBankOrOwner {
        banks.setBanksVotingAddress(_bankVotingAddress);
    }
    /*
        End Banks API
    */

    /*
        Start Accounts API
    */

    // Получаем баланс аккаунта
    function getAccountBalance(uint16 code, address accountAddress) public constant returns (address[], uint[]){

        uint n = banks.getBanksCount();

        address[] memory addressResult = new address[](n);
        uint[] memory balanceResult = new uint[](n);

        if (!accounts.isAccount(accountAddress)) {
            return (
            addressResult,
            balanceResult
            );
        }

        address contractAddr = 0x0;
        (,,,, contractAddr,,) = currencies.getByCode(code);
        if (contractAddr == 0x0) {
            return (
            addressResult,
            balanceResult
            );
        }

        for (uint i = 0; i < n; i++) {
            address bankAddress = banks.getBankAddressByIndex(i);
            uint amount = DssIBusiness(contractAddr).getAccountBalance(accountAddress, bankAddress);
            if (amount > 0) {
                addressResult[i] = bankAddress;
                balanceResult[i] = amount;
            }
        }

        return (
        addressResult,
        balanceResult
        );
    }

    // Создание аккаунта
    function createAccount(
        address accountAddress,
        bytes32 identifier,
        bytes32 addressHash,
        uint8 state,
        uint8 juridicalType,
        uint8 identityType,
        uint8 v,
        bytes32 r,
        bytes32 s) public isBankOnly returns (bool){

        if (!isSigned(accountAddress, addressHash, v, r, s) || history.check(v, r, s)) {
            accounts.EmitEventErrorAccount(accountAddress, 200);
            return false;
        }
        bytes32 bankBik = 0x0;
        (,, bankBik,,) = banks.getBank(msg.sender);
        return accounts.createAccount(accountAddress, identifier, state, juridicalType, bankBik, identityType);
    }

    // Привязка идентификатора к аккаунту
    function addIdentifierForAccount(
        address accountAddress,
        bytes32 identifier,
        uint8 v,
        bytes32 r,
        bytes32 s) public isBankOnly returns (bool){
        if (!isSigned(accountAddress, identifier, v, r, s) || history.check(v, r, s)) {
            accounts.EmitEventErrorAccount(accountAddress, 200);
            return false;
        }
        return accounts.addIdentifierForAccount(accountAddress, identifier);
    }

    // Удаление идентификатора из аккаунта
    function removeIdentifierFromAccount(
        address accountAddress,
        bytes32 identifier,
        uint8 v,
        bytes32 r,
        bytes32 s) public isBankOnly returns (bool){
        if (!isSigned(accountAddress, identifier, v, r, s) || history.check(v, r, s)) {
            accounts.EmitEventErrorAccount(accountAddress, 200);
            return false;
        }
        return accounts.removeIdentifierFromAccount(accountAddress, identifier);
    }

    // Обновление статуса аккаунта
    function updateAccountState(address accountAddress, uint8 accountState) public isBankOnly returns (bool){
        return accounts.updateAccountState(accountAddress, accountState);
    }

    // Обновление юридического типа аккаунта
    function updateAccountJuridical(address accountAddress, uint8 juridicalTypeValue) public isBankOnly returns (bool){
        bytes32 bankBik = 0x0;
        (,, bankBik,,) = banks.getBank(msg.sender);
        return accounts.updateAccountJuridical(accountAddress, juridicalTypeValue, bankBik);
    }

    // Обновление статуса идентификации аккаунта
    function updateAccountIdentity(address accountAddress, uint8 identityTypeValue) public isBankOnly returns (bool){
        return accounts.updateAccountIdentity(accountAddress, identityTypeValue);
    }

    // Получение лимитов аккаунта в зависимости от типа идентификации
    function getAccountLimits(uint16 code, uint8 identityType, address accountAddress) public constant returns (uint256, uint256, uint256, uint256){
        bool isExist;
        DssIBusiness trContract;
        (isExist, trContract) = getDssBusinessByCurrencyCode(code);
        if (!isExist) {
            return (0, 0, 0, 0);
        }
        return trContract.getAccountLimits(identityType, accountAddress);
    }

    // Обновление лимита для аккаунта
    function updateAccountLimit(uint16 code, uint8 identityType, uint8 limitType, uint limit, uint256 endTime) public isBankOnly returns (bool){
        bool isExist;
        DssIBusiness trContract;
        (isExist, trContract) = getDssBusinessByCurrencyCode(code);
        if (!isExist) {
            return false;
        }
        return trContract.updateAccountLimit(identityType, limitType, limit, endTime, msg.sender);
    }
    /*
        End Accounts API
    */


    /*
        Start Transactions API
    */

    // Перевод денежных средств
    function transaction(
        uint16 code,
        address from,
        address to,
        uint amount,
        bytes20 invoice,
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s) public isBankOrInternal returns (bool){

        bool isOk;
        uint16 errCode;
        DssIBusiness trContract;
        (isOk, trContract) = getDssBusinessByCurrencyCode(code);
        if (!isOk) {
            return false;
        }

        if (accounts.getAccountType(from) == 1) {
            if(msg.sender != accounts.getOwner(from)){
                isOk = false;
                errCode = 109;
            }
        } else if(!isSigned(from, hash, v, r, s) || history.check(v, r, s)) {
            // Sign error
            transactionEvent.EmitTransactionTxLog(code, from, true, 0, amount, invoice, 200);
            transactionEvent.EmitTransactionTxLog(code, to, false, 0, amount, invoice, 200);

            isOk = false;
            errCode = 200;
        }

        if(isOk){
            (isOk, errCode) = trContract.transaction(from, to, amount, invoice);
        }

        if (invoice != "" && invoice != 0x0) {
            if (!isOk) {
                invoices.update(invoice, from, 3, errCode);
            } else {
                invoices.update(invoice, from, 5, 0);
            }
        }
        return isOk;
    }

    // Зачисление средств.
    function endow(uint16 code, address to, uint amount) public isBankOnly returns (bool) {
        address from = msg.sender;
        bool isExist;
        DssIBusiness trContract;
        (isExist, trContract) = getDssBusinessByCurrencyCode(code);
        if (!isExist) {
            return false;
        }
        return trContract.endow(from, to, amount);
    }

    // Снятие средств. Требует последующего подтверждения (фиксации) или отката к исходному состоянию
    function withdraw(uint16 code, address from, uint amount, bytes32 hash, uint8 v, bytes32 r, bytes32 s) public isBankOnly returns (bool) {
        bool isExist;
        DssIBusinessWithdraw trContract;
        (isExist, trContract) = getDssBusinessWithdrawByCurrencyCode(code);
        if (!isExist) {
            return false;
        }
        uint atc = 0;
        if (accounts.isAccount(from)) {
            atc = accounts.incrementAccountAct(from);
        }
        else {
            // Account From doesn't exist
            transactionEvent.EmitTransactionWithdrawLog(code, from, true, atc, amount, 0x0, 110);
            transactionEvent.EmitTransactionWithdrawLog(code, msg.sender, false, atc, amount, 0x0, 110);

            return false;
        }
        if (!isSigned(from, hash, v, r, s) || history.check(v, r, s)) {
            // Sign error
            transactionEvent.EmitTransactionWithdrawLog(code, from, true, atc, amount, 0x0, 200);
            transactionEvent.EmitTransactionWithdrawLog(code, msg.sender, false, atc, amount, 0x0, 200);

            return false;
        }
        return trContract.withdraw(atc, from, msg.sender, amount);
    }

    // Возврат денежных средств. Требует последующего подтверждения (фиксации) или отката к исходному состоянию
    function refund(uint16 code, address from) public isBankOnly returns (bool) {
        bool isExist;
        DssIBusinessWithdraw trContract;
        (isExist, trContract) = getDssBusinessWithdrawByCurrencyCode(code);
        if (!isExist) {
            return false;
        }
        uint atc = 0;
        if (accounts.isAccount(from)) {
            atc = accounts.incrementAccountAct(from);
            // блокируем аккаунт
            accounts.updateAccountState(from, 1);
        }
        else {
            // Account From doesn't exist
            transactionEvent.EmitTransactionWithdrawLog(code, from, true, atc, 0, 0x0, 110);
            transactionEvent.EmitTransactionWithdrawLog(code, msg.sender, false, atc, 0, 0x0, 110);

            return false;
        }
        return trContract.refund(atc, from, msg.sender);
    }

    // Возвращает результат процедуры снятия средств
    // Статус депозита
    // Средства списанные с аккаунта
    // Средства списанные c эммисионного счета
    // Средства зачисленные на транзитный счет других банков
    function withdrawResult(uint16 code, uint atc, address from) public constant isBankOnly returns (uint, uint, uint, uint){
        bool isExist;
        DssIBusinessWithdraw trContract;
        (isExist, trContract) = getDssBusinessWithdrawByCurrencyCode(code);
        if (!isExist) {
            return (0, 0, 0, 0);
        }
        return trContract.withdrawResult(atc, from);
    }

    // Подтверждение процедуры снятия средств
    function withdrawConfirm(uint16 code, uint atc, address from) public isBankOnly returns (bool) {
        bool isExist;
        DssIBusinessWithdraw trContract;
        (isExist, trContract) = getDssBusinessWithdrawByCurrencyCode(code);
        if (!isExist) {
            return false;
        }
        return trContract.withdrawConfirm(atc, from, msg.sender);
    }

    // Отменя процедуры снятия средств
    function withdrawReject(uint16 code, uint atc, address from) public isBankOnly returns (bool) {
        bool isExist;
        DssIBusinessWithdraw trContract;
        (isExist, trContract) = getDssBusinessWithdrawByCurrencyCode(code);
        if (!isExist) {
            return false;
        }
        return trContract.withdrawReject(atc, from, msg.sender);
    }

    // Общая сумма эммисии по валюте
    function getTotalIssues(uint16 code) public constant returns (uint) {
        bool isExist;
        DssIBusiness trContract;
        (isExist, trContract) = getDssBusinessByCurrencyCode(code);
        if (!isExist) {
            return 0;
        }
        return trContract.getTotalIssues();
    }

    /*
        End Transactions API
    */

    /*
     * Сlearing
    */

    function clearing(uint16 code) public isBankOnly returns (bool) {
        bool isExist;
        DssIClearing trContract;
        (isExist, trContract) = getDssClearingByCurrencyCode(code);
        if (!isExist) {
            return false;
        }
        trContract.execute(msg.sender);

        return true;
    }

    /*
     * End Сlearing
    */

    /*
    * Invoices
   */
    /**
     * @dev Создание нового счета
     * @param _number bytes20. Значение номера счета.
     * @param _currencyCode uint16. Значение кода валюты.
     * @param _recipient address. Адрес кошелька получателя счета.
     * @param _payer address. Адрес кошелька плательщика счета.
     * @param _amount uint256. Сумма в счете.
     * @param _description bytes32. Описание счета.
     * @return True - счет создан, false - счет не создан, ошибка.
    */
    function createInvoice(
        bytes20 _number,
        uint16 _currencyCode,
        address _recipient,
        address _payer,
        uint256 _amount,
        bytes32 _description
    ) public returns (bool){

        return invoices.create(
            _number,
            _currencyCode,
            _recipient,
            _payer,
            _amount,
            _description,
            msg.sender
        );
    }
    /*
    * End Invoices
   */
}
