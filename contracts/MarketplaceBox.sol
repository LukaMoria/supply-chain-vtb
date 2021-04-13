// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.3;

contract MarketplaceBox {

   Offer[] public offers;
    function createOffer (string memory _title, uint _price, string memory _description, uint256 _quantity) public{
        Offer newOffer = new Offer(payable(msg.sender), _title, _price, _description, _quantity);
        offers.push(newOffer);
    }
    
    function returnAllOffers() public view returns(Offer[] memory){
        return offers;
    }
}

