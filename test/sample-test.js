const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BaseErc20", function () {
  it("Should return the symbol", async function () {
    const BaseErc20 = await hre.ethers.getContractFactory("BaseErc20");
    const baseErc20 = await BaseErc20.deploy("Test Name", "TSN", 100);
    await baseErc20.deployed();

    expect(await baseErc20.name()).to.equal("Test Name");
  });
});
