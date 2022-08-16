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
    mapping(address => uint256) internal depositTimestamps;

    uint256 public deadline;
    uint256 public totalStaked;
    uint256 public constant interestRate = 4;

    bool public _paused;
    bool internal locked;

    address owner;

    /* ========== MODIFIERS ========== */

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    /**
     * @dev In case of emergency sets contract on pause
     */
    modifier onlyWhenNotPaused() {
        require(!_paused, "Contract currently paused");
        _;
    }

    /**
     * @dev Prevents reentrancy
     */
    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    /* ========== CONSTRUCTOR ========== */

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
        owner = msg.sender;
        locked = false;
    }

    /* ========== FUNCTIONS ========== */

    /**
     * @notice Method for staking ETH
     */
    function stake() public payable onlyWhenNotPaused {
        require(msg.value > 0, "Can't stake 0 ether");
        require(msg.value < totalStaked, "Try to stake less ETH");

        balances[msg.sender] += msg.value;
        totalStaked += msg.value;

        depositTimestamps[msg.sender] = block.timestamp;
        deadline = block.timestamp + 120 seconds;

        emit Stake(msg.sender, msg.value);
    }

    /**
     * @notice Method that allows users withdraw their staking balance
     */
    function withdraw() public onlyWhenNotPaused {
        require(
            balances[msg.sender] > 0,
            "Nothing to withdrawal. Stake some eth"
        );
        require(
            block.timestamp >= deadline,
            "You need to wait some time before you can withdraw"
        );

        uint256 withdrawalAmount = earned(msg.sender) + balances[msg.sender];

        (bool success, ) = msg.sender.call{value: withdrawalAmount}("");
        require(success, "Failed to withdraw");
        totalStaked -= withdrawalAmount;
        balances[msg.sender] = 0;
    }

    /**
     * @dev setPaused makes the contract paused or unpaused
     */
    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    /**
     * @notice Additional method that adds liquidity to reward pool by owner of the contract
     */
    function addLiquidity() public payable onlyOwner {
        require(msg.value > 0, "Must be more than 0 ETH");
        totalStaked += msg.value;
    }

    /**
     * @notice Additional method that remove liquidity to reward pool by owner of the contract
     */
    function removeLiquidity() public payable onlyOwner {
        require(totalStaked > 0, "Nothing to withdrawal");
        (bool success, ) = msg.sender.call{value: totalStaked}("");
        require(success, "Failed to withdraw");
        totalStaked = 0;
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
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    /*
        READ-ONLY function that shows how much user earned for staking
    */
    function earned(address account) public view returns (uint256) {
        if (balances[account] > 0) {
            return
                calculateInterest(
                    balances[account],
                    (block.timestamp - depositTimestamps[msg.sender])
                );
        }
        return 0;
    }

    /*
        READ-ONLY function that will calculate interest
    */
    function calculateInterest(uint256 staked, uint256 period)
        private
        view
        returns (uint256)
    {
        if (staked == 0 || totalStaked == 0) {
            return 0;
        }
        return (((staked * interestRate) * (period / 60)) / 100);
    }

    /**
     * @dev returns earned value for the frontend
     */
    function getEarned(address account) public view returns (uint256) {
        uint256 _precision = 1e7;
        return earned(account) / _precision;
    }
}
