import "@nomiclabs/hardhat-ethers";
import { task } from "hardhat/config";
import config from '../config';

task("claim",
  "Allows the caller to claim the reward from the staking contract.")
  .addParam("signer", "ID of the signer used to make the call.")
  .setAction(async (args, { ethers }) => {
    const signerArray = await ethers.getSigners();
    const Staking = await ethers.getContractFactory("Staking");
    const staking = Staking.attach(config.RINKEBY_ADDRESS);
    const txClaim = staking.connect(signerArray[args.signer]).claim();
    const rClaim = await (await txClaim).wait();

    const caller = rClaim.events[1].args[0];
    const amount = rClaim.events[1].args[1];

    console.log(caller + ' claimed ' + amount + ' reward tokens.');
  });
