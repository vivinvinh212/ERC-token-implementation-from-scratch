// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./Counter.sol";
import "./ERC721Token.sol";

contract NFTMarketplace is ERC721Token {
    using Counters for Counters.Counter;
    //_tokenIds variable has the most recent minted tokenId
    Counters.Counter private _tokenIds;
    //Keeps track of the number of items sold on the marketplace
    Counters.Counter private _itemsSold;

    address payable owner;
    //The fee charged by the marketplace to be allowed to list an NFT
    uint256 listPrice = 0.01 ether;

    //The structure to store info about a listed token
    struct ListedToken {
        uint256 tokenId;
        address payable owner;
        address payable seller;
        uint256 price;
        bool currentlyListed;
    }

    //the event emitted when a token is successfully listed
    event TokenListedSuccess(
        uint256 indexed tokenId,
        address owner,
        address seller,
        uint256 price,
        bool currentlyListed
    );

    mapping(uint256 => ListedToken) private idToListedToken;

    constructor() ERC721Token("NFT_Marketplace", "NFTM", 1) {
        owner = payable(msg.sender);
    }

    /**
     * @dev Mint new NFT for the specified tokenURI.
     */
    function createToken(
        string memory _tokenURI,
        uint256 _price
    ) public payable returns (uint) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
        createListedToken(newTokenId, _price);

        return newTokenId;
    }

    /**
     * @dev Create listed token for NFT.
     */
    function createListedToken(uint256 _tokenId, uint256 _price) private {
        //Make sure the sender sent enough ETH to pay for listing
        require(msg.value >= listPrice, "Not enough fee!");
        require(_price > 0, "Price have to be larger than 0");
        require(
            _isHolderOrApproved(msg.sender, _tokenId),
            "Only holder or approved can call method"
        );

        //Update the mapping of tokenId's to Token details, useful for retrieval functions
        idToListedToken[_tokenId] = ListedToken(
            _tokenId,
            payable(address(this)),
            payable(msg.sender),
            _price,
            true
        );

        _transfer(msg.sender, address(this), _tokenId);
        //Emit the event for successful transfer. The frontend parses this message and updates the end user
        emit TokenListedSuccess(
            _tokenId,
            address(this),
            msg.sender,
            _price,
            true
        );
    }

    /**
     * @dev Returns all listed NFTs.
     */
    function getAllNFTs() public view returns (ListedToken[] memory) {
        uint currentId = getCurrentToken();
        ListedToken[] memory NFTs = new ListedToken[](currentId);

        for (uint i = 0; i < currentId; i++) {
            NFTs[i] = idToListedToken[i + 1];
        }

        return NFTs;
    }

    /**
     * @dev Returns all listed NFTs of msg.sender.
     */
    function getMyNFTs() public view returns (ListedToken[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        //Important to get a count of all the NFTs that belong to the user before we can make an array for them
        for (uint i = 0; i < totalItemCount; i++) {
            if (
                idToListedToken[i + 1].owner == msg.sender ||
                idToListedToken[i + 1].seller == msg.sender
            ) {
                itemCount += 1;
            }
        }

        //Once you have the count of relevant NFTs, create an array then store all the NFTs in it
        ListedToken[] memory NFTs = new ListedToken[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (
                idToListedToken[i + 1].owner == msg.sender ||
                idToListedToken[i + 1].seller == msg.sender
            ) {
                NFTs[currentIndex] = idToListedToken[i + 1];
                currentIndex += 1;
            }
        }
        return NFTs;
    }

    /**
     * @dev Execute sale when transactions are made and transfer ownership.
     */
    function executeSale(uint256 _tokenId) public payable {
        uint price = idToListedToken[_tokenId].price;
        address seller = idToListedToken[_tokenId].seller;
        require(msg.value == price, "Incorrect price paid!");

        //update the details of the token
        idToListedToken[_tokenId].currentlyListed = true;
        idToListedToken[_tokenId].seller = payable(msg.sender);
        _itemsSold.increment();

        //Actually transfer the token to the new owner
        _transfer(address(this), msg.sender, _tokenId);
        //approve the marketplace to sell NFTs on your behalf
        approve(_tokenId, address(this));

        //Transfer the listing fee to the marketplace creator
        payable(owner).transfer(listPrice);
        //Transfer the proceeds from the sale to the seller of the NFT
        payable(seller).transfer(msg.value);
    }

    /**
     * @dev Allow owner to change listing fee.
     */
    function updateListPrice(uint256 _listPrice) public payable {
        require(owner == msg.sender, "Only owner can update listing price");
        listPrice = _listPrice;
    }

    /**
     * @dev get listing fee.
     */
    function getListPrice() public view returns (uint256) {
        return listPrice;
    }

    /**
     * @dev Get id of latest listed token.
     */
    function getLatestIdToListedToken()
        public
        view
        returns (ListedToken memory)
    {
        uint256 currentTokenId = _tokenIds.current();
        return idToListedToken[currentTokenId];
    }

    /**
     * @dev Get listed token of a specific token id.
     */
    function getListedTokenForId(
        uint256 _tokenId
    ) public view returns (ListedToken memory) {
        return idToListedToken[_tokenId];
    }

    /**
     * @dev Get id of the current token counter.
     */
    function getCurrentToken() public view returns (uint256) {
        return _tokenIds.current();
    }
}
