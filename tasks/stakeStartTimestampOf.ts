import "@nomiclabs/hardhat-ethers";
import { task } from "hardhat/config";
import config from '../config';

task("stakeStartTimestampOf",
  "Get the timestamp of account's last stake.")
  .addParam("account", "User's address")
  .setAction(async (args, { ethers }) => {
    const Staking = await ethers.getContractFactory("Staking");
    const staking = Staking.attach(config.RINKEBY_ADDRESS);
    const stakeStartTimestampOf
      = await staking.stakeStartTimestampOf(args.account);
    console.log(args.account + ' last staked at ' + stakeStartTimestampOf);
  });
