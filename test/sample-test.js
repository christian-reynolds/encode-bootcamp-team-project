const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BaseErc20", function () {
  let baseErc20;

  beforeEach(async () => {
    const BaseErc20 = await hre.ethers.getContractFactory("BaseErc20");
    baseErc20 = await BaseErc20.deploy("Test Name", "TSN", 100);
    await baseErc20.deployed();

    [owner, addr1, addr2, addr3] = await ethers.getSigners();
  });

  it("Should return the name", async () => {
    expect(await baseErc20.name()).to.equal("Test Name");
  });

  it("Should increase total supply", async () => {
    let tx = await baseErc20.addShares(100);
    await tx.wait();

    expect(await baseErc20.totalSupply()).to.equal(200);
  });

  it("Should decrease total supply", async () => {
    let tx = await baseErc20.reduceShares(100);
    await tx.wait();

    expect(await baseErc20.totalSupply()).to.equal(0);
  });
});
