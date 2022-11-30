// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Counters.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title Contract for Cutie NFT
 * @author vivinvinh212
 * @notice Contract allowing user to mint Cutie ERC-721 compliant NFT
 */
contract Cutie is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    //NFT id counter
    Counters.Counter private _tokenIdCounter;

    //Meta-data uri
    string constant TOKEN_URI =
        "ipfs://QmZvBFsTFhfR75bEVitGVHcqCCkR5WgYmgHVNihH5nmejN";

    // Define maximum supply, mint price and maximum mint per transactions of NFT
    uint256 public constant MAX_SUPPLY = 100;
    uint public constant mintPrice = 0.01 ether;
    uint constant maxPerTransaction = 5;

    //Track deployment status
    bool public deployed = false;

    /**
     * @notice Constructor for generating ERC-721 Cutie token
     */
    constructor() ERC721("Cutie", "CUTE") {
        deployed = true;
    }

    /**
     * @notice Function to safely mint up to 5 Cutie NFT token in a transaction
     * @param mintAmount Number of NFT mint during the transaction
     */
    function safeMint(uint256 mintAmount) public payable {
        require(mintAmount > 0, "Must mint at least 1");
        require(
            mintAmount <= maxPerTransaction,
            "Maximum 5 nfts allowed in a transaction"
        );
        require(
            _tokenIdCounter.current() + mintAmount <= MAX_SUPPLY,
            "Supply is not enough"
        );
        require(msg.value >= mintPrice * mintAmount, "Insufficient balance");

        for (uint256 i = 1; i <= mintAmount; i++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint(msg.sender, tokenId);
            _setTokenURI(tokenId, TOKEN_URI);
        }
    }

    /**
     * @notice Send funds in the contract to owner wallet
     */
    function withdraw() public payable onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Not enough balance");
        (bool status, ) = (msg.sender).call{value: balance}("");
        require(status, "Withdraw failed");
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

// contract TestCutie is Cutie {
//     function echidna_mint() public view returns (bool) {
//         return balances[msg.sender] <= 1000;
//     }
// }
