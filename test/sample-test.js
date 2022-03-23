const { expect } = require("chai");
const { ethers } = require("hardhat");
let nameBox = ["xanh","do","vang"];
let amountBox = [1000,1000,1000];
let urlBox = ["abc","abcd","abcdef"];
let owner, addr1;
describe("Box", function () {

  before(async () => {
    [owner, addr1, _] = await ethers.getSigners();
    const Box = await ethers.getContractFactory("Box");
    contract = await Box.deploy();
    const NFT = await ethers.getContractFactory("OpenBox");
    nft = await NFT.deploy(contract.address);
    const RanDom = await ethers.getContractFactory("RandomNumberConsumer");
    random = await RanDom.deploy(contract.address);
  });

  describe("createBox", () => {
    it("test function createBoxList ", async function () {
      await contract.deployed();
      const createBox = await contract.createBoxList(nameBox,amountBox,urlBox);
    
      expect(createBox).to.be.not.undefined;
    });
  });
  describe("createEvent", () => {
    it("test function createEvent ", async function () {
      await contract.deployed();
      await random.deployed();
      const setUpAddress = await contract.setRanDomContractAddress(random.address);
      console.log(setUpAddress);
      const createEvent = await contract.createEvent(
        1,
        ["xanh","vang"],
        [100,100],
        200,
        10000000,
        "0x0000000000000000000000000000000000000000",
        1645000000,
        1650000000,
        10,
        1,
        1646000000);
      expect(createEvent).to.be.not.undefined;
    });
  });
});
