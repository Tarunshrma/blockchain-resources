// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../node_modules/@openzeppelin/contracts/interfaces/IERC721.sol";

contract EnglishAuction {
  
  event AuctionStarted();
  event BidPlaced(address indexed bidder, uint indexed amount);
  event AuctionEnded(address indexed auctionWinner, uint indexed highestBid);

  //Original owner of NFT
  address public originalOwner;
  //Current highest bid
  uint public heighestBid;

  IERC721 public nftUnderAuction;
  uint public nftId;


  constructor(uint _initialBid, address _nftAddress, uint _nftId) public {
    originalOwner = msg.sender;
    heighestBid = _initialBid;

    require(_nftAddress != address(0), "NFT address is invalid!");
    nftUnderAuction = IERC721(_nftAddress); 
    nftId = _nftId;
  }

  
}
