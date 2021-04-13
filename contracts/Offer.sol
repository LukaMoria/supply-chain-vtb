// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.3;

contract Offer
{
    address payable private owner;
    string title;
    uint price;
    string description;
    uint256 quantity;          // uint256 maxQuantity;
    enum State{Opened, Booked, Approved, Rejected,  Declined, Completed}
    State public offerState;
    // mapping(address(this) => Purchase) puchasing;
    // mapping(this => Purchase) puchasing;
    
    
    
    /** @dev constructor to creat an auction
    * @param _owner who call createAuction() in AuctionBox contract
    * @param _title the title of the auction
    * @param _price the start price of the auction
    * @param _description the description of the auction
    */
    
    constructor(address payable _owner, string memory _title, uint _price, string memory _description, uint256 _quantity) {
    // initialize 
        owner = _owner;
        title = _title;
        price = _price;
        description = _description;
        quantity = _quantity;
        offerState = State.Opened;
    }
    
    modifier notOwner(){
        require(msg.sender != owner);
        _;
    }
    
    
    function changeState(State _state) public {
        offerState = _state;
    }
    
    
    function returnContents() public view returns(string memory, uint, string memory, State) {
        return (title, price, description, offerState);
    }
}