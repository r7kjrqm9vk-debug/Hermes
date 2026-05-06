// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title HermesToken
/// @notice ERC-20 token for the HERMES protocol on RISE Chain

contract HermesToken {
    string public name = "Hermes Token";
    string public symbol = "HERMES";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public faucet;
    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    modifier onlyFaucet() {
        require(msg.sender == faucet, "HermesToken: only faucet");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setFaucet(address _faucet) external {
        require(msg.sender == owner, "HermesToken: only owner");
        faucet = _faucet;
    }

    function mint(address to, uint256 amount) external onlyFaucet {
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(balanceOf[from] >= amount, "insufficient balance");
        require(allowance[from][msg.sender] >= amount, "insufficient allowance");
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }
}
