// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract nftMarketPlace is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    Counters.Counter private _tokenSold;

    uint256 private listingPrice;
    uint256 private newTokenId;
    address payable owner;

    mapping(uint256 => MarketItem) private idMarketItem;
    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }
    event idMarketItemCreated(
        uint256 indexed tokenid,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );
    modifier onlyOwner() {
        require(owner == (msg.sender), "you are not the owner");
        _;
    }

    constructor() ERC721("Watson Meta Token", "WMT") {
        owner == payable(msg.sender);
    }

    function updateListingPrice(uint256 _listingPrice)
        public
        payable
        onlyOwner
    {
        listingPrice = _listingPrice;
    }

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    function createToken(string memory tokenURI, uint256 price)
        public
        payable
        returns (uint256)
    {
        _tokenIds.increment();

        newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        createdMarketItem(newTokenId, price);

        return newTokenId;
    }

    function createdMarketItem(uint256 tokenId, uint256 price) privare {
        require(price > 0 ,"At least cost 1 token");
        require (msg.valus == listingPrice,"price must equal to listing price");

        idMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            sold
        )

        _transfer(msg.sender,address(this),tokenId);

        emit idMarketItemCreated(tokenId,payable(msg.sender),payable(address(this)),price,sold);
    }

    function reSellToken(uint256 tokenId,uint256 price) public payable{
        require(idMarketItem[tokenId].owner == msg.sender,"you are not the owner");
        require(listingPrice == price,"price must be listingPrice");

        idMarketItem[tokenId].sold = false;
        idMarketItem[tokenId].seller = payable(msg.sender);
        idMarketItem[tokenId].owner = payable(address(this));
        idMarketItem[tokenId].price = price;

        _itemsold.decrement();

        _transfer(msg.sender,address(this),tokenId);

    }

    function toogleMarketSale(uint256 tokenId) payable public{
        require(msg.sender == idMarketItem[tokenId].owner , "you are not the owner of this NFT");
        require(idMarketItem[tokenId[.price == msg.value,"your price must be with the listing price");

        idMarketItem[tokenId].owner = payable(msg.sender);
        idMarketItem[tokenId].sold = true;
        idMarketItem[tokenId].owner = payable(address(0));

        _itemsold.increment();

        _transfer(address(this),msg.sender,tokenId);
        payable(owner).transfer(listingPrice);
        payable(idMarketItem[tokenId].seller).transfer(msg.value);
    }
}
