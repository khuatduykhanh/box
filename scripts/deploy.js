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

  // const Nft = await hre.ethers.getContractFactory("OpenBox");
  // const nft = await Nft.deploy(box.address);

  // await nft.deployed();

  // console.log("NFT deployed to:", nft.address);

  // const RanDom = await hre.ethers.getContractFactory("RandomNumberConsumer");
  // const random = await RanDom.deploy(box.address);

  // await random.deployed();

  // console.log("RanDom deployed to:", random.address);
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
