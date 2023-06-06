import { ethers } from "hardhat";

async function main() {
  const TokenFactory = await ethers.getContractFactory("TokenAsset");
  const Token = await TokenFactory.deploy();
  await Token.deployed();

  console.log(
    `The Token contract has been deployed to address ${Token.address}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
