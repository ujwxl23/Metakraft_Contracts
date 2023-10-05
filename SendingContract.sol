// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract SendingContract {
    address private owner;

    IERC20 private token;

    constructor(address tokenAddress) {
        token = IERC20(tokenAddress);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    struct Transaction {
        address senderAddress;
        address recieverAddress;
        uint256 amount;
        bool approved;
        bool transactionComplete;
    }
    uint256 public transactionNo;
    mapping(uint256 => Transaction) public transactions;

    function sendTransaction(address _reciever, uint256 _amt) public {
        ++transactionNo;
        Transaction storage newTransaction = transactions[transactionNo];
        newTransaction.recieverAddress = _reciever;
        newTransaction.senderAddress = msg.sender;
        newTransaction.amount = _amt;
        newTransaction.approved = false;
        newTransaction.transactionComplete = false;
    }

    function viewTransactions(
        uint256 _transactionNum
    ) public view returns (address, uint256, bool, address) {
        Transaction storage thisTransaction = transactions[_transactionNum];
        return (
            thisTransaction.senderAddress,
            thisTransaction.amount,
            thisTransaction.approved,
            thisTransaction.recieverAddress
        );
    }

    function approveTransaction(uint256 _transactionNo) public {
        Transaction storage thisTransaction = transactions[_transactionNo];
        require(
            token.allowance(thisTransaction.senderAddress, address(this)) >=
                thisTransaction.amount,
            "Insufficient allowance"
        );
        require(
            msg.sender == thisTransaction.recieverAddress,
            "You are not the reciever"
        );
        require(
            token.transferFrom(
                thisTransaction.senderAddress,
                address(this),
                thisTransaction.amount
            ),
            "Token transfer failed"
        );

        thisTransaction.approved = true;
    }

    function receiveTransaction(uint256 _transactionNo) public {
        Transaction storage thisTransaction = transactions[_transactionNo];
        require(
            msg.sender == thisTransaction.recieverAddress,
            "You are not the reciever"
        );
        require(
            token.transferFrom(
                address(this),
                msg.sender,
                thisTransaction.amount
            ),
            "Token transfer failed"
        );

        thisTransaction.transactionComplete = true;
    }
}
