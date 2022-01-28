// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface ERC721 {
  event Transfer(address indexed _from, address indexed _to,uint _sumBox, uint _price,string _nameCoin,uint _boxMax);
  event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

  function balanceOf(address _owner) external view returns (uint[] memory);
  function ownerOf(uint256 _tokenId) external view returns (address);
  function transferFrom(address _from, address _to,uint _sumBox,uint _price,string memory _nameCoin) external payable;
}
