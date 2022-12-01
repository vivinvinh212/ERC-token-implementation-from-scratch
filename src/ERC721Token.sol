// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./Counter.sol";

contract ERC721Token {
    address private owner;
    string private name;
    string private symbol;
    uint private immutable MAX_SUPPLY;
    uint private currentSupply;

    using Counters for Counters.Counter;
    //NFT id counter
    Counters.Counter private _tokenIdCounter;

    // Mapping keeping track of balances of addresses
    mapping(address => uint) private balances;
    // Mapping from token ID to owner address
    mapping(uint256 => address) private holders;
    // Mapping from token ID to approved address
    mapping(uint256 => address) private tokenApprovals;
    // Mapping for token URIs
    mapping(uint256 => string) private tokenURIs;

    // Main events including Mint, Burn, Transfer, Approve
    event tokenMinted(address _to, uint _tokenId);
    event tokenBurned(address _from, uint _tokenId);
    event Transfer(address _from, address _to, uint _tokenId);
    event Approval(address _from, address _to, uint _tokenId);

    /**
     * @dev Modifier restricting access to only owner
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call method");
        _;
    }

    /**
     * @dev Modifier restricting access to only holder
     */
    modifier onlyHolder(uint _tokenId) {
        require(msg.sender == holders[_tokenId], "Only holder can call method");
        _;
    }

    /**
     * @dev Modifier restricting access to only holder or approved account
     */
    modifier onlyHolderOrApproved(uint _tokenId) {
        require(
            msg.sender == tokenApprovals[_tokenId] ||
                msg.sender == holders[_tokenId],
            "Only holder or approved can call method"
        );
        _;
    }

    constructor(string memory _name, string memory _symbol, uint _totalSupply) {
        name = _name;
        symbol = _symbol;
        owner = msg.sender;
        MAX_SUPPLY = _totalSupply;
    }

    /**
     * @dev Returns the name of the token.
     */
    function getName() public view returns (string memory) {
        return name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function getSymbol() public view returns (string memory) {
        return symbol;
    }

    /**
     * @dev Returns the owner of the token
     */
    function getOwner() public view returns (address) {
        return owner;
    }

    /**
     * @dev Function allows the owner to issue new token to specified address.
     */
    function mintToken(address _to, uint _amount) public onlyOwner {
        require(_amount > 0, "Must mint at least 1 NFT");
        require(_to != address(0), "ERC721: mint to the zero address");
        require(
            _tokenIdCounter.current() + _amount <= MAX_SUPPLY,
            "Cannot mint more than total supply"
        );
        currentSupply += _amount;
        for (uint256 i = 0; i < _amount; i++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            _mint(_to, tokenId);
            emit tokenMinted(_to, tokenId);
        }
    }

    /**
     * @dev Function allows anyone to burn an amount of their token.
     */
    function burnToken(uint _tokenId) public onlyHolderOrApproved(_tokenId) {
        address holder = holders[_tokenId];

        delete holders[_tokenId];
        unchecked {
            currentSupply -= 1;
            balances[holder] -= 1;
        }
        if (bytes(tokenURIs[_tokenId]).length != 0) {
            delete tokenURIs[_tokenId];
        }
        emit tokenBurned(msg.sender, _tokenId);
    }

    /**
     * @dev Function returning to total supply defined by the owner in constructor.
     */
    function totalSupply() public view returns (uint256) {
        return MAX_SUPPLY;
    }

    /**
     * @dev Function returning to current supply.
     */
    function supply() public view returns (uint256) {
        return currentSupply;
    }

    /**
     * @dev Returns the balance of a specfific user.
     */
    function balanceOf(address _user) public view returns (uint) {
        require(
            _user != address(0),
            "ERC721: address zero is not a valid owner"
        );
        return balances[_user];
    }

    /**
     * @dev Returns the holder of a specific token given token id.
     */
    function holderOf(uint _tokenId) public view returns (address) {
        address holder = holders[_tokenId];
        return holder;
    }

    /**
     * @dev Allows user to transfer a specific token given token id to another address
     */
    function transfer(
        uint _tokenId,
        address _to
    ) public onlyHolder(_tokenId) returns (bool) {
        _transfer(msg.sender, _to, _tokenId);
        return true;
    }

    /**
     * @dev Allows an user to approve spending of a specific token for a spender account.
     */
    function approve(uint _tokenId, address _to) public onlyHolder(_tokenId) {
        tokenApprovals[_tokenId] = _to;
        emit Approval(holderOf(_tokenId), _to, _tokenId);
    }

    /**
     * @dev View approval of a specific token.
     */
    function getApproval(uint _tokenId) public view returns (address) {
        return tokenApprovals[_tokenId];
    }

    /**
     * @dev Allow an user to transfer token in behalf of the owner accounts given approval.
     */
    function transferFrom(
        address _from,
        address _to,
        uint _tokenId
    ) public onlyHolderOrApproved(_tokenId) returns (bool) {
        _transfer(_from, _to, _tokenId);
        return true;
    }

    /**
     * @dev Return the tokenURI of a specific token.
     */
    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        require(_exists(_tokenId), "ERC721: invalid token id");

        string memory _tokenURI = tokenURIs[_tokenId];
        string memory base = "";

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return
            bytes(base).length > 0
                ? string(abi.encodePacked(base, _tokenId))
                : "";
    }

    /**
     * @dev Set tokenURI for a token.
     */
    function _setTokenURI(uint256 _tokenId, string memory _tokenURI) internal {
        require(_exists(_tokenId), "ERC721: URI set of nonexistent token");
        tokenURIs[_tokenId] = _tokenURI;
    }

    /**
     * @dev Internal function mint.
     */
    function _mint(address _to, uint _tokenId) internal {
        require(_to != address(0), "ERC721: mint to the zero address!");
        require(!_exists(_tokenId), "ERC721: token already minted!");
        unchecked {
            balances[_to] += 1;
        }
        holders[_tokenId] = _to;
    }

    /**
     * @dev Internal function transfer.
     */
    function _transfer(address _from, address _to, uint _tokenId) internal {
        require(
            _from == holders[_tokenId],
            "ERC721: transfer from incorrect owner"
        );
        require(_to != address(0), "ERC721: invalid receiver");
        delete tokenApprovals[_tokenId];

        unchecked {
            balances[_from] -= 1;
            balances[_to] += 1;
        }

        holders[_tokenId] = _to;
    }

    /**
     * @dev Check the existence of token with the specified token id
     */
    function _exists(uint256 _tokenId) internal view returns (bool) {
        return holderOf(_tokenId) != address(0);
    }

    /**
     * @dev Check if the address is the holder or is approved for a specific token id.
     */
    function _isHolderOrApproved(
        address _spender,
        uint _tokenId
    ) internal view returns (bool) {
        address holder = ERC721Token.holderOf(_tokenId);
        return (_spender == holder || getApproval(_tokenId) == _spender);
    }
}
