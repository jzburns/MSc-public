// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;

contract PlayerStateManagement {
  /**
   * @dev declares the blockchain variable "numberOfCalls"
   */

   // A uint is an unsigned integer in the range 0 to 2^64 -1
   uint public numberOfCalls = 0;

   // A mapping is a K:V pair dictionart (similar to python dict)
   mapping(address => uint) public playerGameSate;
  

  // Here are some global variables available to all contracts
  function showBlockNumber () external view returns (uint) {
    return block.number;
  }

  // Here are some global variables available to all contracts
  function showCallerAddress () external view returns (address) {
    return msg.sender;
  }

  // Payable functions in Solidity are functions that let a smart contract accept Ether
  function updatePlayerState (uint newState) external payable {

    // f we had a smart contract where we needed to keep track of who deposited which ether, we might keep track of that in storage:
    playerGameSate[msg.sender] += newState;
    numberOfCalls++;
  
  }

}
