import "@nomiclabs/hardhat-ethers";
import { task } from "hardhat/config";
import config from '../config';

task("changeLockInterval",
  "Change the lock interval.")
  .addParam("signer", "ID of the signer used to make the call.")
  .addParam("value", "The new lock interval value.")
  .setAction(async (args, { ethers }) => {
    const signerArray = await ethers.getSigners();
    const Staking = await ethers.getContractFactory("Staking");
    const staking = Staking.attach(config.RINKEBY_ADDRESS);
    const lockInterval = await staking.lockInterval();
    await staking.connect(signerArray[args.signer]).changeLockInterval(args.value);
    const newLockInterval = await staking.lockInterval();
    console.log("Lock interval changed from " + lockInterval
      + " to " + newLockInterval + '.');
  });
