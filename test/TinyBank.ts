import hre from "hardhat";
import { expect } from "chai";
import { DECIMALS, MINTING_AMOUNT } from "./constant";
import { MyToken, TinyBank } from "../typechain-types";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";

describe("TinyBank", () => {
  let signers: HardhatEthersSigner[];
  let myTokenC: MyToken;
  let tinyBankC: TinyBank;

  beforeEach(async () => {
    signers = await hre.ethers.getSigners();
    myTokenC = await hre.ethers.deployContract("MyToken", [
      "MyToken",
      "MT",
      DECIMALS,
      MINTING_AMOUNT,
    ]);

    const managers = signers.slice(0, 5).map((s) => s.address);
    tinyBankC = await hre.ethers.deployContract("TinyBank", [
      await myTokenC.getAddress(),
      managers,
    ]);
    await myTokenC.setManager(await tinyBankC.getAddress());
  });

  it("should revert when not all managers confirmed", async () => {
    await tinyBankC.connect(signers[0]).confirm();
    await tinyBankC.connect(signers[1]).confirm();
    await expect(
      tinyBankC.connect(signers[0]).setRewardPerBlock(123)
    ).to.be.revertedWith("Not all confirmed yet");
  });

  it("should allow setRewardPerBlock after all managers confirm", async () => {
    const newReward = hre.ethers.parseUnits("1234", DECIMALS);
    for (let i = 0; i < 5; i++) {
      await tinyBankC.connect(signers[i]).confirm();
    }
    await tinyBankC.connect(signers[0]).setRewardPerBlock(newReward);
    const result = await tinyBankC.rewardPerBlock();
    expect(result).to.equal(newReward);
  });

  it("should revert if non-manager tries to confirm", async () => {
    await expect(tinyBankC.connect(signers[5]).confirm()).to.be.revertedWith(
      "You are not a manager"
    );
  });
});
