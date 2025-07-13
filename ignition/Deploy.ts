import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { TinyBank } from "../typechain-types/TinyBank.vy";

export default buildModule("MyTokenDeploy", (m) => {
  const myTokenC = m.contract("MyToken", ["MyToken", "MT", 18, 100]);
  const tinyBankC = m.contract("TinyBank", [myTokenC]);
  return { myTokenC, tinyBankC };
});
