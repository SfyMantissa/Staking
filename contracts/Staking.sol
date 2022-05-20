// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/MyCoin.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title A simple ERC-20 staking contract for the Uniswap testnet.
/// @author Sfy Mantissa
contract Staking is Ownable {

  /// @notice Get the staked token balance of the account.
  mapping(address => uint256) public balanceOf;

  /// @notice Get last stake timestamp of the account.
  mapping(address => uint256) public stakeStartTimestampOf;

  /// @notice Get whether the account already claimed the reward.
  mapping(address => bool) public hasClaimedReward;

  /// @notice Get the stake token address.
  address public stakeTokenAddress;

  /// @notice Get the reward token address.
  address public rewardTokenAddress;

  /// @notice Get the percentage of staked tokens which is returned every
  ///         rewardInterval as reward tokens.
  uint256 public rewardPercentage;

  /// @notice Get the interval for reward returns.
  uint256 public rewardInterval;

  /// @notice Get the interval for which `claim()`
  ///         function remains unavailable.
  uint256 public lockInterval;

  /// @notice Gets triggered when tokens are staked by the account.
  event Staked(address from, uint256 amount);

  /// @notice Gets triggered when tokens are unstaked by the account.
  event Unstaked(address to, uint256 amount);

  /// @notice Get triggered when the reward is claimed by the account.
  event Claimed(address to, uint256 amount);

  /// @notice All constructor params are actually set in config.ts.
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

  /// @notice Allows the user to stake a specified `amount` of tokens.
  /// @dev The implied usage cycle is stake() → claim() → unstake() → ...
  /// @param _amount The amount of tokens to be staked.
  function stake(uint256 _amount) 
    external
  {
    require(
      !hasClaimedReward[msg.sender],
      "ERROR: must unstake after claiming the reward to stake again."
    );

    IUniswapV2Pair(stakeTokenAddress).transferFrom(
      msg.sender,
      address(this),
      _amount
    );

    balanceOf[msg.sender] += _amount;
    stakeStartTimestampOf[msg.sender] = block.timestamp;

    emit Staked(msg.sender, _amount);
  }

  /// @notice Allows the user to unstake all staked tokens.
  function unstake()
    external
  {
    require(
      hasClaimedReward[msg.sender],
      "ERROR: must claim reward before unstaking."
    );

    uint256 amount = balanceOf[msg.sender];
    
    IUniswapV2Pair(stakeTokenAddress).transfer(
      msg.sender,
      amount
    );

    balanceOf[msg.sender] = 0;
    hasClaimedReward[msg.sender] = false;

    emit Unstaked(msg.sender, amount);
  }

  /// @notice Allows the user to claim the reward.
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

  /// @notice Allows the owner to change the rewardInterval.
  function changeRewardInterval(uint256 _rewardInterval)
    external
    onlyOwner
  {
    rewardInterval = _rewardInterval;
  }

  /// @notice Allows the owner to change the lockInterval.
  function changeLockInterval(uint256 _lockInterval)
    external
    onlyOwner
  {
    lockInterval = _lockInterval;
  }

  /// @notice Allows the owner to change the rewardPercentage.
  function changeRewardPercentage(uint256 _rewardPercentage)
    external
    onlyOwner
  {
    rewardPercentage = _rewardPercentage;
  }
}
