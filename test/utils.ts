import hre from "hardhat";
import { FheInstance } from "../utils/instance";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";

export async function getTokensFromFaucet() {
    if (hre.network.name === "localfhenix") {
        const signers = await hre.ethers.getSigners();

        // get fund for admin
        if ((await hre.ethers.provider.getBalance(signers[0].address)).toString() === "0") {
            await hre.fhenixjs.getFunds(signers[0].address);
        }

        // get fund for borrower
        if ((await hre.ethers.provider.getBalance(signers[1].address)).toString() === "0") {
            await hre.fhenixjs.getFunds(signers[1].address);
        }
    }
}