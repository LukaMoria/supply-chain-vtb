
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.18;
// pragma experimental ABIEncoderV2;


import "contracts/addedContracts/Ownable.sol";
import "contracts/addedContracts/DssAccounts.sol";
import "contracts/addedContracts/Dss.sol";
import "contracts/addedContracts/DssErrors.sol";
import "contracts/Offers.sol";

contract DssSafeDeals is Ownable {
    DssAccounts private accounts;
    Dss private dss;
    DssErrors internal errors;
    address offersAddress;
    
    enum State{Created, Pending, Completed}
    
    
    struct Deal{
        address buyer;
        address seller;
        State dealState;
        address escrowAccoutAddress;
    }
    
    mapping (string => Deal) private deals;
    
    event EscrowCreated(string);
    
    function DssSafeDeal(address _errors, address _accounts, address  _dss, address _offers) public {
        require(_errors != 0x0);
        errors = DssErrors(_errors);
        accounts = DssAccounts(_accounts);
        dss = Dss(_dss);
        offersAddress = _offers;
    }
    
    function createEscrowAccountDeal(
        address accountAddress,       
        bytes32 identifier            
    ) public returns (bool) {
        return accounts.createEscrowAccount(accountAddress, identifier);   // address seller is redundant; проверки
        
    }
    
    function createEscrowDeal(string _UID, address _buyer, address _seller, address _accountAddress) public {
        accounts.createEscrowAccount(_accountAddress, "");    
        Offers offersContract = Offers(offersAddress);
        uint256 amount = offersContract.getAmountByUID(_UID); 
        dss.createInvoice(bytes20(_accountAddress), 
                            offersContract.getCodeByUID(_UID), 
                            _accountAddress, 
                            _buyer, 
                            amount, 
                            "");  
        deals[_UID] = Deal(_buyer,_seller,State.Created,_accountAddress);
        EscrowCreated(_UID);
    }
    
    
    function changeState(string _UID, State _state) public {
        deals[_UID].dealState = _state;
    }
    
    function transactionDeal(string _UID) public {
        Offers offersContract = Offers(offersAddress);
        uint256 amount = offersContract.getAmountByUID(_UID); 
        Deal memory currentDeal = deals[_UID];
        dss.transaction(offersContract.getCodeByUID(_UID), 
                        currentDeal.escrowAccoutAddress, 
                        currentDeal.seller, 
                        amount, 
                        "", 
                        "",
                        0,
                        "",
                        "");
        changeState(_UID, State.Completed);
    }
    
    function getDealBuyer(string _UID) public view returns (address){
        return deals[_UID].buyer;
    }
    
    function getDealSeller(string _UID) public view returns (address){
        return deals[_UID].seller;
    }
    
    function getDealState(string _UID) public view returns (State){
        return deals[_UID].dealState;
    }
    
    function getDealEscrow(string _UID) public view returns (address){
        return deals[_UID].escrowAccoutAddress;
    }
    
}
