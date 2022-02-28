//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MyToken is ERC721, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(address addressBox ) ERC721("Battle", "GAN") {
        _grantRole(MINTER_ROLE, addressBox);
    }

    function mintNFT (address to, uint256 nftID) public  {
        require(hasRole(MINTER_ROLE, msg.sender));
        _safeMint(to, nftID);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}