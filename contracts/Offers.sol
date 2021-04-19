// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.18;

contract Offers {
    string UID;
    

    struct Offer{
        address owner;
        string title;
        string type_v;
        uint16 currencyCode;
        uint price;
        uint256 amount;
        address OwnerWallet;
        string uid;
    }

    mapping (string => Offer) private offers;
    Offer[] public offerList;

    event ProductCreated(string _UID);


    function createOffer (string memory _UID,
                string memory _title,
                string memory _type_v,
                uint16 _currencyCode,
                uint _price,
                uint256 _amount,
                address  _wallet
               ) public{
        offers[_UID] = Offer({ owner: msg.sender,
                                    title: _title,
                                    type_v: _type_v,
                                    currencyCode: _currencyCode,
                                    price: _price,
                                    amount:_amount,
                                    OwnerWallet: _wallet,
                                    uid: _UID
        });
        offerList.push(offers[_UID]);
        
        ProductCreated(_UID);
    }
    
    function returnAllOffers() public view returns(Offer[] memory){
        return offerList;
    }
    
    function getAmountByUID(string memory _UID) public view returns(uint256){
        return offers[_UID].amount;
    }
    
    
    function getCodeByUID(string memory _UID) public view returns(uint16){
        return offers[_UID].currencyCode;
    }

}
