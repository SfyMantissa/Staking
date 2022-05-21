import "@nomiclabs/hardhat-ethers";
import { task } from "hardhat/config";
import config from '../config';

task("rewardTokenAddress",
  "Get the reward token contract address.")
  .setAction(async (_, { ethers }) => {
    const Staking = await ethers.getContractFactory("Staking");
    const staking = Staking.attach(config.RINKEBY_ADDRESS);
    const rewardTokenAddress = await staking.rewardTokenAddress();
    console.log("Reward token address is " + rewardTokenAddress + '.');
  });
