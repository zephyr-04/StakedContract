// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract StakingContract {
    using SafeMath for uint256;

    event Staked(address indexed staker, uint256 indexed amount, uint256 indexed startTime);
    event Withdrawn(address indexed staker, uint256 indexed amount, uint256 indexed endTime);
    event OwnerTransferred(address previousOwner, address newOwner);

    address public Address;
    address public owner;

    struct Staker {
        uint256 stakedAmount;
        uint256 startTime;
    }

    uint256 public stakingDuration;
    mapping(address => Staker) public stakers;

    constructor(address _Address, uint256 _stakingDuration) {
        owner = msg.sender;
        Address = _Address;
        stakingDuration = _stakingDuration;
    }

    function stake(uint256 _amount) external {
        require(msg.sender != address(0), "Address zero detected");
        require(_amount > 0, "Can't stake null value");
        require(IERC20(Address).balanceOf(msg.sender) >= _amount, "Insufficient funds");

        // Ensure the user has not already staked
        require(stakers[msg.sender].stakedAmount == 0, "Already staked");

        IERC20(Address).transferFrom(msg.sender, address(this), _amount);

        stakers[msg.sender] = Staker({
            stakedAmount: _amount,
            startTime: block.timestamp
        });

        emit Staked(msg.sender, _amount, block.timestamp);
    }

    function withdraw() external {
        require(stakers[msg.sender].stakedAmount > 0, "No staked amount");
        require(block.timestamp >= stakers[msg.sender].startTime.add(stakingDuration), "Staking period not over yet");

        uint256 stakedAmount = stakers[msg.sender].stakedAmount;
        stakers[msg.sender].stakedAmount = 0;

        IERC20(Address).transfer(msg.sender, stakedAmount);

        emit Withdrawn(msg.sender, stakedAmount, block.timestamp);
    }

    function showContractBalance() external view returns (uint256) {
        return IERC20(Address).balanceOf(address(this));
    }

    function transferOwnership(address newOwner) external {
        require(msg.sender == owner, "Give it back to the owner");
        require(newOwner != address(0), "Address zero?");

        address oldOwner = owner;

        owner = newOwner;

        emit OwnerTransferred(oldOwner, newOwner);
    }
}
