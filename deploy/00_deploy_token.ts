import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import chalk from "chalk";
import { skip } from "node:test";

const hre = require("hardhat");

const func: DeployFunction = async function () {
  const { fhenixjs, ethers } = hre;
  const { deploy, execute } = hre.deployments;
  const [signer] = await ethers.getSigners();

  if ((await ethers.provider.getBalance(signer.address)).toString() === "0") {
    if (hre.network.name === "localfhenix") {
      await fhenixjs.getFunds(signer.address);
    } else {
        console.log(
            chalk.red("Please fund your account with testnet FHE from https://faucet.fhenix.zone"));
        return;
    }
  }

  const AddressesProvider = await deploy("TestToken", {
    from: signer.address,
    log: true,
    skipIfAlreadyDeployed: true,
  });

  console.log(`Test Token contract: `, AddressesProvider.address);
};

export default func;
func.id = "deploy_test_token";
func.tags = ["test_token"];