import "@nomiclabs/hardhat-ethers";
import { task } from "hardhat/config";
import config from '../config';

task("lockInterval",
  "Get the time in seconds for which account"
  + "balance gets locked after a stake.")
  .setAction(async (_, { ethers }) => {
    const Staking = await ethers.getContractFactory("Staking");
    const staking = Staking.attach(config.RINKEBY_ADDRESS);
    const lockInterval = await staking.lockInterval();
    console.log("Lock interval is " + lockInterval + '.');
  });
