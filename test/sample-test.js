const { expect,assert } = require("chai");
const {upgrades, ethers } = require("hardhat");
let nameBox = ["xanh","do","vang"];
let amountBox = [1000,1000,1000];
let urlBox = ["abc","abcd","abcdef"];
let addr1, addr2;
describe("Box", function () {

  before(async function() {
    [addr1, addr2, _] = await ethers.getSigners();
    const Box = await ethers.getContractFactory("Box");
    contract = await Box.deploy();
    console.log(`Box deployed to1: ${contract.address}`);
    // const Nft = await ethers.getContractFactory("OpenBox");
    // nft = await Nft.deploy(contract.address);
    // console.log(`NFT deployed to1: ${nft.address}`);
    // const RanDom = await ethers.getContractFactory("RandomNumberConsumer");
    // random = await RanDom.deploy(contract.address);
    // console.log(`RanDom deployed to1: ${random.address}`);
  });
  beforeEach(async function () {});

  describe("createBox", () => {
    it("test function createBoxList ", async function () {
      await contract.deployed();
      const createBox = await contract.createBoxList(nameBox,amountBox,urlBox);
      expect(
        (nameBox.length === amountBox.length) === urlBox.length,
        "Invalid Supply"
      );
     
      expect(createBox).to.be.not.undefined;
    });
    it("test function addQuantityBox", async function(){
      await contract.deployed();
      const addQuantityBox = await contract.addQuantityBox("xanh",1000);
      
      expect(addQuantityBox, 'topic [answer]').to.equal(2000);

    });
  });
  describe("createEvent", () => {
    it("test function createEvent ", async function () {
      await contract.deployed();
      // await random.deployed();
      // console.log(random.address);
      // const randomNumber = await contract.setRanDomContractAddress(random.address,1);
      // console.log(randomNumber);
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
  // describe("buyBox", () => {
  //   it("test function muabox ", async function () {
  //     await contract.deployed();
  //     const createBox = await contract.createBoxList(nameBox,amountBox,urlBox);
  //     expect(
  //       (nameBox.length === amountBox.length) === urlBox.length,
  //       "Invalid Supply"
  //     );
     
  //     expect(createBox).to.be.not.undefined;
  //   });
  // });
});
