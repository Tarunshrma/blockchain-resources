// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <0.7.0;

contract StarNotary{
    string public starName;
    address public owner;

    event starClaimed(address _owner);

    constructor() public{
        starName = "TS Star"; 
    }

    function claimStar() external{
        owner = msg.sender;
        emit starClaimed(msg.sender);
    }
}