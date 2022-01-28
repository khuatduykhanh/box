// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./erc721.sol";
import "./box.sol";

contract BoxSale is ERC721,Box {

   function balanceOf(address _owner) external view override returns (uint[] memory) {
       return allBoxToOwner[_owner];
    }
    function ownerOf(uint256 _tokenId) external view override returns (address) {
        return boxToOwner[_tokenId];
    }
    function transferFrom(address _from, address _to,uint _sumBox,uint _price,string memory _nameCoin) external override payable {
        require(_sumBox <= limitBox && _sumBox <= boxToCount[ _from]);
        uint a;
        for (uint16 i = 0; i < _sumBox; i++) {
           if( block.timestamp >= BOX[idToIndexArry[allBoxToOwner[_from][i]]].timesale && block.timestamp <= BOX[idToIndexArry[allBoxToOwner[_from][i]]].timeendsale) {
           a = allBoxToOwner[_from][i];
           allBoxToOwner[_to].push(a);
           boxToCount[_from]--;
           boxToCount[_to]--;
           boxToOwner[a] = _to;
           delete allBoxToOwner[_from][i];
        } else {
            console.log("chua den ngay ban");
            }
        }
        if(boxToCount[_from] == 0 ){
         emit Transfer(_from, _to, _sumBox, _price, _nameCoin, limitBox);
        } else {
            if(_sumBox == limitBox) {
                emit Transfer(_from, _to, _sumBox, _price, _nameCoin, limitBox);
            }

        }  
  }




}