//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface OpenBoxInterface {  
    function mintNFT (address _to, uint256 _nftID) external ;
    function balanceOf(address owner) external returns (uint256);
    function ownerOf(uint256 tokenId) external returns (address);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external ;
}
interface RanDomNumber {
    function getEventRandomNumber(uint256 _eventId) external;
}

contract Box is ERC721Enumerable, Ownable{
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
        uint256 timeOpenBox;
    }
   struct BoxList {
        uint256 quantity;
        uint256 bought;
        string uriImage;
    }
     struct InforNFT {
        string name;
        uint256 level;
        uint256 gen;

    }
    struct InforSaleNFT {
        uint256 price;
        uint256 startTime;
        uint256 endTime;
    }
    mapping (uint256 => InforSaleNFT) saleNFTByID;
    mapping (uint256 => InforNFT) NFTByID;
    mapping (uint256 => uint256 ) internal luckyNumber;
    address public fundWallet;
    mapping (uint => uint) internal eventRandom;
    mapping (address => uint ) boxOpened;
    mapping (string => BoxList ) boxListByID;
    mapping (uint => mapping(string => BoxList)) boxesByEvent;
    mapping(uint256 => EventInfo) public eventByID;
    mapping (uint => uint ) boxByEvent;
    mapping (uint => mapping(address => uint)) userBought;
    event EventCreated(uint _totalSupply, string[] nameBoxSale, uint[]numberBoxSale, uint _price, address _currency,uint _startTime,uint _endTime,uint _maxBuy,uint startID);
    event BoxCreated(uint _boxID,address addressUser,uint _eventID,string _uriImage, string _name,uint _boxPrice, address _token);
    event createBox( string _nameBox,uint _quantity,string _uriImage);
     event EventSaleNFT (uint256 _ID,uint256 _price, uint256 _startTime, uint256 _endTime);
    event EventBuyNFT (address _from,address _to,uint256 _nftID,uint256 _price);
    constructor() ERC721("Box", "BOX") {}
    
    function setRandomNumber(uint eventId, uint ranDom) external {
        eventRandom[eventId] = ranDom ;
    }
    uint256 randNonce = 0;
    function randMod(uint _NftID) internal returns(uint) {
        randNonce = randNonce++;
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce,_NftID))) % 100000000;
    }
    uint256 randNonce1 = 0;
    function randMod1(uint _to,uint _from) internal returns(uint) {
        randNonce1 = randNonce1++;
        return _from - (uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce1,_to,_from))) % _to);
    }

    function createBoxList (string[] memory _name,uint[] memory _quantity,string[] memory _uriImage) external onlyOwner {
        require(_name.length == _quantity.length && _name.length == _uriImage.length);
        for(uint i = 0; i < _name.length; i++){
        boxListByID[_name[i]] = BoxList(_quantity[i],0,_uriImage[i]);
        // console.log("Name Box %s is %s", i,_name[i] );
        // console.log("Amount Box %s is %s", i,_quantity[i] );
        //  console.log("URI Box %s is %s", i,_uriImage[i] );
        emit createBox(_name[i],_quantity[i],_uriImage[i]);
        }
        
    } 
    function addQuantityBox(string memory _nameBox,uint _amount ) external onlyOwner {
        require(_amount > 0 );
        boxListByID[_nameBox].quantity += _amount;
        console.log("khanhdz");
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
    RanDomNumber random;

    function setRanDomContractAddress (address _ckAddress) external onlyOwner {
        random = RanDomNumber(_ckAddress);
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
        uint256 _startID,
        uint256 _timeOpenBox
    ) external onlyOwner {
        require(_nameBox.length == _amountBoxID.length ,"Invalid");
        require (checkAmount(_totalSupply,_amountBoxID), "Invalid");
        require(_totalSupply > 0, "Invalid Supply");
        require(_startTime < _endTime, "Invalid time");
        require(_maxBuy > 0, "Need set max buy");
        require(_nameBox.length > 0 );
        luckyNumber[_eventID] = randMod1(_startID+1,_totalSupply);
        for(uint i=0;i <_nameBox.length; i++){
            boxesByEvent[_eventID][_nameBox[i]] = boxListByID[_nameBox[i]];
            //console.log(boxesByEvent[_eventID][_nameBox[i]]);
        }
        random.getEventRandomNumber(_eventID);
        //console.log(random.getEventRandomNumber(_eventID));
        eventByID[_eventID] = EventInfo(_totalSupply, _nameBox, _amountBoxID, 0, _price, _currency, _startTime, _endTime, _maxBuy, _startID,_timeOpenBox);
        //console.log(eventByID[_eventID]);
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

    OpenBoxInterface open;

    function setOpenBoxContractAddress (address _ckAddress) external onlyOwner {
        open = OpenBoxInterface(_ckAddress);
    }

    // function openBox (uint[] memory boxID ) external {
    //     for(uint i =0; i < boxID.length;i++){
    //     require(ownerOf(boxID[i]) == msg.sender );
    //     EventInfo memory eventInfo =  eventByID[boxByEvent[boxID[i]]];
    //     uint rand = eventRandom[boxByEvent[boxID[i]]];
    //     uint256 nftId = (boxID[i] + rand) % eventInfo.totalSupply + eventInfo.startID;
    //     open.mintNFT(msg.sender,nftId);
    //     boxOpened[msg.sender] += 1;
    //    _burn(boxID[i]);
    // }
    // }
    function openBox(uint256 _boxId,uint256 _eventID) public {
        require(ownerOf(_boxId) == msg.sender );
        require(boxByEvent[_boxId] == _eventID );
        EventInfo memory eventInfo =  eventByID[boxByEvent[_boxId]];
        uint rand = eventRandom[boxByEvent[_boxId]];
        uint256 nftId = (_boxId + rand) % eventInfo.totalSupply + eventInfo.startID;
        uint gens = randMod(nftId);
        if(nftId == luckyNumber[_eventID]) {
            NFTByID[nftId] = InforNFT('',5,gens);
        }
        NFTByID[nftId] = InforNFT('',1,gens);
        open.mintNFT(msg.sender,nftId);
        boxOpened[msg.sender] += 1;
       _burn(_boxId);
    }

    function openAllBox(uint256 _eventID) public {
        uint256 userBox = balanceOf(msg.sender);
        require(userBox > 0, "User not owner of any box");
        for (uint256 index = 0; index < userBox; index++) {
            uint256 currentBalance = balanceOf(msg.sender);
            if (currentBalance == 0) {
                continue;
            }
            uint256 boxId = tokenOfOwnerByIndex(msg.sender, currentBalance - 1);
            if (boxByEvent[boxId] == _eventID) {
                openBox(boxId, _eventID);
            }
        }
    }

    function saleNFT(uint256 _NftID,uint256 _startTime,uint256 _endTime,uint256 _price) external {
        require(_startTime < _endTime);
        require(open.ownerOf(_NftID) == msg.sender);
        saleNFTByID[_NftID] = InforSaleNFT(_price,_startTime,_endTime);
        emit EventSaleNFT(_NftID,_price,_startTime,_endTime);
    }

    function BuyNft (uint256 _NftID,address _token) public payable {
        InforSaleNFT memory inforNFT = saleNFTByID[_NftID];
        address from = open.ownerOf(_NftID);
        require(block.timestamp >= inforNFT.startTime, "Sale has not started");
        require(block.timestamp <= inforNFT.endTime, "Sale has ended");
        if (_token == address(0)) {
            require(inforNFT.price == msg.value, "invalid value");
        }
        if (_token == address(0)) { // native token (BNB)
            (bool isSuccess,) = from.call{value: inforNFT.price}("");
            require(isSuccess, "Transfer failed: gas error");
        }
         IERC20(_token).transferFrom(msg.sender,from, inforNFT.price);

       open.safeTransferFrom(from,msg.sender,_NftID); 
       emit EventBuyNFT(from,msg.sender,_NftID,inforNFT.price);
    }
     
    function levelUp (uint256 _NftID,address _token) public payable {
        require(open.ownerOf(_NftID) == msg.sender);
        InforNFT memory inforNft = NFTByID[_NftID];
        if (_token == address(0)) {
            require(10000000000000000 == msg.value, "invalid value");
        }
        _fowardFund(10000000000000000, _token);
        inforNft.level++;
    }
    function setUpName (uint256 _NftID,address _token,string memory _nameNFT) public payable {
        require(open.ownerOf(_NftID) == msg.sender);
        InforNFT memory inforNft = NFTByID[_NftID];
        if (_token == address(0)) {
            require(100000000000000 == msg.value, "invalid value");
        }
        _fowardFund(100000000000000, _token);
        inforNft.name = _nameNFT;
    }
 }