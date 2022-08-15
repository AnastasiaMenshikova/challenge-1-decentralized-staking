// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./ExampleExternalContract.sol";
import "hardhat/console.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    /* ========== EVENTS ========== */

    event Stake(address indexed sender, uint256 amount);

    /* ========== STATE VARIABLES ========== */

    mapping(address => uint256) public balances;
    mapping(address => uint256) public depositTimestamps;

    uint256 public deadline = block.timestamp + 120 seconds;

    // uint256 public constant rewardRatePerBlock = 0.01 ether;

    /* ========== CONSTRUCTOR ========== */

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    /*
     * @notice Method for staking ETH
     */
    function stake() public payable {
        require(msg.value > 0, "Can't stake 0 ether");

        balances[msg.sender] += msg.value;
        depositTimestamps[msg.sender] = block.timestamp;

        emit Stake(msg.sender, msg.value);
    }

    /*
     * @notice Method that allows users withdraw their staking balance
     */
    function withdraw() public {
        require(
            balances[msg.sender] > 0,
            "Nothing to withdrawal. Stake some eth"
        );
        require(
            block.timestamp >= deadline,
            "You need to wait some time before you can withdraw"
        );

        // uint256 withdrawAmount = balances[msg.sender];
        (bool success, ) = msg.sender.call{value: balances[msg.sender]}("");
        require(success, "Failed to withdraw");
        balances[msg.sender] = 0;
    }

    // special function that receives eth
    receive() external payable {}

    /* ========== VIEWS ========== */

    /*
        READ-ONLY function that returns the time left before the deadline for the frontend
    */
    function timeLeft() public view returns (uint256) {
        return block.timestamp < deadline ? deadline - block.timestamp : 0;
    }

    /*
        READ-ONLY function that shows staked amount for the frontend
    */
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}
