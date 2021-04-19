pragma solidity ^0.4.18;

/**
 * @title DssTransactionEvent
 * @dev Контракт обработки события транзакции.
 */
contract DssTransactionEvent {

    /**
     * @dev Событие перевода средств
     * @param currencyCode uint16. Код валюты.
     * @param addr address. Адрес кошелька.
     * @param txType uint8. Тип перевода: 1 - endow, 2 - withdraw, 3 - transfer, 4 - payment.
     * @param spend bool. Признак зачисления/списания с кошелька.
     * @param atc uint. Порядковый номер операции.
     * @param amount uint. Сумма средств.
     * @param dt uint. Дата события.
     * @param reason bytes32. Дополнительная инормация.
     * @param errorCode uint16. Код ошибки.
    */
    event TransactionLog(uint16 indexed currencyCode, address indexed addr, uint8 txType, bool spend, uint atc, uint amount, uint dt, bytes32 reason, uint16 errorCode);

    function EmitTransactionLog(uint16 code, address addr, uint8 txType, bool spend, uint atc, uint amount, bytes32 reason, uint16 errorCode) public {
        TransactionLog(code, addr, txType, spend, atc, amount, now, reason, errorCode);
    }

    function EmitTransactionTxLog(uint16 code, address addr, bool spend, uint atc, uint amount, bytes32 reason, uint16 errorCode) public {
        TransactionLog(code, addr, 3, spend, atc, amount, now, reason, errorCode);
    }

    function EmitTransactionWithdrawLog(uint16 code, address addr, bool spend, uint atc, uint amount, bytes32 reason, uint16 errorCode) public {
        TransactionLog(code, addr, 2, spend, atc, amount, now, reason, errorCode);
    }
}
