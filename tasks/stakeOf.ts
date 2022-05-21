import "@nomiclabs/hardhat-ethers";
import { task } from "hardhat/config";
import config from '../config';

task("stakeOf",
  "Get the stake information for the account.")
  .addParam("account", "User's address")
  .setAction(async (args, { ethers }) => {
    const Staking = await ethers.getContractFactory("Staking");
    const staking = Staking.attach(config.RINKEBY_ADDRESS);
    const stakeOf = await staking.stakeOf(args.account);
    console.log(args.account + ' has:\n'
      + stakeOf[0] + ' liquidity tokens staked.\n'
      + stakeOf[1] + ' last stake start timestamp.\n'
      + stakeOf[2] + ' current stake end timestamp.\n'
      + 'Claimed the reward is ' + stakeOf[3]
    );
  });
