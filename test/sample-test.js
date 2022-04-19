const { expect,assert } = require("chai");
const {upgrades, ethers } = require("hardhat");
const { utils } = ethers;
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
      await expect(contract.addQuantityBox("xanh", 1000))
      .to.emit(contract, 'updateAmountBox')
      .withArgs(2000);

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
        utils.parseEther("0.1"),
        "0x0000000000000000000000000000000000000000",
        1645000000,
        1660000000,
        10,
        0,
        1646000000);
      expect(createEvent).to.be.not.undefined;
    });
  });
  describe("buyBox", () => {
    it("test function muabox addr1 ", async function () {
      await contract.deployed();
      const buybox = await contract.connect(addr1).buyBox(1,5,"xanh","0x0000000000000000000000000000000000000000",{ value: utils.parseEther("0.5") });
      
      expect(buybox).to.be.not.undefined;
      expect( await contract.balanceOf(addr1.address)).to.equal(5);
      
     for (let index = 1; index <= 5; index++) {
      expect( await contract.ownerOf(index)).to.equal(addr1.address);  
     }
    });
    it("test function muabox addr2 ", async function () {
      await contract.deployed();
      const buybox = await contract.connect(addr2).buyBox(1,3,"xanh","0x0000000000000000000000000000000000000000",{ value: utils.parseEther("0.3") });
      
      expect(buybox).to.be.not.undefined;
      expect( await contract.balanceOf(addr2.address)).to.equal(3);
      
     for (let index = 6; index <= 8; index++) {
      expect( await contract.ownerOf(index)).to.equal(addr2.address);  
     }
    });
  });
  describe("OpenBox", () => {
    it("test function OpenBox ", async function () {
      await contract.deployed();
      // const openbox = await contract.connect(addr1).openBox(1,1);
      
    });
  });
});
