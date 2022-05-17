// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../node_modules/@openzeppelin/contracts/interfaces/IERC721.sol";

contract EnglishAuction {
  
  event AuctionStarted();
  event BidPlaced(address indexed bidder, uint indexed amount);
  event AuctionEnded(address indexed auctionWinner, uint indexed highestBid);

  enum AuctionState {NotStarted, Started, Ended }

  //Original owner of NFT
  address public originalOwner;
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
    originalOwner = msg.sender;
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

}
