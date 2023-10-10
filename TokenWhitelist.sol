// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Token is ERC20 {
    address public owner;
    mapping(address => bool) public whitelistedAddresses; // Whitelisted addresses to mint tokens
    mapping(address => bool) public tokenMintedAddress; // Addresses that have already minted tokens
    address[] private tokenMintedAddressList;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier onlyWhitelistedUser() {
        require(whitelistedAddresses[msg.sender], "Could not mint the token");
        _;
    }

    constructor() ERC20("recieveToken", "RTK") {
        owner = msg.sender;
        _mint(msg.sender, 5000 * 10 ** decimals());
    }

    function addToWhiteList(address _add) public onlyOwner {
        require(!whitelistedAddresses[_add], "ADDRESS_ALREADY_WHITELISTED");
        whitelistedAddresses[_add] = true;
    }

    function safeMintToken() public onlyWhitelistedUser {
        whitelistedAddresses[msg.sender] = false;
        tokenMintedAddress[msg.sender] = true;
        _mint(msg.sender, 1 * 10 ** decimals());
        tokenMintedAddressList.push(msg.sender);
    }

    function changeOwner(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "New owner cannot be zero address");
        uint256 tokenBalance = balanceOf(owner);
        _transfer(owner, _newOwner, tokenBalance);
        owner = _newOwner;
    }

    function viewTokenMintedAddressList()
        public
        view
        onlyOwner
        returns (address[] memory)
    {
        return tokenMintedAddressList;
    }
}
