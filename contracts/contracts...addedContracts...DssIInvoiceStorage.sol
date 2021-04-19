pragma solidity ^0.4.18;

/**
 * @title DssIInvoiceStorage
 * @dev Интерфейс хранилища счетов.
 */
contract DssIInvoiceStorage {

    /**
     * @dev Проверка существования счета
     * @param _number bytes20 Значение номера счета.
     * @return True - счет существует, false - счет не существует.
     */
    function isInvoice(bytes20 _number) public constant returns (bool);

    /**
     * @dev Получаем количество счетов
     * @return uint 256 - количество счетов.
    */
    function getCount() public constant returns (uint);

    /**
     * @dev Получение информации по счету
     * @param _number bytes20. Значение номера счета.
     * @return  uint16 - Код валюты,
     *          address - Получатель,
     *          address - Плательщик,
     *          uint256 - Сумма,
     *          uint8 - Статус счета,
     *          uint16 - Код ошибки (оплаты),
     *          uint256 - Дата создания
    */
    function getInvoice(bytes20 _number) public constant returns (uint16, address, address, uint256, uint8, uint16, uint256);

    /**
    * @dev Получение дополнительной информации по счету
    * @param _number bytes20. Значение номера счета.
    * @return  string - Описание счета
   */
    function getInvoiceDetails(bytes20 _number) public constant returns (bytes32);

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
    function create(
        bytes20 _number,
        uint16 _currencyCode,
        address _recipient,
        address _payer,
        uint256 _amount,
        bytes32 _description,
        address _owner
    ) public returns (bool);

    /**
     * @dev Обновление существующего счета
     * @param _number bytes20. Значение номера счета.
     * @param _payer address. Адрес кошелька плательщика счета.
     * @param _state uint8. Значение нового статуса счета
     * @param _errorCode uint. Код ошибки.
     * @return True - счет обновлен, false - счет не обновлен, ошибка.
    */
    function update(bytes20 _number, address _payer, uint8 _state, uint16 _errorCode) public returns (bool);
}

