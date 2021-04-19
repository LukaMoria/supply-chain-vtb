pragma solidity ^0.4.18;

import 'contracts/addedContracts/Ownable.sol';
import 'contracts/addedContracts/SafeMath.sol';
import 'contracts/addedContracts/DssIClearing.sol';
import 'contracts/addedContracts/DssBanks.sol';
import 'contracts/addedContracts/DssAccounts.sol';
import 'contracts/addedContracts/DssBusinessStorage.sol';
import 'contracts/addedContracts/DssRefundVault.sol';



/**
 * @title DssIClearing
 * @dev Интерфэйс контракта клиринга.
 */
contract DssIClearing {
    // Процедура клиринга
    function execute(address _bank) public;

}