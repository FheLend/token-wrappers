import { createFheInstance } from "../utils/instance";
import { expect } from "chai";
import hre  from "hardhat";
import type { Signers } from "./types";
import { getTokensFromFaucet } from "./utils";

describe('Token test', function() {
    before(async function() {
        this.signers = {} as Signers;
        // get tokens from faucet
        await getTokensFromFaucet();
        // initiate fhenixjs
        // this.instance = await createFheInstance(hre, address);
        const signers = await hre.ethers.getSigners();
        this.signers.admin = signers[0];
        this.signers.borrower = signers[1];
    }) 

    it('should transferEncrypted success', async function() {
        const [owner] = await hre.ethers.getSigners();

        const token = await hre.ethers.getContractFactory("TestToken");
        const t = await token.deploy("USDT", "USDT");
        const tokenAddress = await t.getAddress();

        // initiate fhenixjs
        this.instance = await createFheInstance(hre, tokenAddress);

        console.log("balance of owner: ", await t.balanceOf(owner))
        const transferAmount = BigInt(1) * BigInt(10**18)
        const etransferAmount = await this.instance.instance.encrypt_uint128(transferAmount);

        // transfer encrypted
        t.transferEncrypted(this.signers.borrower, etransferAmount);

        // t.connect(this.signers.borrower).transferFromEncrypted(owner,  this.signers.borrower, etransferAmount);

        // console.log("balance of receiver: ", await t.balanceOf(this.signers.borrower))
    })

    it.only('should transferFromEncryted success', async function() {
        const [owner] = await hre.ethers.getSigners();

        const token = await hre.ethers.getContractFactory("TestToken");
        const t = await token.deploy("USDT", "USDT");
        const tokenAddress = await t.getAddress();

        // initiate fhenixjs
        this.instance = await createFheInstance(hre, tokenAddress);

        console.log("balance of owner: ", await t.balanceOf(owner))

        // transfer encrypted

        // approve encrypted
        const approveAmount = BigInt(1000_000) * BigInt(10**18) ;
        const encApproveAmount = await this.instance.instance.encrypt_uint128(approveAmount);
        
        // approve using token to another user
        await t.connect(owner).approveEncrypted(this.signers.borrower, encApproveAmount);

        const transferAmount = BigInt(100) * BigInt(10**18)
        const etransferAmount = await this.instance.instance.encrypt_uint128(transferAmount);

        t.connect(this.signers.borrower).transferFromEncrypted(owner,  this.signers.borrower, etransferAmount);

        console.log("balance of receiver: ", await t.balanceOf(this.signers.borrower));
        
        const permit = await fhenixjs.generatePermit(tokenAddress, undefined, this.signers.borrower);

        const balanceSealed = await t.connect(this.signers.borrower).getBalanceSealed(permit);

        console.log(balanceSealed);

        const balance = this.instance.instance.unseal(tokenAddress, balanceSealed, this.signers.borrower.address);

        console.log(balance);
    })

});