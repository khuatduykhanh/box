//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./ownable.sol";

contract Box is Ownable {
    
    uint idModulus = 10 ** 56;
    uint limitBox;
    uint random = 0 ;
    struct box {
        uint id;
        string name;
        uint timesale;
        uint timeendsale;

    }
    mapping(address => uint )  boxToCount;
    mapping(uint => address) public boxToOwner;
    mapping (address=> uint[]) allBoxToOwner;
    mapping (uint => uint) idToIndexArry;
    event newbox(uint _id,string _name);
    box[] public BOX;

    function mint (string memory _name,string memory _boxname) public {
       uint id = uint(keccak256(abi.encodePacked(block.timestamp,_name,random))) % idModulus;
       BOX.push(box(id,_boxname,0,0));
       idToIndexArry[id] = random;
       boxToCount[msg.sender]++;
       boxToOwner[id] = msg.sender;
       allBoxToOwner[msg.sender].push(id);
       random++;
       emit newbox(id,_boxname);
    }

    function quantityLimitBox(uint _limitBox) external onlyOwner {
        limitBox = _limitBox;
    }


    function setUpTime(uint _daySale,uint _hourSale,uint _dayEndSale,uint _hourEndSale ) external {
        for (uint16 i = 0; i < allBoxToOwner[msg.sender].length; i++) {
            BOX[idToIndexArry[allBoxToOwner[msg.sender][i]]].timesale = block.timestamp + _daySale * 1 days + _hourSale * 1 hours;
            BOX[idToIndexArry[allBoxToOwner[msg.sender][i]]].timeendsale = block.timestamp + _dayEndSale * 1 days + _hourEndSale * 1 hours;
        }

    }

}
