import { ethers } from "hardhat";

async function main() {
  const BridgeFactory = await ethers.getContractFactory("Bridge");
  const Bridge = await BridgeFactory.deploy();
  await Bridge.deployed();

  console.log(`The contract has been deployed to ${Bridge.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
