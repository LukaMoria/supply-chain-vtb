pragma solidity ^0.4.18;


import 'contracts/addedContracts/DssIBusiness.sol';
import 'contracts/addedContracts/DssBusinessBase.sol';


/**
 * @title DssIBusinessWithdraw
 * @dev Интерфэйс контракта биснес процесса списания средств.
 */
contract DssIBusinessWithdraw {

    // Снятие средств
    function withdraw(uint _atc, address _from, address _to, uint _amount) public returns (bool);
    // Возврат средств
    function refund(uint _atc, address _from, address _to) public returns (bool);

    // Подтверждение процедуры снятия средств
    function withdrawConfirm(uint _atc, address _from, address _to) public returns (bool);

    // Отменя процедуры снятия средств
    function withdrawReject(uint _atc, address _from, address _to) public returns (bool);

    // Возвращает результат процедуры снятия средств
    // Статус депозита
    // Средства списанные с аккаунта
    // Средства списанные c эмиссионного счета
    // Средства зачисленные на транзитный счет других банков
    function withdrawResult(uint _atc, address _from) public constant returns (uint, uint, uint, uint);

    // Возвращает по коду валюты адрес контракта, который отвечает за заморозку списываемых средств
    function getRefundVaultContractAddress() public constant returns (address);
}
