pragma solidity ^0.4.18;

import 'contracts/addedContracts/Ownable.sol';
import 'contracts/addedContracts/SafeMath.sol';
import 'contracts/addedContracts/DssBanks.sol';
import 'contracts/addedContracts/DssAccounts.sol';

/**
*   @title DssBusinessStorage
*   @dev Хранилище данных БЛ
*/
contract DssBusinessStorage is Ownable {
    using SafeMath for uint256;

    // Структура баланса
    struct Balance {
        // balance transactions count
        uint btc;
        // Amount
        uint amount;
    }

    // account address => (bank address => balance)
    mapping(address => mapping(address => Balance)) internal accountsBalanceOf;

    // bank address => (bank address => balance)
    // В клиринге это называется требования (claims)
    mapping(address => mapping(address => Balance)) internal banksBalanceOf;

    // Bank address => bank issue
    mapping(address => uint) internal banksIssue;

    // Bank address => bank issue limit
    mapping(address => uint) internal banksIssueLimit;

    // Contract address => permission bit (0 - no permission, 1 -read, 2- write)
    mapping(address => uint8) internal permissions;

    // СК банков
    DssBanks internal banks;

    // СК аккаунтов
    DssAccounts internal accounts;

    function DssBusinessStorage(address _banks, address _accounts) public {
        require(_banks != 0x0);
        require(_accounts != 0x0);

        banks = DssBanks(_banks);
        accounts = DssAccounts(_accounts);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier allowWrite() {
        require(permissions[msg.sender] == 2);
        _;
    }

    function prepareBasksArray(address _from, address _to) internal view returns (address[]) {
        uint banksCount = banks.getBanksCount();
        uint index = 0;

        address[] memory addressBanks = new address[](banksCount);

        uint topIndex = 0;
        uint downIndex = banksCount - 1;
        for (index = 0; index < banksCount; index++) {
            address bankAddress = banks.getBankAddressByIndex(index);
            Balance memory _balanceFrom = accountsBalanceOf[_from][bankAddress];
            if (_balanceFrom.amount > 0) {
                Balance memory _balanceTo = accountsBalanceOf[_to][bankAddress];
                if (_balanceTo.amount > 0) {
                    addressBanks[topIndex] = bankAddress;
                    topIndex++;
                }
                else {
                    addressBanks[downIndex] = bankAddress;
                    if (downIndex > 0) downIndex--;
                }
            }
        }

        return addressBanks;
    }

    // Установка прав доступа
    function setPermissions(address _owner, uint8 _flag) public onlyOwner() {
        permissions[_owner] = _flag;
    }

    // Получаем суммарный баланс аккаунта
    function getAccountTotalBalance(address accountAddress) public constant returns (uint){
        if (!accounts.isAccount(accountAddress)) {
            return 0;
        }
        uint totalBalance = 0;
        uint banksCount = banks.getBanksCount();
        for (uint i = 0; i < banksCount; i++) {
            address addrBank = banks.getBankAddressByIndex(i);
            if (addrBank == 0x0) {
                continue;
            }
            totalBalance = totalBalance.add(accountsBalanceOf[accountAddress][addrBank].amount);
        }
        return totalBalance;
    }

    // Получаем баланс аккаунта по банку
    function getAccountBalance(address accountAddress, address bankAddress) public constant returns (uint){
        if (!accounts.isAccount(accountAddress)) {
            return 0;
        }
        if (!banks.isBank(bankAddress)) {
            return 0;
        }

        return accountsBalanceOf[accountAddress][bankAddress].amount;
    }

    // Задаем новое значение баланса аккаунта по банку
    function setAccountBalance(address accountAddress, address bankAddress, uint256 amount) public allowWrite() {
        if (!accounts.isAccount(accountAddress)) {
            return;
        }
        if (!banks.isBank(bankAddress)) {
            return;
        }

        accountsBalanceOf[accountAddress][bankAddress].amount = amount;
    }

    // Получаем баланс банка в разрезе других банков для клиринга
    function getBankBalance(address bankAddress, address refBankAddress) public constant returns (uint){
        if (!banks.isBank(bankAddress)) {
            return 0;
        }
        if (!banks.isBank(refBankAddress)) {
            return 0;
        }

        // Возвращаем баланс по банку за вычитом "замороженных"  средств на депозите для операции withdraw
        return banksBalanceOf[bankAddress][refBankAddress].amount;
    }

    // Вычисляем адрес банка сумма средств по которому максимальная для аккаунта
    function getBankAddressWithMaxAmount(address _from, address _to, uint banksCount) public constant returns (address){
        address maxAmountBankAddress = 0x0;
        uint maxAmount = 0;

        for (uint index = 0; index < banksCount; index++) {
            address bankAddress = banks.getBankAddressByIndex(index);
            if (_to == bankAddress) continue;
            uint bankAmount = accountsBalanceOf[_from][bankAddress].amount;
            if (maxAmount < bankAmount) {
                maxAmountBankAddress = bankAddress;
                maxAmount = bankAmount;
            }
        }
        return maxAmountBankAddress;
    }

    // Задаем новое значение баланса банка в разрезе другого банков для клиринга
    // ограничить доступ для метода только business и clearing контрактами
    function setBankBalance(address bankAddress, address refBankAddress, uint256 amount) public allowWrite() {
        if (!banks.isBank(bankAddress)) {
            return;
        }
        if (!banks.isBank(refBankAddress)) {
            return;
        }
        // Задаем новое значение баланса банка
        banksBalanceOf[bankAddress][refBankAddress].amount = amount;
    }

    // Получение суммы эмиссии денег банка по его адресу
    function getBankIssues(address bankAddress) public constant returns (uint){
        if (!banks.isBank(bankAddress)) {
            return 0;
        }
        return banksIssue[bankAddress];
    }

    // Задаем новое значение суммы эмиссии денег банка по его адресу
    function setBankIssues(address bankAddress, uint256 amount) public allowWrite() {
        if (!banks.isBank(bankAddress)) {
            return;
        }
        banksIssue[bankAddress] = amount;
    }

    // Получение лимита суммы эмиссии денег банка по его адресу
    function getBankIssuesLimit(address bankAddress) public constant returns (uint){
        if (!banks.isBank(bankAddress)) {
            return 0;
        }
        return banksIssueLimit[bankAddress];
    }

    // Получение суммы эмиссии денег всех банков для этой валюты
    function getTotalIssues() public constant returns (uint){
        uint n = banks.getBanksCount();
        uint totalAmount = 0;
        for (uint i = 0; i < n; i++) {
            totalAmount = totalAmount.add(getBankIssues(banks.getBankAddressByIndex(i)));
        }
        return totalAmount;
    }

    // Обновление лимита суммы имиссии денег банка
    function updateBankIssuesLimit(address bankAddress, uint limit) public allowWrite() returns (bool){
        banksIssueLimit[bankAddress] = limit;
        return true;
    }

    // Проведение процедуры перевода средств с аккаунта на аккаунт
    function transaction(address _from, address _to, uint _amount) public allowWrite() returns (uint256) {
        uint totalAmountTransfered = 0;
        uint index = 0;
        address[] memory sortedBanks = prepareBasksArray(_from, _to);
        while (totalAmountTransfered < _amount && index < sortedBanks.length) {
            address addrBank = sortedBanks[index];
            if (addrBank == 0x0) {
                index += 1;
                continue;
            }
            uint bankAmount = accountsBalanceOf[_from][addrBank].amount;
            if (bankAmount == 0) {
                index += 1;
                continue;
            }
            uint rest = 0;
            if (totalAmountTransfered + bankAmount >= _amount) {
                rest = totalAmountTransfered + bankAmount - _amount;
                bankAmount -= rest;
            }

            accountsBalanceOf[_from][addrBank].amount = rest;
            accountsBalanceOf[_to][addrBank].amount += bankAmount;

            totalAmountTransfered += bankAmount;
            index += 1;
        }

        return totalAmountTransfered;
    }

    // Зачисление средств.
    function endow(address _from, address _to, uint _amount) public allowWrite() returns (uint256) {

        accountsBalanceOf[_to][_from].btc = accountsBalanceOf[_to][_from].btc.add(1);
        accountsBalanceOf[_to][_from].amount = accountsBalanceOf[_to][_from].amount.add(_amount);

        banksIssue[_from] = banksIssue[_from].add(_amount);

        return accountsBalanceOf[_to][_from].btc;
    }

    // Отмена процедуры снятия средств
    function withdrawReject(address _from, address _to, address _bankAddress, uint256 _bankAmount) public allowWrite() {
        if (_bankAmount > 0) {
            accountsBalanceOf[_from][_bankAddress].amount = accountsBalanceOf[_from][_bankAddress].amount.add(_bankAmount);
            if (_bankAddress != _to) {
                // Списываем с баланса банка эммитента для клиринга
                banksBalanceOf[_to][_bankAddress].amount = banksBalanceOf[_to][_bankAddress].amount.sub(_bankAmount);
            }
            // Возвращаем на сумму эмиссии
            banksIssue[_bankAddress] = banksIssue[_bankAddress].add(_bankAmount);
        }
    }
}