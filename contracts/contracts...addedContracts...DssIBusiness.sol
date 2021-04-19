pragma solidity ^0.4.18;

import 'contracts/addedContracts/DssIBusiness.sol';
import 'contracts/addedContracts/DssBusinessBase.sol';

/**
 * @title DssIBusiness
 * @dev Интерфэйс контракта биснес процессов.
 */
contract DssIBusiness {

    // Получаем баланс банка в разрезе других банков для клиринга
    function getBankBalance(address bankAddress, address refBankAddress) public constant returns (uint);

    // Получаем баланс аккаунта по банку
    function getAccountBalance(address accountAddress, address bankAddress) public constant returns (uint);

    // Получение суммы эмиссии денег банка по его адресу
    function getBankIssues(address bankAddress) public constant returns (uint);

    // Получение лимита суммы эмиссии денег банка по его адресу
    function getBankIssuesLimit(address bankAddress) public constant returns (uint);

    // Обновление лимита суммы имиссии денег банка
    function updateBankIssuesLimit(address bankAddress, uint limit) public returns (bool);

    // Получение суммы эмиссии денег всех банков для этой валюты
    function getTotalIssues() public constant returns (uint);

    // Перевод денежных средств
    function transaction(address _from, address _to, uint _amount, bytes20 _invoice) public returns (bool, uint16);

    // Зачисление средств.
    function endow(address _from, address _to, uint _amount) public returns (bool);

    // Получение лимитов аккаунта в зависимости от типа идентификации
    function getAccountLimits(uint8 _identityType, address _accountAddress) public constant returns (uint256,uint256,uint256,uint256);

    // Обновление лимита аккаунта в зависимости от типа идентификации и типа лимита
    function updateAccountLimit(uint8 _identityType, uint8 _limitType, uint _limit, uint256 _endTime, address _creator) public returns (bool);
}
