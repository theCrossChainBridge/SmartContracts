import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";
dotenv.config();

const PRIVATE_KEY = process.env.PRIVATE_KEY!;

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.16",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },

  networks: {
    polygonMumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${process.env.Mumbai_RPC_KEY}`,
      accounts: [PRIVATE_KEY]
    },
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${process.env.Sepolia_RPC_KEY}`,
      accounts: [PRIVATE_KEY]
    }
  },

  etherscan: {
    apiKey: {
      sepolia: process.env.EtherScan_API_KEY!,
      polygonMumbai: process.env.PolygonScan_API_KEY!,
    }
  }
};

export default config;
