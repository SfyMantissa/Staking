// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/MyCoin.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title A simple ERC-20 staking contract for the Uniswap testnet.
/// @author Sfy Mantissa
contract Staking is Ownable {

  struct Stake {
    uint256 balance;
    uint256 stakeStartTimestamp;
    uint256 stakeEndTimestamp;
    bool claimedReward;
  }
  
  // @notice Get user's stake data.
  // @dev balance is current amount of tokens staked by user.
  //      stakeStartTimestamp is the UNIX timestamp of last stake made by the user.
  //      stakeEndTimestamp is the UNIX timestamp of the user calling claim().
  //      claimedReward is the flag to tell whether the user already claimed the reward.
  mapping(address => Stake) public stakeOf;

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
    Stake storage _stake = stakeOf[msg.sender];

    require(
      !_stake.claimedReward,
      "ERROR: must unstake after claiming the reward to stake again."
    );

    IUniswapV2Pair(stakeTokenAddress).transferFrom(
      msg.sender,
      address(this),
      _amount
    );

    _stake.balance += _amount;
    _stake.stakeStartTimestamp = block.timestamp;

    emit Staked(msg.sender, _amount);
  }

  /// @notice Allows the user to unstake all staked tokens.
  function unstake()
    external
  {
    Stake storage _stake = stakeOf[msg.sender];
    uint256 amount = _stake.balance;

    require(
      _stake.claimedReward,
      "ERROR: must claim reward before unstaking."
    );

    IUniswapV2Pair(stakeTokenAddress).transfer(
      msg.sender,
      amount
    );

    _stake.balance = 0;
    _stake.claimedReward = false;

    emit Unstaked(msg.sender, amount);
  }

  /// @notice Allows the user to claim the reward.
  function claim()
    external
  {
    Stake storage _stake = stakeOf[msg.sender];

    require(
      _stake.balance > 0,
      "ERROR: nothing is staked."
    );

    require(
      block.timestamp >= _stake.stakeStartTimestamp + lockInterval,
      "ERROR: must wait for lock interval to pass."
    );

    require(
      !_stake.claimedReward,
      "ERROR: already claimed the reward."
    );

    _stake.stakeEndTimestamp = block.timestamp;

    uint256 rewardPerRewardInterval = 
      _stake.balance * rewardPercentage / 100;

    uint256 rewardTotal = 
      rewardPerRewardInterval * (
        (_stake.stakeEndTimestamp - _stake.stakeStartTimestamp) / rewardInterval
    );

    _stake.claimedReward = true;
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
