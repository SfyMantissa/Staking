import "@nomiclabs/hardhat-ethers";
import { task } from "hardhat/config";
import config from '../config';

task("rewardPercentage",
  "Get the percentage of total account's liquidity token stake which"
  + "gets returned as a reward in reward tokens.")
  .setAction(async (_, { ethers }) => {
    const Staking = await ethers.getContractFactory("Staking");
    const staking = Staking.attach(config.RINKEBY_ADDRESS);
    const rewardPercentage = await staking.rewardPercentage();
    console.log("Reward percentage is " + rewardPercentage);
  });
