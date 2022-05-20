// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/MyCoin.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract Staking is Ownable {

  mapping(address => uint256) public balanceOf;
  mapping(address => uint256) public stakeStartTimestampOf;
  mapping(address => bool) public hasClaimedReward;

  address public stakeTokenAddress;
  address public rewardTokenAddress;
  uint256 public rewardPercentage;
  uint256 public rewardInterval;
  uint256 public lockInterval;

  event Staked(address from, uint256 amount);
  event Unstaked(address to, uint256 amount);
  event Claimed(address to, uint256 amount);

  constructor(
    address _stakeTokenAddress,
    address _rewardTokenAddress,
    uint256 _rewardPercentage,
    uint256 _rewardInterval,
    uint256 _lockInterval
  ) 
  {
    stakeTokenAddress = _stakeTokenAddress;
    rewardTokenAddress = _rewardTokenAddress;
    rewardPercentage = _rewardPercentage;
    rewardInterval = _rewardInterval;
    lockInterval = _lockInterval;

  }

  function stake(uint256 _amount) 
    external
  {
    require(
      !hasClaimedReward[msg.sender],
      "ERROR: must unstake after claiming the reward to stake again."
    );

    IUniswapV2Pair(stakeTokenAddress).transferFrom(msg.sender, address(this), _amount);
    balanceOf[msg.sender] += _amount;
    stakeStartTimestampOf[msg.sender] = block.timestamp;

    emit Staked(msg.sender, _amount);
  }

  function unstake()
    external
  {
    require(
      hasClaimedReward[msg.sender],
      "ERROR: must claim reward before unstaking."
    );
    
    IUniswapV2Pair(stakeTokenAddress).transfer(msg.sender, balanceOf[msg.sender]);
    uint256 amount = balanceOf[msg.sender];
    balanceOf[msg.sender] = 0;
    hasClaimedReward[msg.sender] = false;

    emit Unstaked(msg.sender, amount);
  }

  function claim()
    external
  {
    require(
      block.timestamp >= stakeStartTimestampOf[msg.sender] + lockInterval,
      "ERROR: must wait for lock interval to pass."
    );

    require(
      !hasClaimedReward[msg.sender],
      "ERROR: already claimed the reward."
    );

    uint256 rewardPerRewardInterval = 
      balanceOf[msg.sender] * rewardPercentage / 100;

    uint256 rewardTotal = 
      rewardPerRewardInterval * (
        (block.timestamp - stakeStartTimestampOf[msg.sender]) / rewardInterval
    );

    hasClaimedReward[msg.sender] = true;
    MyCoin(rewardTokenAddress).mint(msg.sender, rewardTotal);

    emit Claimed(msg.sender, rewardTotal);
  }

  function changeRewardInterval(uint256 _rewardInterval)
    external
    onlyOwner
  {
    rewardInterval = _rewardInterval;
  }

  function changeLockInterval(uint256 _lockInterval)
    external
    onlyOwner
  {
    lockInterval = _lockInterval;
  }

  function changeRewardPercentage(uint256 _rewardPercentage)
    external
    onlyOwner
  {
    rewardPercentage = _rewardPercentage;
  }
}
