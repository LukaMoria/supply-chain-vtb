// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.3;

contract Offer {
    
    enum State {Created, Booked, Approved, Rejected, Declined, Completed}
    State private offerState;
    uint256 id;
    
    struct OfferItem{
        uint offerId;
        // address payable owner;
        string title;
        string type_v;
        uint price;
        uint256 amount;
        // address payable owner;
        
        State offerState;
    }
    
    constructor(){
        id = 0;
    }
    
    function updateId() private{
        id += 1;
    }
    
    OfferItem[] Values;
    
    mapping(address => OfferItem[]) public offers;
    
    
    function createProduct(string memory _title, 
                            string memory _type_v,
                            uint _price, 
                            uint256 _amount) public {
            Values.push(OfferItem({ offerId: id,
                                    title: _title, 
                                    type_v: _type_v,
                                    price: _price, 
                                    amount:_amount, 
                                    // owner: msg.sender,
                                    offerState: State.Created}));
            offers[msg.sender] = Values;
            
            updateId();
            
        }
    
    function changeState(uint index, address owner, State _state) public{
        offers[owner][index].offerState = _state;
    }

    function returnContents(address owner, uint index) public view returns(uint, string memory, string memory, uint, uint256) {
        return (offers[owner][index].offerId, 
                offers[owner][index].title, 
                offers[owner][index].type_v, 
                offers[owner][index].price, 
                offers[owner][index].amount);    
    }
    
    function returnState(address owner, uint index) public view returns(State){
        return offers[owner][index].offerState;
    }
}


// contract 

