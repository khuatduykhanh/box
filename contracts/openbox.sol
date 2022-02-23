//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
contract OpenBox is ERC721 {
    using Counters for Counters.Counter; 
    Counters.Counter private _itemID;  
    constructor() ERC721("Battle", "GAN") {}
    function mintNFT(uint boxID) external returns(uint) {
        _itemID.increment();
        uint256 newItemId = _itemID.current();
       _safeMint(msg.sender, newItemId);
       return newItemId;
    }
    
}