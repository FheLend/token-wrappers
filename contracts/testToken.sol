// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@fhenixprotocol/contracts/access/Permissioned.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@fhenixprotocol/contracts/FHE.sol";

contract TestToken is ERC20, Permissioned {

    mapping(address => euint128) internal _encBalances;
    mapping(address => bool) internal _minted; // limit each address to mint only one

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 100000 * 10 ** uint(decimals()));
    }

    // @dev mint token for testing purpose
    function mint() public {
        // check require
        require(_minted[msg.sender] == false, "Each address can mint only once.");
        // mint 100 token to msg sender 
        _mint(msg.sender, 100 * 10 ** uint(decimals()));
        _minted[msg.sender] = true;
    }

    function wrap(uint32 amount) public {
        // Make sure that the sender has enough of the public balance
        require(balanceOf(msg.sender) >= amount);
        // Burn public balance
        _burn(msg.sender, amount);

        // convert public amount to shielded by encrypting it
        euint128 shieldedAmount = FHE.asEuint128(amount);
        // Add shielded balance to his current balance
        _encBalances[msg.sender] = _encBalances[msg.sender] + shieldedAmount;
    }

    function unwrap(inEuint128 memory amount) public {
        euint128 _amount = FHE.asEuint128(amount);
        // verify that our shielded balance is greater or equal than the requested amount 
        FHE.req(_encBalances[msg.sender].gte(_amount));
        // subtract amount from shielded balance
        _encBalances[msg.sender] = _encBalances[msg.sender] - _amount;
        // add amount to caller's public balance by calling the `mint` function
        _mint(msg.sender, FHE.decrypt(_amount));
    }

    function transferEncrypted(address to, inEuint128 calldata encryptedAmount) public {
        euint128 amount = FHE.asEuint128(encryptedAmount);
        // Make sure the sender has enough tokens.
        FHE.req(amount.lte(_encBalances[msg.sender]));

        // Add to the balance of `to` and subract from the balance of `from`.
        _encBalances[to] = _encBalances[to] + amount;
        _encBalances[msg.sender] = _encBalances[msg.sender] - amount;
    }
    
    function getBalanceEncrypted(Permission calldata perm) 
    public 
    view 
    onlySender(perm) 
    returns (uint256) {
        return FHE.decrypt(_encBalances[msg.sender]);
    }

    function getBalanceSealed(
        Permission memory permission
    ) public view onlySender(permission) returns (string memory) {
        return FHE.sealoutput(_encBalances[msg.sender], permission.publicKey);
    }
}