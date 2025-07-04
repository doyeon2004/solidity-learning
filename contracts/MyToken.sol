// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract MyToken {
    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    constructor(string memory _name, string memory _symbol, uint8 _decimal) {
        name = _name;
        symbol = _symbol;
        decimals = _decimal;

        // transaction
        // from, to, data, value, gas, ...
        _mint(1 * 10 ** uint256(decimals), msg.sender); // 1 MT (e.g. 10^18 for 18 decimals)
    }

    function _mint(uint256 amount, address owner) internal {
        // totalSupply = totalSupply + amount;
        // balanceOf[owner] = balanceOf[owner] + amount;
        totalSupply += amount;
        balanceOf[owner] += amount;
    }
}
