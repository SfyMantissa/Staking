import "@nomiclabs/hardhat-ethers";
import { task } from "hardhat/config";
import config from '../config';

task("balanceOf",
  "Get the stake balance of the account.")
  .addParam("account", "User's address")
  .setAction(async (args, { ethers }) => {
    const Staking = await ethers.getContractFactory("Staking");
    const staking = Staking.attach(config.RINKEBY_ADDRESS);
    const balanceOf = await staking.balanceOf(args.account);
    console.log(args.account + ' has ' + balanceOf
      + ' liquidity tokens staked.');
  });
