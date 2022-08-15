// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./ExampleExternalContract.sol";
import "hardhat/console.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    /* ========== EVENTS ========== */

    event Stake(address indexed sender, uint256 amount);
    event Received(address, uint);
    event Execute(address indexed sender, uint256 amount);

    /* ========== MODIFIERS ========== */

    modifier withdrawlDeadlineReached(bool requireReached) {
        uint256 timeRemaining = withdrawlTimeLeft();
        if (requireReached) {
            require(
                timeRemaining == 0,
                "Withdrawal deadline has not been reached"
            );
        } else {
            require(timeRemaining > 0, "Withdrawal deadline has been reached");
        }
        _;
    }

    modifier claimDeadlineReached(bool requireReached) {
        uint256 timeRemaining = claimPeriodLeft();
        if (requireReached) {
            require(timeRemaining == 0, "Claim deadline has not been reached");
        } else {
            require(timeRemaining > 0, "Claim deadline has been reached");
        }
        _;
    }

    modifier notCompleted() {
        bool completed = exampleExternalContract.completed();
        require(!completed, "Stake already completed!");
        _;
    }

    /* ========== STATE VARIABLES ========== */

    mapping(address => uint256) public balances;
    mapping(address => uint256) public depositTimestamps;

    // uint256 public constant threshold = 1 ether;
    uint256 public withdrawlDeadline = block.timestamp + 120 seconds;
    uint256 public claimDeadline = block.timestamp + 240 seconds;
    uint256 public constant rewardRatePerBlock = 0.01 ether; // change later
    uint256 public currentBlock = 0;

    /* ========== CONSTRUCTOR ========== */

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

    function stake()
        public
        payable
        withdrawlDeadlineReached(false)
        claimDeadlineReached(false)
    {
        balances[msg.sender] = balances[msg.sender] + msg.value;
        depositTimestamps[msg.sender] = block.timestamp;
        emit Stake(msg.sender, msg.value);
    }

    // After some `deadline` allow anyone to call an `execute()` function
    //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
    //  if the `threshold` was not met, allow everyone to call a `withdraw()` function

    function execute() public claimDeadlineReached(true) notCompleted {
        exampleExternalContract.complete{value: address(this).balance}();
    }

    // Add a `withdraw()` function to let users withdraw their balance

    function withdraw()
        public
        withdrawlDeadlineReached(true)
        claimDeadlineReached(false)
        notCompleted
    {
        require(balances[msg.sender] > 0, "You have no balance to withdraw");
        uint256 withdrawAmount = balances[msg.sender];
        uint256 periods = block.timestamp - depositTimestamps[msg.sender];
        for (uint256 i = 0; i < periods; i++) {
            withdrawAmount += (withdrawAmount * rewardRatePerBlock) / 100;
        }
        balances[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: withdrawAmount}("");
        require(success, "Failed to withdraw");
    }

    // Add the `receive()` special function that receives eth and calls stake()

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /* ========== VIEWS ========== */

    /*
        READ-ONLY function to calculate the time remaining before the minimum staking period has passed
    */
    function withdrawlTimeLeft() public view returns (uint256) {
        return
            block.timestamp < withdrawlDeadline
                ? withdrawlDeadline - block.timestamp
                : 0;
    }

    /*
        READ-ONLY function to calculate the time remaining before the minimum staking period has passed
    */
    function claimPeriodLeft() public view returns (uint256) {
        return
            block.timestamp < claimDeadline
                ? claimDeadline - block.timestamp
                : 0;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}
