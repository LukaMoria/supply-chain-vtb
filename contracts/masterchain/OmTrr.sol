// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.4.18;

import "./contracts/Ownable.sol";
import "./contracts/DssErrors.sol";
import "./contracts/DssAccounts.sol";
import "./contracts/Dss.sol";
// import 'OmTrr.sol';


contract Offers {
    string UID;
    

    struct Offer{
        address owner;
        string title;
        string type_v;
        uint price;
        uint256 amount;
        address OwnerWallet;
    }

    mapping (string => Offer) private offers;
    Offer[] public offerList;

    event ProductCreated(string _UID);
    //event ESMCreated(string UID, address buyer, address seller);

    function createOffer (string memory _UID,
                string memory _title,
                string memory _type_v,
                uint _price,
                uint256 _amount,
                address  _wallet
               ) public{
        offers[_UID] = Offer({owner: msg.sender,
                                    title: _title,
                                    type_v: _type_v,
                                    price: _price,
                                    amount:_amount,
                                    OwnerWallet: _wallet
        });
        offerList.push(offers[_UID]);
        ProductCreated(_UID);


    }

    function returnAllOffers() public view returns(Offer[] memory){
        return offerList;
    }

}

contract DssSafeDeal is Ownable {
    DssAccounts private accounts;
    Dss private dss;
    // Cк ошибок
    DssErrors internal errors;
    Offers offersContract;
    
    enum State{Created, Pending, Completed}
    
    struct Deal{
        address buyer;
        address seller;
        State dealState;
        address escrowAccoutAddress;
    }
    
    mapping (string => Deal) private deals;
    
    event EscrowCreated(Deal deal);
    
    function DssSafeDeal(address _errors, address _accounts, address  _dss, address _offers) public {
        require(_errors != 0x0);
        errors = DssErrors(_errors);
        accounts = DssAccounts(_accounts);
        dss = Dss(_dss);
        // адрес офферов 
        offersContract = Offers(_offers);
    }
    
    function createEscrowAccountDeal(
        address accountAddress,       // Адрес аккаунта (Уникальный хеш, hex-строка состоящая из 42 символов и начинающийся с 0x)
        bytes32 identifier            // bytes32 - Идентификатор аккаунта (не обязательное поле)
    ) public returns (bool) {
        return accounts.createEscrowAccount(accountAddress, identifier);
    }
    
    function createEscrowDeal(string _UID, address _buyer, address _seller, address _accountAddress){
        accounts.createEscrowAccount(_accountAddress);
        Offer offerStruct = offersContract.offers[_UID];
        dss.createInvoice(_accountAddress, offerStruct.currencyCode, _accountAddress, buyer, offerStruct.amount, "");
        deals[_UID] = Deal({    buyer: _buyer,
                                seller: _seller,
                                dealState: State.Created,
                                escrowAccoutAddress: _accountAddress
                            });
        EscrowCreated(deals[_UID]);
    }
    
    
    function changeState(string _UID, uint _state) public {
        deals[_UID].dealState = _state;
    }
    
    function transactionDeal(string _UID) public {
        Offer currentOffer = offersContract.offers[_UID];
        Deal currentDeal = deals[_UID];
        dss.transaction(currentOffer.currencyCode, currentDeal.escrowAccoutAddress, currentDeal.seller, currentOffer.amount, "", "","","", "");
        changeState(_UID, 2);
    }
    
    function getDeal(string _UID) public returns (Deal){
        return deals[_UID];
    }
    
    function getAllDeal(string _UID) public {
        return deals[_UID];
    }
        
}

