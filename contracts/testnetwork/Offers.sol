// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.3;

contract Offers {
    string UID;

    struct Offer {
        address owner;
        string title;
        string type_v;
        uint price;
        uint256 amount;
        uint256 currency;
        address OwnerWallet;
    }

    mapping (string => Offer) private offers;
    Offer[] public offerList;

    event ProductCreated(string _UID);

    function createOffer (string memory _UID,
                string memory _title,
                string memory _type_v,
                uint _price,
                uint256 _amount,
                uint256 _currency,
                address  _wallet
               ) public{
        offers[_UID] = Offer({owner: msg.sender,
                                    title: _title,
                                    type_v: _type_v,
                                    price: _price,
                                    amount:_amount,
                                    currency: _currency,
                                    OwnerWallet: _wallet
        });
        offerList.push(offers[_UID]);
        emit ProductCreated(_UID);
    }

    function returnAllOffers() public view returns(Offer[] memory){
        return offerList;
    }
    
    function returnOfferByUID(string memory _UID) public view returns(Offer memory){
        return offers[_UID];
    }
}