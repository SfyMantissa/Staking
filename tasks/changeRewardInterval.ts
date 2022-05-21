import "@nomiclabs/hardhat-ethers";
import { task } from "hardhat/config";
import config from '../config';

task("changeRewardInterval",
  "Change the reward interval.")
  .addParam("signer", "ID of the signer used to make the call.")
  .addParam("value", "The new reward interval value.")
  .setAction(async (args, { ethers }) => {
    const signerArray = await ethers.getSigners();
    const Staking = await ethers.getContractFactory("Staking");
    const staking = Staking.attach(config.RINKEBY_ADDRESS);
    const rewardInterval = await staking.rewardInterval();
    await staking.connect(signerArray[args.signer]).changeRewardInterval(args.value);
    const newRewardInterval = await staking.rewardInterval();
    console.log("Reward interval changed from " + rewardInterval
      + " to " + newRewardInterval + '.');
  });
