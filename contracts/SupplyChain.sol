// Implement the smart contract SupplyChain following the provided instructions.
// Look at the tests in SupplyChain.test.js and run 'truffle test' to be sure that your contract is working properly.
// Only this file (SupplyChain.sol) should be modified, otherwise your assignment submission may be disqualified.

pragma solidity ^0.5.0;

contract SupplyChain {
  
  address payable owner;

  // Create a variable named 'itemIdCount' to store the number of items and also be used as reference for the next itemId.
  uint itemIdCount;

  constructor() public {
    owner = msg.sender;
    itemIdCount = 0;
  }

  // Create an enumerated type variable named 'State' to list the possible states of an item (in this order): 'ForSale', 'Sold', 'Shipped' and 'Received'.
  enum State {ForSale, Sold, Shipped, Received }

  // Create a struct named 'Item' containing the following members (in this order): 'name', 'price', 'state', 'seller' and 'buyer'.
  struct Item {
    string name;
    uint price;
    State state;
    address payable seller;
    address payable buyer;
  }

  // Create a variable named 'items' to map itemIds to Items.
    mapping (uint => Item) items;

  // Create an event to log all state changes for each item.
    event LogForSale(uint _itemIdCount);
    event LogSold(uint _itemIdCount);
    event LogShipped(uint _itemIdCount);
    event LogReceived(uint _itemIdCount);

  // Create a modifier named 'onlyOwner' where only the contract owner can proceed with the execution.
    modifier onlyOwner() {require(msg.sender == owner); _;}
  // Create a modifier named 'checkState' where the execution can only proceed if the respective Item of a given itemId is in a specific state.
    modifier checkState(uint _itemId, State _state) {require(items[_itemId].state == _state); _;}
  // Create a modifier named 'checkCaller' where only the buyer or the seller (depends on the function) of an Item can proceed with the execution.
    modifier checkCaller(address _requiredCaller) {require(msg.sender == _requiredCaller); _;}
  // Create a modifier named 'checkValue' where the execution can only proceed if the caller sent enough Ether to pay for a specific Item or fee.
    modifier checkValue(uint _value) {require(msg.value >= _value); _;}

  // Create a function named 'addItem' that allows anyone to add a new Item by paying a fee of 1 finney. Any overpayment amount should be returned to the caller. All struct members should be mandatory except the buyer.
    function addItem(string memory _name, uint _price) public payable checkValue(1 finney) returns (bool) {
      emit LogForSale(itemIdCount);
      items[itemIdCount] = Item({name: _name, price: _price, state: State.ForSale, seller: msg.sender, buyer: address(0)});
      itemIdCount = itemIdCount + 1;
      return true;
    }
  // Create a function named 'buyItem' that allows anyone to buy a specific Item by paying its price. The price amount should be transferred to the seller and any overpayment amount should be returned to the buyer.
  function buyItem(uint _itemId) public payable checkState(_itemId, State.ForSale) checkValue(items[_itemId].price) returns (bool) {
    emit LogSold(_itemId);
    items[_itemId].seller.transfer(items[_itemId].price);
    items[_itemId].buyer = msg.sender;
    items[_itemId].state = State.Sold;
    uint refundAmount = msg.value - items[_itemId].price;
    items[_itemId].buyer.transfer(refundAmount);
    return true;
  }
  // Create a function named 'shipItem' that allows the seller of a specific Item to record that it has been shipped.
  function shipItem(uint _itemId) public checkState(_itemId, State.Sold) checkCaller(items[_itemId].seller) {
    emit LogShipped(_itemId);
    items[_itemId].state = State.Shipped;
  }
  // Create a function named 'receiveItem' that allows the buyer of a specific Item to record that it has been received.
  function receiveItem(uint _itemId) public checkState(_itemId, State.Shipped) checkCaller(items[_itemId].buyer) {
    emit LogReceived(_itemId);
    items[_itemId].state = State.Received;
  }
  // Create a function named 'getItem' that allows anyone to get all the information of a specific Item in the same order of the struct Item.
  function getItem(uint _itemId) public view returns (string memory name, uint price, State state, address seller, address buyer) {
    name = items[_itemId].name;
    price = items[_itemId].price;
    state = items[_itemId].state;
    seller = items[_itemId].seller;
    buyer = items[_itemId].buyer;
    return (name, price, state, seller, buyer);
  }
  // Create a function named 'withdrawFunds' that allows the contract owner to withdraw all the available funds.
  function withdrawFunds() public payable onlyOwner() returns (bool) {
    uint256 balance = address(this).balance;
    owner.transfer(balance);
    return true;
  }
}
