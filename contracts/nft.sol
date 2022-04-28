//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

import "./box.sol";

contract NFT is  Box {
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
    event EventSaleNFT (uint256 _ID,uint256 _price, uint256 _startTime, uint256 _endTime);

    
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

    function BuyNft (uint256 _NftID,address _from,address _token) public payable {
        InforSaleNFT memory inforNFT = saleNFTByID[_NftID];
        require(block.timestamp >= inforNFT.startTime, "Sale has not started");
        require(block.timestamp <= inforNFT.endTime, "Sale has ended");
        if (_token == address(0)) {
            require(inforNFT.price == msg.value, "invalid value");
        }
        if (_token == address(0)) { // native token (BNB)
            (bool isSuccess,) = _from.call{value: inforNFT.price}("");
            require(isSuccess, "Transfer failed: gas error");
        }
         IERC20(_token).transferFrom(msg.sender, _from, inforNFT.price);

       open.safeTransferFrom(_from,msg.sender,_NftID); 

    }
}