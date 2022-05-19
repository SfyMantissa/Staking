import "@nomiclabs/hardhat-ethers";
import { task } from "hardhat/config";
import config from '../config';

task("rewardInterval",
  "Get the time in seconds after which reward is allocated to the account.")
  .setAction(async (_, { ethers }) => {
    const Staking = await ethers.getContractFactory("Staking");
    const staking = Staking.attach(config.RINKEBY_ADDRESS);
    const rewardInterval = await staking.rewardInterval();
    console.log("Reward interval is " + rewardInterval);
  });
