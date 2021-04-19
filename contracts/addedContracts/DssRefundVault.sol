pragma solidity ^0.4.18;

import 'contracts/addedContracts/Ownable.sol';
import 'contracts/addedContracts/SafeMath.sol';

/**
 * @title DssRefundVault
 * @dev Этот контракт используется для хранения списываемых средств
 * с аккаунта для перевода банку до тех пор, пока не будет подтверждение или возврат.
 */
contract DssRefundVault is Ownable {
    using SafeMath for uint256;

    // Состояние депозита для workflow
    enum State {None, Deposited, Confirmed, Rejected}

    // Структура депозита
    struct DepositedBalance {
        State depositedState;
        uint256 accountAmount;
        address issueBankAddress;
        uint256 issueBankAmount;
        uint256 banksTotalAmount;
        address[] banksAddresses;
        mapping(address => uint256) banksBalance;
    }

    /*
     * Хранилище депозитов: account => atc => DepositedBalance
    */
    mapping(address => mapping(uint256 => DepositedBalance)) public deposited;

    /*
     * Хранилище депозитов в разрезе банков: адрес банка эммитента => адрес банка => сумма депозита
    */
    mapping(address => mapping(address => uint256)) public banksDeposited;

    // Событие подтверждения списания средств
    event WithdrawConfirmed(address indexed beneficiary, uint256 amount);

    // Событие отказа от списания средств, средства возвращаются на аккаунт
    event WithdrawRejected(address indexed beneficiary, uint256 amount);

    /*
      * Возвращает сумму депозита по адресу банка
      * issueBank - адрес банка эммитент
      * bank - адрес банка
    */
    function getTotalDepositByBank(address issueBank, address bank) public constant returns (uint256) {
        require(issueBank != 0x0);
        require(bank != 0x0);

        return banksDeposited[issueBank][bank];
    }

    // Инициализация депозита
    function deposit(address account, address bank, uint256 atc, uint256 accountAmount) onlyOwner public {
        require(account != 0x0);
        require(accountAmount != 0);
        require(bank != 0x0);
        require(deposited[account][atc].issueBankAddress == 0x0);
        require(deposited[account][atc].depositedState == State.None);

        deposited[account][atc].depositedState = State.Deposited;
        deposited[account][atc].accountAmount = accountAmount;
        deposited[account][atc].issueBankAddress = bank;
    }

    // Добавляем в депозит средства по банку
    function depositByBank(address account, address bank, uint256 atc, uint256 amount) onlyOwner public {
        require(account != 0x0);
        require(amount != 0);
        require(bank != 0x0);

        uint256 totalAmount = 0;
        if (bank == deposited[account][atc].issueBankAddress) {
            totalAmount = deposited[account][atc].issueBankAmount;
            deposited[account][atc].issueBankAmount = totalAmount.add(amount);
        }
        else {
            totalAmount = deposited[account][atc].banksTotalAmount;
            deposited[account][atc].banksTotalAmount = totalAmount.add(amount);
            deposited[account][atc].banksBalance[bank] = amount;

            banksDeposited[deposited[account][atc].issueBankAddress][bank] = banksDeposited[deposited[account][atc].issueBankAddress][bank].add(amount);
        }
    }

    // Подтверждаем списание, обнуляем депозит
    function confirm(address account, uint256 atc) onlyOwner public {
        require(account != 0x0);

        uint256 accountAmount = deposited[account][atc].accountAmount;
        deposited[account][atc].depositedState = State.Confirmed;
        clear(account, atc);
        WithdrawConfirmed(account, accountAmount);
    }

    // Подтверждаем средств по каждому банку на счет аккаунта
    function confirmByBank(address account, address bank, uint256 atc) onlyOwner public returns (uint) {
        require(account != 0x0);
        require(bank != 0x0);

        uint amount = 0;
        if (bank == deposited[account][atc].issueBankAddress) {
            amount = deposited[account][atc].issueBankAmount;
            deposited[account][atc].issueBankAmount = 0;
        }
        else {
            amount = deposited[account][atc].banksBalance[bank];
            deposited[account][atc].banksBalance[bank] = 0;

            banksDeposited[deposited[account][atc].issueBankAddress][bank] = banksDeposited[deposited[account][atc].issueBankAddress][bank].sub(amount);
        }
        return amount;
    }

    // Отказ от списания средств, закрываем депозит (предварительно вернув деньги)
    function reject(address account, uint256 atc) onlyOwner public {
        require(account != 0x0);

        uint256 accountAmount = deposited[account][atc].accountAmount;
        deposited[account][atc].depositedState = State.Rejected;
        clear(account, atc);
        WithdrawRejected(account, accountAmount);
    }

    // Возврат средств по каждому банку на счет аккаунта
    function rejectByBank(address account, address bank, uint256 atc) onlyOwner public returns (uint) {
        require(account != 0x0);
        require(bank != 0x0);

        uint amount = 0;
        if (bank == deposited[account][atc].issueBankAddress) {
            amount = deposited[account][atc].issueBankAmount;
            deposited[account][atc].issueBankAmount = 0;
        }
        else {
            amount = deposited[account][atc].banksBalance[bank];
            deposited[account][atc].banksBalance[bank] = 0;
            deposited[account][atc].banksTotalAmount = deposited[account][atc].banksTotalAmount.sub(amount);

            banksDeposited[deposited[account][atc].issueBankAddress][bank] = banksDeposited[deposited[account][atc].issueBankAddress][bank].sub(amount);
        }
        return amount;
    }

    // Обнуление депозита в статусе депозит подтвержден или депозит отменен
    function clear(address account, uint256 atc) internal {

        // require(deposited[account][atc].depositedState == State.Confirmed || deposited[account][atc].depositedState == State.Rejected);

        deposited[account][atc].accountAmount = 0;
        deposited[account][atc].issueBankAddress = 0x0;
        deposited[account][atc].issueBankAmount = 0;
        deposited[account][atc].banksTotalAmount = 0;
        delete deposited[account][atc].banksAddresses;
    }
}
