//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

 contract Box is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    struct EventInfo {
        uint256 totalSupply;
        uint256 boxPrice;
        string currency;
        uint256 startTime;
        uint256 endTime;
        uint256 maxBuy;
    }
    Box[] private box;
    mapping(uint256 => EventInfo) public eventByID;
    event EventCreated(uint _totalSupply, uint _price, string _currency,uint _startTime,uint _endTime,uint _maxBuy);
    event mintBox(uint _sum,address _recipient);
    constructor() ERC721("Box", "BOX") {}
   
    function _mintNFT(address recipient)
        private  
    {   
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        
    }

    function createEvent(
        uint256 _eventID,
        uint256 _totalSupply,
        uint256 _price,
        string memory _currency,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _maxBuy
    ) external onlyOwner {
        require(_totalSupply > 0, "Invalid Supply");
        require(_startTime < _endTime, "Invalid time");
        require(_maxBuy > 0, "Need set max buy");

        eventByID[_eventID] = EventInfo(_totalSupply, _price, _currency, _startTime, _endTime, _maxBuy);
        emit EventCreated(
            _totalSupply,
            _price,
            _currency,
            _startTime,
            _endTime,
            _maxBuy
        );
    }
    function saleBox(uint eventID,uint sum) external payable {
        require(msg.value == eventByID[eventID].boxPrice * sum );
        require(sum < eventByID[eventID].maxBuy );
        require(eventByID[eventID].startTime <= block.timestamp &&  block.timestamp <= eventByID[eventID].endTime);
         for(uint8 i=0;i<sum;i++){
             _mintNFT(msg.sender);
         }
        emit mintBox(sum,msg.sender);
    }

}
