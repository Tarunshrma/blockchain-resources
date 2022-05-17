// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../node_modules/@openzeppelin/contracts/interfaces/IERC721.sol";

contract EnglishAuction {
  
  event AuctionStarted();
  event BidPlaced(address indexed bidder, uint indexed amount);
  event WithDrawnFromAuction(address indexed bidder, uint indexed amount);
  event AuctionEnded(address indexed auctionWinner, uint indexed highestBid);

  enum AuctionState {NotStarted, Started, Ended }

  //Original owner of NFT
  address payable public originalOwner;
  //Current highest bid
  uint public heighestBid;
  address public highestBidder;
  uint public auctionEndDate;

  IERC721 public nftUnderAuction;
  uint public nftId;
  AuctionState public auctionState = AuctionState.NotStarted;

  mapping (address => uint) bidders;


  modifier onlyNFTOwner(){
    require(msg.sender == originalOwner, "Not authorized to start the auction");
  }

  constructor(uint _initialBid, address _nftAddress, uint _nftId) public {
    originalOwner = payable(msg.sender);
    heighestBid = _initialBid;

    require(_nftAddress != address(0), "NFT address is invalid!");
    nftUnderAuction = IERC721(_nftAddress); 
    nftId = _nftId;
  }

  function startAuction() external onlyNFTOwner{
    require(auctionState == AuctionState.NotStarted, "Auction is not active.");
    auctionEndDate = block.timestamp + 7 days;
    auctionState = AuctionState.Started;

    nftUnderAuction.transferFrom(msg.sender, address(this), nftId);

    emit AuctionStarted();
  }

  function placeBid() external payable{
    require(auctionState == AuctionState.Started, "Auction is not active.");
    require(block.timestamp < auctionEndDate, "Auction end date passed");
    require(msg.value > heighestBid, "Your bid is not sufficient");

    heighestBid = msg.value;
    bidders[msg.sender] = bidders[msg.sender] + msg.value;
    highestBidder = msg.sender;

    emit BidPlaced(msg.sender, msg.value);
  }

  //Can not withdraw from an active auction
  function withdrawFromAuction() external{
    require(auctionState == AuctionState.Ended, "Can not withdraw from an active auction.");
    require(bidders[msg.sender] > 0, "You have not bid yet.");

    uint balance = bidders[msg.sender];
    bidders[msg.sender] = 0;
    payable(msg.sender).transfer(balance);

    emit WithDrawnFromAuction(msg.sender, balance);
  }

  //Finish the auction by transferring the NFT to highest bidder.
  //mark the Bid as stopped, check time should have been elapsed for Auction window
  //Anyone who has bid can call endAuction.
  function endAuction() external{
    require(auctionState == AuctionState.Started, "Auction is not active.");
    require(block.timestamp >= auctionEndDate, "Auction is still active and can not be ended before it expires.");
    require(bidders[msg.sender] > 0, "You are not authorozed to end the Auction.");
    
    //no-one bid to auction :-( ). return the nft to owner.
    if(highestBidder == address(0)){
      nftUnderAuction.safeTransferFrom(address(this), originalOwner, nftId, "");
    }else{
      //Set the highest bidder balance to 0
      auctionState = AuctionState.Ended;
      bidders[highestBidder] = 0;
      originalOwner.transfer(heighestBid);
      nftUnderAuction.safeTransferFrom(address(this), highestBidder, nftId, "");
    }

    emit AuctionEnded(highestBidder, heighestBid);


  }

}
