//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface OpenBoxInterface {  
    function mintNFT(uint _boxID) external returns(uint NftID);
}
 contract Box is ERC721, Ownable {
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
        uint256 startID;
    }
   struct BoxList {
        uint256 quantity;
        uint256 bought;
        string uriImage;
    }
    struct gun {
        uint gunStructure;
        string name;
    }
    struct armor {
        uint armorStructure;
        string name;
    }
    struct knife {
        uint knifeStructure;
        string name;
    }
    address public fundWallet;
    address public addressOpenBox;
    mapping (address => uint ) boxOpened;
    mapping (uint => gun) gunsByID;
    mapping (uint => armor) armorByID;
    mapping (uint => knife ) knifeByID;
    mapping (string => BoxList ) boxListByID;
    mapping (uint => mapping(string => BoxList)) boxesByEvent;
    mapping(uint256 => EventInfo) public eventByID;
    mapping (uint => uint ) boxByEvent;
    mapping (uint => mapping(address => uint)) userBought;
    mapping (uint => address ) itemOwner;
    event EventCreated(uint _totalSupply, string[] nameBoxSale, uint[]numberBoxSale, uint _price, address _currency,uint _startTime,uint _endTime,uint _maxBuy,uint startID);
    event BoxCreated(uint _boxID,address addressUser,uint _eventID,string _uriImage, string _name,uint _boxPrice, address _token);
    event createBox( string _nameBox,uint _quantity,string _uriImage);
    constructor() ERC721("Box", "BOX") {}

    function createBoxList (string[] memory _name,uint[] memory _quantity,string[] memory _uriImage) external onlyOwner {
        require(_name.length == _quantity.length && _name.length == _uriImage.length);
        for(uint i = 0; i < _name.length; i++){
        boxListByID[_name[i]] = BoxList(_quantity[i],0,_uriImage[i]);
        emit createBox(_name[i],_quantity[i],_uriImage[i]);
        }
        
    } 
    function addQuantityBox(string memory _nameBox,uint _amount ) external onlyOwner {
        require(_amount > 0 );
        boxListByID[_nameBox].quantity += _amount;
    }
    function checkAmount(uint _sum, uint[] memory _amountBoxID ) pure private returns(bool) {
        uint sum = 0;
        for(uint i=0 ; i< _amountBoxID.length; i++){
            sum = sum + _amountBoxID[i];
        }
        if(_sum == sum ){
            return true;
        }
        return false;
        }
   function createEvent(
        uint256 _eventID,
        string[] memory _nameBox,
        uint[] memory _amountBoxID,
        uint256 _totalSupply,
        uint256 _price,
        address _currency,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _maxBuy,
        uint256 _startID
    ) external onlyOwner {
        require(_nameBox.length == _amountBoxID.length );
        require (checkAmount(_totalSupply,_amountBoxID));
        require(_totalSupply > 0, "Invalid Supply");
        require(_startTime < _endTime, "Invalid time");
        require(_maxBuy > 0, "Need set max buy");
        require(_nameBox.length > 0 );
            for(uint i=0;i <_nameBox.length; i++){
                boxesByEvent[_eventID][_nameBox[i]] = boxListByID[_nameBox[i]];
            }
        eventByID[_eventID] = EventInfo(_totalSupply, _nameBox, _amountBoxID, 0, _price, _currency, _startTime, _endTime, _maxBuy, _startID);
        emit EventCreated(
            _totalSupply,
            _nameBox,
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
    function buyBox(uint256 _eventID, uint256 _amount,string memory _nameBox, address _token) public payable {
        EventInfo storage eventInfo = eventByID[_eventID];

        require(_amount > 0 && _amount + userBought[_eventID][msg.sender] <= eventInfo.maxBuy, "Rate limit exceeded");
        require(block.timestamp >= eventInfo.startTime, "Sale has not started");
        require(block.timestamp <= eventInfo.endTime, "Sale has ended");
        require(_token == eventInfo.currency, "Invalid token");
        BoxList storage boxes = boxesByEvent[_eventID][_nameBox];

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
            emit BoxCreated(boxID, msg.sender, _eventID, boxes.uriImage, _nameBox, eventInfo.boxPrice, eventInfo.currency);
        }

        boxes.bought += _amount;
    }
    uint randNonce = 0;
    function ranDom (uint _modulus) internal returns(uint) {
        randNonce++;
        return uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % _modulus;
    }

    OpenBoxInterface open;

    function setOpenBoxContractAddress (address _ckAddress) external onlyOwner {
        open = OpenBoxInterface(_ckAddress);
    }

    function openBox (uint boxID ) external {
        require(ownerOf(boxID) == msg.sender );
        uint random = ranDom (100);
        if(random > 90 ){
            console.log ("there's nothing in the box");
        }
        
        if(random <= 30 ){
            (uint newID) = open.mintNFT(boxID);
            uint gunStructure = uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,boxID))) % (10 ** 49);
            gunsByID[newID] = gun(gunStructure,"gun");
            boxOpened[msg.sender] += 1;
        }
        if(random > 30 && random <=60 ){
            (uint newID) = open.mintNFT(boxID);
            uint armorStructure = uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,boxID))) % (10 ** 55);
            armorByID[newID] = armor(armorStructure,"armor");
            boxOpened[msg.sender] += 1;
        }
        if(random > 60 && random <=90 ){
            (uint newID) = open.mintNFT(boxID);
            uint knifeStructure = uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,boxID))) % (10 ** 55);
            knifeByID[newID] = knife(knifeStructure,"knife");
            boxOpened[msg.sender] += 1;

        }
       _burn(boxID);
    }

}
