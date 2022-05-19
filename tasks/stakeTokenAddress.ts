import "@nomiclabs/hardhat-ethers";
import { task } from "hardhat/config";
import config from '../config';

task("stakeTokenAddress",
  "Get the stake token contract address.")
  .setAction(async (_, { ethers }) => {
    const Staking = await ethers.getContractFactory("Staking");
    const staking = Staking.attach(config.RINKEBY_ADDRESS);
    const stakeTokenAddress = await staking.stakeTokenAddress();
    console.log("Stake token address is " + stakeTokenAddress);
  });
