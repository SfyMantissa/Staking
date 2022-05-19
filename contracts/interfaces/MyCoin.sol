/// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface MyCoin {

  event Transfer(address indexed seller, address indexed buyer, uint256 amount);
  event Approval(address indexed owner, address indexed delegate, uint256 amount);

  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);
  function transfer(address buyer, uint256 amount) external returns (bool);
  function transferFrom(address seller, address buyer, uint256 amount) external returns (bool);
  function approve(address delegate, uint256 amount) external returns (bool);
  function burn(address account, uint256 amount) external returns (bool);
  function mint(address account, uint256 amount) external returns (bool);

}
