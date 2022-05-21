import "@nomiclabs/hardhat-ethers";
import { task } from "hardhat/config";
import config from '../config';

task("changeRewardPercentage",
  "Change the reward percentage.")
  .addParam("signer", "ID of the signer used to make the call.")
  .addParam("value", "The new reward percentage value.")
  .setAction(async (args, { ethers }) => {
    const signerArray = await ethers.getSigners();
    const Staking = await ethers.getContractFactory("Staking");
    const staking = Staking.attach(config.RINKEBY_ADDRESS);
    const rewardPercentage = await staking.rewardPercentage();
    await staking.connect(signerArray[args.signer]).changeRewardPercentage(args.value);
    const newRewardPercentage = await staking.rewardPercentage();
    console.log("Reward percentage changed from " + rewardPercentage
      + " to " + newRewardPercentage + '.');
  });
