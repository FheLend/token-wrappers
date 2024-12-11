// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@fhenixprotocol/contracts/access/Permissioned.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@fhenixprotocol/contracts/FHE.sol";

contract TestToken is ERC20, Permissioned {

    mapping(address => euint64) internal _encBalances;
    euint64 public totalEncryptedSupply;
    mapping(address => bool) internal _minted;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
    }

    // override token decimals
    function decimals() public override view virtual returns (uint8) {
        return 6;
    }

    // @dev mint token for testing purpose
    function mint(inEuint64 memory eMintAmount) public {
        _mintEncrypted(msg.sender, eMintAmount);
        _minted[msg.sender] = true;
    }

    function _mintEncrypted(address to, inEuint64 memory encryptedAmount) internal {
        euint64 amount = FHE.asEuint64(encryptedAmount);
        _encBalances[to] = _encBalances[to] + amount;
        totalEncryptedSupply = totalEncryptedSupply + amount;
    }


    function wrap(uint64 amount) public {
        // Make sure that the sender has enough of the public balance
        require(balanceOf(msg.sender) >= amount);
        // Burn public balance
        _burn(msg.sender, amount);

        // convert public amount to shielded by encrypting it
        euint64 shieldedAmount = FHE.asEuint64(amount);
        // Add shielded balance to his current balance
        _encBalances[msg.sender] = _encBalances[msg.sender] + shieldedAmount;
    }

    function unwrap(inEuint64 memory amount) public {
        euint64 _amount = FHE.asEuint64 (amount);
        // verify that our shielded balance is greater or equal than the requested amount 
        FHE.req(_encBalances[msg.sender].gte(_amount));
        // subtract amount from shielded balance
        _encBalances[msg.sender] = _encBalances[msg.sender] - _amount;
        // add amount to caller's public balance by calling the `mint` function
        _mint(msg.sender, FHE.decrypt(_amount));
    }

    function transferEncrypted(address to, inEuint64 calldata encryptedAmount) public {
        euint64 amount = FHE.asEuint64(encryptedAmount);
        // Make sure the sender has enough tokens.
        FHE.req(amount.lte(_encBalances[msg.sender]));

        // Add to the balance of `to` and subract from the balance of `from`.
        _encBalances[to] = _encBalances[to] + amount;
        _encBalances[msg.sender] = _encBalances[msg.sender] - amount;
    } 

    function getBalanceSealed(
        Permission memory permission
    ) public view onlySender(permission) returns (string memory) {
        return FHE.sealoutput(_encBalances[msg.sender], permission.publicKey);
    }
}