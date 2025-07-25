// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./ManagedAccess.sol";

interface IMyToken {
    function transfer(uint256 amount, address to) external;
    function transferFrom(address from, address to, uint256 amount) external;
    function mint(uint256 amount, address owner) external;
}

contract TinyBank is ManagedAccess {
    event Staked(address from, uint256 amount);
    event Withdraw(uint256 amount, address to);

    IMyToken public stakingToken;

    mapping(address => uint256) public lastClaimedBlock;
    mapping(address => uint256) public staked;
    uint256 public totalStaked;

    uint256 defaultRewardPerBlock = 1 * 10 ** 18;
    uint256 rewardPerBlock;

    constructor(IMyToken _stakingToken) ManagedAccess(msg.sender, msg.sender) {
        stakingToken = _stakingToken;
        rewardPerBlock = defaultRewardPerBlock;
    }

    modifier updateReward(address to) {
        if (staked[to] > 0) {
            uint256 blocks = block.number - lastClaimedBlock[to];
            uint256 reward = (blocks * rewardPerBlock * staked[to]) / totalStaked;
            stakingToken.mint(reward, to);
        }
        lastClaimedBlock[to] = block.number;
        _;
    }

    function setRewardPerBlock(uint256 _amount) external onlyManager {
        rewardPerBlock = _amount;
    }

    function stake(uint256 _amount) external updateReward(msg.sender) {
        require(_amount > 0, "cannot stake 0 amount");
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        staked[msg.sender] += _amount;
        totalStaked += _amount;
        emit Staked(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external updateReward(msg.sender) {
        require(staked[msg.sender] >= _amount, "insufficient staked token");
        stakingToken.transfer(_amount, msg.sender);
        staked[msg.sender] -= _amount;
        totalStaked -= _amount;
        emit Withdraw(_amount, msg.sender);
    }

    function currentReward(address to) external view returns (uint256) {
        if (staked[to] > 0) {
            uint256 blocks = block.number - lastClaimedBlock[to];
            return (blocks * rewardPerBlock * staked[to]) / totalStaked;
        } else {
            return 0;
        }
    }
}
