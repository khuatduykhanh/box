// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const Box = await hre.ethers.getContractFactory("Box");
  const box = await Box.deploy();

  await box.deployed();

  console.log("Box deployed to:", box.address);

  const OpenBox = await hre.ethers.getContractFactory("OpenBox");
  const openBox = await OpenBox.deploy(0x5FbDB2315678afecb367f032d93F642f64180aa3);

  await openBox.deployed();

  console.log("OpenBox deployed to:", openBox.address);

  const RanDom = await hre.ethers.getContractFactory("RandomNumberConsumer");
  const ranDom = await RanDom.deploy(0x5FbDB2315678afecb367f032d93F642f64180aa3);

  await box.deployed();

  console.log("Box deployed to:", box.address);  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
