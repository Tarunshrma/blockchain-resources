// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../node_modules/@openzeppelin/contracts/interfaces/IERC20.sol";

contract CrowdFunding {
  event CampaignLaunched(uint id, address creator, uint goal, uint start, uint end);
  event Pledged(address indexed by, uint amount);
  event UnPledged(address indexed by, uint amount);
  event Claim(address indexed by, uint amount);
  event Refund(address indexed by, uint amount);

  error  CampaignGoalIsNotSufficient();
  error  CampaignStartTimeIsInvalid();
  error  CampaignEndTimeIsInvalid();

  struct Campaign{
    uint id;
    address creator;
    uint goal;
    uint startAt;
    uint endAt;
    bool claimed;
  }

  mapping (uint => Campaign) public campaigns;
  mapping (uint => mapping (address => uint)) public pledged;

  uint private campignId = 0;
  IERC20 public immutable token;

  constructor(address _tokenAddress) public {
    token = IERC20(_tokenAddress);
  }

  function launched(uint _goal, uint _startAt, uint _endAt) external{
    if(_goal <=0){
      revert CampaignGoalIsNotSufficient();
    }
    if(_startAt < block.timestamp){
      revert CampaignStartTimeIsInvalid();
    }
    if(_endAt < _startAt){
      revert CampaignEndTimeIsInvalid();
    }

    campignId++;
    campaigns[campignId] = Campaign({
      id : campignId,
      creator: msg.sender,
      goal: _goal,
      startAt: _startAt,
      endAt: _endAt,
      claimed: false
    });

    emit CampaignLaunched(campignId,msg.sender ,_goal, _startAt, _endAt);
  }

  




}
