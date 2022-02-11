//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

 contract Box is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    mapping (address => uint[] ) boxOwner;
    event mintBox(uint _sum123,uint _timeBegin, uint _timeEnd, uint _price,string _sellingUint, uint _limitBox );
    
    constructor() ERC721("Box", "BOX") {}
    uint private _timeBegin; 
    uint private _timeEnd;
    uint private _price;
    string private _sellingUint;
    uint private _limitBox;
    function _mintNFT(address recipient, uint amountToMint )
        private 
        
    {
        for(uint i = 0; i < amountToMint; i++){
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        boxOwner[recipient].push(newItemId);
        _mint(recipient, newItemId);
    
    }
        
    }

    function setUp ( uint timeEnd, uint price,string memory sellingUint,uint limitBox) external onlyOwner {
        _timeBegin = block.timestamp;
        _timeEnd = timeEnd * 86400 + block.timestamp;
        _price = price;
        _sellingUint = sellingUint;
        _limitBox = limitBox;
        
    }
    function saleBox(uint sum,address recipient) external onlyOwner {
        require(sum <= _limitBox);
        require(_timeBegin <= block.timestamp &&  block.timestamp <= _timeEnd);
        _mintNFT(recipient,sum );
        if(sum == _limitBox) {
            emit mintBox(sum,_timeBegin,_timeEnd, _price,_sellingUint,_limitBox);
        }

    }

}
