//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

 contract Box is ERC721, Ownable {
    using Counters for Counters.Counter;    
    struct EventInfo {
        uint256 totalSupply;
        string[] nameBoxSale;
        uint[] numberBoxSale;
        uint256 boxCount;
        uint256 boxPrice;
        address currency;
        uint256 startTime;
        uint256 endTime;
        uint256 maxBuy;
    }
   struct BoxList {
        uint256 quantity;
        uint256 bought;
        string nameBox;
        string uriImage;
    }
    mapping (uint => BoxList ) boxListByID;
    mapping (uint => mapping(uint => BoxList)) boxesByEvent;
    mapping(uint256 => EventInfo) public eventByID;
    mapping (uint => uint ) boxByEvent;
    mapping (uint => mapping(address => uint)) userBought;
    event EventCreated(uint _totalSupply, string[] nameBoxSale, uint[]numberBoxSale, uint _price, address _currency,uint _startTime,uint _endTime,uint _maxBuy);
    event BoxCreated(uint _boxID,address addressUser,uint _eventID,string _uriImage, string _name,uint _boxPrice, address _token);
    event createBox(uint _boxID, string _nameBox,uint _quantity,string _uriImage);
    constructor() ERC721("Box", "BOX") {}

    function createBoxList (uint _boxID,string memory _name,uint _quantity,string memory _uriImage) external onlyOwner {
        require(_quantity > 0);
        boxListByID[_boxID] = BoxList(_quantity,0,_name,_uriImage);
        emit createBox(_boxID,_name,_quantity,_uriImage);
    } 
    function addQuantityBox(uint _boxID,uint _amount ) external onlyOwner {
        require(_amount > 0 );
        boxListByID[_boxID].quantity += _amount;
    }
    function checkAmount (uint _sum, uint[] _amountBoxID ) private returns (bool) {
        uint sum = 0;
        for(uint i=0 ; i< _amountBoxID.length; i++){
            sum = sum + _amountBoxID[i];
        }
        if(_sum == sum ){
            return true;
        }
        return false;
        }
    function nameBox (uint[] boxID ) private returns (string[]) {
        string[] memory arrayName;
        for(uint i =0; i< boxID.length; i++){
            arrayName[i] = boxListByID[boxID[i]].nameBox;
        }
        return arrayName;
    }
   function createEvent(
        uint256 _eventID,
        uint[] _boxID,
        uint[] _amountBoxID,
        uint256 _totalSupply,
        uint256 _price,
        address _currency,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _maxBuy,
        uint256 _startID
    ) external onlyOwner {
        require(_boxID.length == _amountBoxID );
        require (checkAmount(_totalSupply,_amountBoxID));
        require(_totalSupply > 0, "Invalid Supply");
        require(_startTime < _endTime, "Invalid time");
        require(_maxBuy > 0, "Need set max buy");
        require(_boxID.length > 0 );
            for(uint i=0;i <_boxID.length; i++){
                boxesByEvent[_eventID][_boxID[i]] = boxListByID[_boxID[i]];
            }
        eventByID[_eventID] = EventInfo(_totalSupply, nameBox(_boxID), _amountBoxID, 0, _price, _currency, _startTime, _endTime, _maxBuy, _startID);
        emit EventCreated(
            _totalSupply,
            nameBox(_boxID),
            _amountBoxID,
            _price,
            _currency,
            _startTime, 
            _endTime,
            _maxBuy,
            _startID
        );
    }
    function _fowardFund(uint256 _amount, address _token) internal {
        if (_token == address(0)) { // native token (BNB)
            (bool isSuccess,) = fundWallet.call{value: _amount}("");
            require(isSuccess, "Transfer failed: gas error");
            return;
        }

        IERC20(_token).transferFrom(msg.sender, fundWallet, _amount);
    }
    function buyBox(uint256 _eventID, uint256 _amount, uint256 _indexBoxList, address _token) public payable {
        EventInfo storage eventInfo = eventByID[_eventID];

        require(_amount > 0 && _amount + userBought[_eventID][msg.sender] <= eventInfo.maxBuy, "Rate limit exceeded");
        require(block.timestamp >= eventInfo.startTime, "Sale has not started");
        require(block.timestamp <= eventInfo.endTime, "Sale has ended");
        require(_token == eventInfo.currency, "Invalid token");
        BoxList storage boxes = boxesByEvent[_eventID][_indexBoxList];

        require(boxes.quantity - boxes.bought >= _amount, "sold out");
        
        uint256 totalFund = eventInfo.boxPrice * _amount;
        if (_token == address(0)) {
            require(totalFund == msg.value, "invalid value");
        }
        
        _fowardFund(totalFund, _token);
        for (uint i = 0; i < _amount; i++) {
            uint256 boxID = eventInfo.boxCount + eventInfo.startID + 1;
            _safeMint(msg.sender, boxID);
            boxByEvent[boxID] = _eventID;
            userBought[_eventID][msg.sender] += 1;
            eventInfo.boxCount += 1;
            emit BoxCreated(boxID, msg.sender, _eventID, boxes.uriImage, boxes.nameBox, eventInfo.boxPrice, eventInfo.currency);
        }

        boxes.bought += _amount;
    }

}
