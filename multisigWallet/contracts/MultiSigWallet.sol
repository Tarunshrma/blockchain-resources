// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract MultiSigWallet {

  //Define Events
  event Deposit(address indexed sender, uint amount, uint currentBalance);
  event TransactionSubmitted(bytes32 indexed txnId);
  event Approve(address indexed owner, uint indexed txnId);
  event Revoke(address indexed owner, uint indexed txnId);
  event Execute(uint indexed txnId);

  struct Transaction{
    bytes32 txnId;
    address to;
    uint value;
    bytes data;
    bool executed;
    uint approvals; //Current approvals
  }

  //STORAGE VARIABLES
  //Approvers who can approve the transaction
  address[] public approvers;
  mapping(address => bool) public isApprover;
  mapping (bytes32 => Transaction) pendingTransactions;
  //This mapping will store if given transaction is approved by approver
  mapping (bytes32 => mapping (address => bool)) isTransactionApprovedBy;
  
  //PRIVATE VARIABLES
  //Min. number of approval req. to execute the transaction
  uint private minApprovalReq;

  //Modifiers
  modifier onlyApprover(){
    require(isApprover[msg.sender], "Only approver can perform this operation");
    _;
  }

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

  receive() external payable {
    emit Deposit(msg.sender, msg.value, address(this).balance);
  }

  function submitTransaction(address _toParty,
                             uint _value,
                             bytes calldata _data
                             ) external onlyApprover
  {
    bytes32 _txnId = keccak256(abi.encodePacked(_toParty, _value, _data));
    pendingTransactions[_txnId] = Transaction({
      txnId: _txnId,
      to   : _toParty,
      value: _value,
      data: _data,
      executed: false,
      approvals: 0 
    });

    emit TransactionSubmitted(_txnId);
  }

}
