import "@nomiclabs/hardhat-ethers";
import { task } from "hardhat/config";
import config from '../config';

task("hasClaimedReward",
  "Get whether the account claimed the reward.")
  .addParam("account", "User's address")
  .setAction(async (args, { ethers }) => {
    const Staking = await ethers.getContractFactory("Staking");
    const staking = Staking.attach(config.RINKEBY_ADDRESS);
    const hasClaimedReward = await staking.hasClaimedReward(args.account);
    console.log(args.account + ' has claimed reward is ' + hasClaimedReward);
  });
