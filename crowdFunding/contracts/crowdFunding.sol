// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../node_modules/@openzeppelin/contracts/interfaces/IERC20.sol";

//TODO: Contract can be optimized.. this is just the draft version
contract CrowdFunding {
  event CampaignLaunched(uint id, address creator, uint goal, uint start, uint end);
  event Pledged(address indexed by, uint amount);
  event UnPledged(address indexed by, uint amount);
  event Claim(address indexed by, uint amount);
  event Refund(address indexed by, uint amount);

  error  CampaignGoalIsNotSufficient();
  error  CampaignStartTimeIsInvalid();
  error  CampaignEndTimeIsInvalid();
  error  CampainDoesNotExist();
  error  CampainNotStarted();
  error  CampainEnded();
  error CampainNotEnded();
  error InsufficiantAmount();
  error CapmaignNotSuccefull();
  error CapmaignAlreadyClaimed();
  error NotAuthorizedToClaim();


  struct Campaign{
    uint id;
    address creator;
    uint goal;
    uint pledged;
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
      revert CampainNotStarted();
    }
    if(_endAt < _startAt){
      revert CampaignEndTimeIsInvalid();
    }

    campignId++;
    campaigns[campignId] = Campaign({
      id : campignId,
      creator: msg.sender,
      goal: _goal,
      pledged: 0,
      startAt: _startAt,
      endAt: _endAt,
      claimed: false
    });

    emit CampaignLaunched(campignId,msg.sender ,_goal, _startAt, _endAt);
  }

  function pledge(uint _campaignId, uint _amount) external{
    Campaign storage campaign = campaigns[_campaignId];
    if(campaign.id == 0){
      revert CampainDoesNotExist();
    }
    if(block.timestamp <= campaign.startAt){
      revert CampainNotStarted();
    }

    if(block.timestamp > campaign.endAt){
      revert CampainEnded();
    }

    campaign.pledged += _amount;
    pledged[campaign.id][msg.sender] +=  _amount;
    token.transferFrom(msg.sender, address(this), _amount);
    emit Pledged(msg.sender, _amount);
  }

  function unPledge(uint _campaignId, uint _amount) external{
    
    Campaign storage campaign = campaigns[_campaignId];
    if(campaign.id == 0){
      revert CampainDoesNotExist();
    }
    if(block.timestamp <= campaign.startAt){
      revert CampainNotStarted();
    }

    if(block.timestamp > campaign.endAt){
      revert CampainEnded();
    }

    if(pledged[_campaignId][msg.sender] >= _amount){
      revert InsufficiantAmount();
    }

    pledged[campaign.id][msg.sender] +=  _amount;
    campaign.pledged -= _amount;
    token.transfer(msg.sender, _amount);
    emit UnPledged(msg.sender, _amount);
  }

  function claim(uint _campaignId) external{
    Campaign storage campaign = campaigns[_campaignId];
    if(block.timestamp < campaign.endAt){
      revert CampainEnded();
    }
    if(campaign.pledged < campaign.goal){
      revert CapmaignNotSuccefull();
    }
    if(msg.sender == campaign.creator){
      revert NotAuthorizedToClaim();
    }

    campaign.claimed = true;
    token.transfer(msg.sender, campaign.pledged);
    emit Claim(msg.sender, campaign.pledged);
  }

  function refund(uint _campaignId) external{
    Campaign storage campaign = campaigns[_campaignId];
    if(block.timestamp < campaign.endAt){
      revert CampainNotEnded();
    }
    if(campaign.claimed){
      revert CapmaignAlreadyClaimed();
    }
    if(campaign.pledged < campaign.goal){
      revert CapmaignNotSuccefull();
    }

    uint balance = pledged[_campaignId][msg.sender];
    pledged[_campaignId][msg.sender] = 0;
    payable(msg.sender).transfer(balance);

    emit Refund(msg.sender, balance);

  }





}
