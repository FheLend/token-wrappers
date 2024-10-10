import { LendingPoolConfigurator } from "../types";
import { task } from "hardhat/config";
import type { TaskArguments } from "hardhat/types";
import chalk from "chalk";

task("deployTestToken", "deploy test token")
  .addParam("symbol", "token symbol")
  .addParam("name", "token name")
  .setAction(async function (taskArguments: TaskArguments, hre) {
    const { fhenixjs, ethers } = hre;
    const { deploy } = hre.deployments;
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
    console.log(
      `Deploy test token : ${taskArguments.symbol}-${taskArguments.name}`,
    );

    try {
      // need to update LendingPool
      const testToken = await deploy("TestToken", {
        from: signer.address,
        log: true,
        args: [taskArguments.symbol, taskArguments.name]
      });
      console.log("test token address: ", testToken.address);
    } catch (e) {
      console.log(`Failed to send add transaction: ${e}`);
      return;
    }
  });
