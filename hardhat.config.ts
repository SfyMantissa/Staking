import * as dotenv from "dotenv";

import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "solidity-coverage";
import './tasks/index';
dotenv.config();

module.exports = {
  solidity: "0.8.4",
  defaultNetwork: "rinkeby",
  networks: {
    rinkeby: {
      url: process.env.ALCHEMY_KEY,
      accounts: [process.env.PRIVATE_KEY1, process.env.PRIVATE_KEY2],
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_KEY
  }
};
