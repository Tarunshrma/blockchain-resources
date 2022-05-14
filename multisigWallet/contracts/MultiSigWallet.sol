// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract MultiSigWallet {

  //Define Events
  event Deposit(address indexed sender, uint amount);
  event Submit(uint indexed txnId);
  event Approve(address indexed owner, uint indexed txnId);
  event Revoke(address indexed owner, uint indexed txnId);
  event Execute(uint indexed txnId);

  struct Transaction{
    address to;
    uint value;
    bytes data;
    bool executed;
  }

  //STORAGE VARIABLES
  //Approvers who can approve the transaction
  address[] public approvers;
  mapping(address => bool) public isApprover;
  
  //PRIVATE VARIABLES
  //Min. number of approval req. to execute the transaction
  uint private minApprovalReq;

  constructor(address[] memory _approvers, uint _minApprovalRequired) public {
    require(_approvers.length > 0, "Approvers not provided");
    require(_minApprovalRequired <= _approvers.length, "Min approval whould be less or equal to approvers count");
    
    for(uint i = 0; i<_approvers.length; i++){
        address approver = _approvers[i];
        require(approver != address(0), "Invalid approver address");
        require(!isApprover[approver], "Duplicate owners provided");

        isApprover[approver] = true;
        approvers.push(approver);
    }
    minApprovalReq = _minApprovalRequired;
  }

  
}
