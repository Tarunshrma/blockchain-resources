// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract MultiSigWallet {

  //Define Events
  event Deposit(address indexed sender, uint amount, uint currentBalance);
  event TransactionSubmitted(bytes32 indexed txnId);
  event TrsanctionApproved(address indexed approver, bytes32 indexed txnId);
  event TransactionReadyForExecution(bytes32 indexed txnId);
  event TransactionExecuted(bytes32 indexed txnId);

  struct Transaction{
    bytes32 txnId;
    address to;
    uint value;
    bytes data;
    uint approvals; //Current approvals
  }

  //STORAGE VARIABLES
  //Approvers who can approve the transaction
  address[] public approvers;
  mapping(address => bool) public isApprover;
  mapping (bytes32 => Transaction) pendingTransactions;
  mapping (bytes32 => Transaction) readyTransaction;
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

  modifier transactionShouldExist(bytes32 _txnid){
    require(pendingTransactions[_txnid].txnId == _txnid, "Transaction not exist.");
    _;
  }

  
  modifier transactionShouldExistInReadyState(bytes32 _txnid){
    require(readyTransaction[_txnid].txnId == _txnid, "Transaction should be in ready state.");
    _;
  }

  modifier notApprovedBy(bytes32 _txnid){
    require(!isTransactionApprovedBy[_txnid][msg.sender], "Transaction already approved.");
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
      approvals: 0 
    });

    emit TransactionSubmitted(_txnId);
  }

  //Only valid approver
  //transaction should exist
  //transaction not already approved by current approver
  function approveTransaction(bytes32 _txnId) external onlyApprover 
                                                       transactionShouldExist(_txnId)
                                                       notApprovedBy(_txnId){
      Transaction memory _txn = pendingTransactions[_txnId];
      _txn.approvals++;
      isTransactionApprovedBy[_txnId][msg.sender] = true;

      emit TrsanctionApproved(msg.sender, _txnId);

      if(_txn.approvals >= minApprovalReq){
        //Tranasction is ready for execution as enough approval found.
        readyTransaction[_txnId] = _txn;
        delete pendingTransactions[_txnId]; 
        emit TransactionReadyForExecution(_txnId);
      }
  }

  function executeTrancation(bytes32 _txnId) external 
                                              onlyApprover
                                              transactionShouldExistInReadyState(_txnId)

  {
      Transaction memory _txn = readyTransaction[_txnId];
      (bool success, ) = _txn.to.call{value: _txn.value}(_txn.data);

      require(success, "Transaction failed.");
      delete readyTransaction[_txnId];
      emit TransactionExecuted(_txnId);
  }

}
