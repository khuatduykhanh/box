//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
 * PLEASE DO NOT USE THIS CODE IN PRODUCTION.
 */

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */
 
interface IEpicWarBox {
    function setRandomNumber(uint eventId, uint ranDom) external;
}

contract RandomNumberConsumer is VRFConsumerBase, AccessControl{
    
    bytes32 internal keyHash;
    uint256 internal fee;
    
    uint256 public randomResult;
    mapping (bytes32 => uint256 ) reqToEvent;
    address boxContract;
    bytes32 public constant RANDOM_ROLE = keccak256("RANDOM_ROLE");
    event RequestRandomNumber(bytes32 _requestId,uint256 _eventId);
    event ReceiveRandomNumber(bytes32 _requestId,uint256 _eventId,uint256 _randomness);
    
    /**
     * Constructor inherits VRFConsumerBase
     * 
     * Network: Kovan
     * Chainlink VRF Coordinator address: 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9
     * LINK token address:                0xa36085F69e2889c224210F603D836748e7dC0088
     * Key Hash: 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4
     */
    constructor(address _boxContract) 
        VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
            0xa36085F69e2889c224210F603D836748e7dC0088 // LINK Token
        )
    {
        keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)
        boxContract = _boxContract;
        _grantRole(RANDOM_ROLE, _boxContract);
    }

    function getEventRandomNumber(uint256 _eventId) external onlyRole(RANDOM_ROLE) {
        require(hasRole(RANDOM_ROLE, msg.sender));
        require(LINK.balanceOf(address(this)) >= fee, "Contract not enough LINK to pay fee");
        bytes32 requestId = requestRandomness(keyHash, fee);
        reqToEvent[requestId] = _eventId;
        emit RequestRandomNumber(requestId, _eventId);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        uint256 eventId = reqToEvent[requestId];
        IEpicWarBox(boxContract).setRandomNumber(eventId, randomness);
        emit ReceiveRandomNumber(requestId, eventId, randomness);
    }
}