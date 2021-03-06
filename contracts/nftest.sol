// SPDX-License-Identifier: GPLv3

pragma solidity ^0.8.4;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";

contract Nftest is ERC721, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _priceUpdates;
    
    mapping(uint256 => string) private _tokenNames;
    mapping(uint256 => uint256) private _tokenPrices;
    mapping(uint256 => string) private _tokenURIs;
    mapping(address => uint256) private _balances;
    
    constructor(string memory _name, string memory _symbol) 
        ERC721(_name, _symbol) 
    {}
    
    fallback() external payable {}
    receive() external payable {}
    
    modifier tokenExists(uint256 tokenId) {
        require(_exists(tokenId), "This is not a token.");
        _;
    }
    
    function getName(uint256 tokenId) external view tokenExists(tokenId) returns (string memory) {
    	return _tokenNames[tokenId];
    }
    
    function getPrice(uint256 tokenId) external view tokenExists(tokenId) returns (uint256) {
    	return _tokenPrices[tokenId];
    }
    
    function getURI(uint256 tokenId) external view tokenExists(tokenId) returns (string memory) {
    	return _tokenURIs[tokenId];
    }
    
    function getBalance(address checkAddress) external view returns (uint256) {
    	return _balances[checkAddress];
    }
    
    function getMintedCount() external view returns (uint256) {
        return _tokenIds.current();
    }
    
    function getPriceUpdates() external view returns (uint256) {
        return _priceUpdates.current();
    }
    
    function setTokenPrice(uint256 tokenId, uint256 _tokenPrice) external tokenExists(tokenId) {
    	address tokenOwner = ownerOf(tokenId);
    	require(tokenOwner == msg.sender, "You do not own this token.");
    	_tokenPrices[tokenId] = _tokenPrice;
    	_priceUpdates.increment();
    }
    
    function setTokenMetadata(uint256 tokenId, string memory _URI, uint256 _price, string memory _name) internal virtual tokenExists(tokenId) {
    	_tokenURIs[tokenId] = _URI;
    	_tokenPrices[tokenId] = _price;
    	_tokenNames[tokenId] = _name;
    }
    
    function buy(uint256 tokenId) external payable tokenExists(tokenId) {
    	uint256 tokenPrice = _tokenPrices[tokenId];
    	require(msg.value >= tokenPrice, "This is not enough money.");
    	address tokenHolder = ownerOf(tokenId);
    	_balances[tokenHolder] += msg.value;
    	
    	_safeTransfer(tokenHolder, msg.sender, tokenId, "");
    }
    
    function withdraw() external {
    	uint256 money = _balances[msg.sender];
    	if (money > 0) {
    		address payable addressToPay = payable(msg.sender);
    		_balances[msg.sender] = 0;
            addressToPay.transfer(money);
    	}
    }
    
    function mint(address _to, string memory _tokenURI, uint256 _price, string memory _name) external onlyOwner() {
    	_tokenIds.increment();
    	uint256 tokenId = _tokenIds.current();
    	
    	_safeMint(_to, tokenId);
    	setTokenMetadata(tokenId, _tokenURI, _price, _name);
    }
}
