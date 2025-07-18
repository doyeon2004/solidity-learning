import hre from "hardhat";
import { MyToken, NativeBank } from "../typechain-types";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai";

describe("Native Bank", () => {
  let signers: HardhatEthersSigner[];
  let nativeBankC: NativeBank;
  beforeEach("Deploy NativeBank contract", async () => {
    signers = await hre.ethers.getSigners();
    nativeBankC = await hre.ethers.deployContract("NativeBank");
  });

  it("Should send native token to contract", async () => {
    const signers = await hre.ethers.getSigners();
    const staker = signers[0];
    const nativeBankC = await hre.ethers.deployContract("NativeBank");

    const tx = {
      from: staker.address,
      to: await nativeBankC.getAddress(),
      value: hre.ethers.parseEther("1"),
    };

    const txResp = await staker.sendTransaction(tx);
    const txReceipt = await txResp.wait();
    console.log(
      //total balance
      await hre.ethers.provider.getBalance(await nativeBankC.getAddress())
    );

    console.log(await nativeBankC.balanceOf(staker.address));
  });

  it("Should withdraw all the tokens", async () => {
    const staker = signers[0];
    const stakingAmount = hre.ethers.parseEther("10");
    const tx = {
      from: staker,
      to: await nativeBankC.getAddress(),
      value: stakingAmount,
    };

    const sendTx = await staker.sendTransaction(tx);
    sendTx.wait();
    expect(await nativeBankC.balanceOf(staker.address)).equal(stakingAmount);
    nativeBankC;

    await nativeBankC.withdraw();
    expect(await nativeBankC.balanceOf(staker.address)).equal(0n);
  });
});
