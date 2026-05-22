// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title PlatformToken (PLAT)
 * @dev ERC-20 — native currency of the unified DeFi+NFT platform
 *      Initial supply: 1,000,000 PLAT minted to deployer
 *      Authorised minters (Faucet) can mint additional tokens
 */
contract PlatformToken {
    string  public name     = "PlatformCoin";
    string  public symbol   = "PLAT";
    uint8   public decimals = 18;
    uint256 public totalSupply;

    address public owner;
    mapping(address => bool)                     public minters;
    mapping(address => uint256)                  public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner_, address indexed spender, uint256 value);

    modifier onlyOwner()  { require(msg.sender == owner,           "Not owner");  _; }
    modifier onlyMinter() { require(minters[msg.sender] || msg.sender == owner, "Not minter"); _; }

    constructor(uint256 initialSupply) {
        owner = msg.sender;
        _mint(msg.sender, initialSupply * 10 ** 18);
    }

    // ── ERC-20 ────────────────────────────────────────────────────────────────
    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount); return true;
    }
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount); return true;
    }
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(allowance[from][msg.sender] >= amount, "Allowance exceeded");
        allowance[from][msg.sender] -= amount;
        _transfer(from, to, amount); return true;
    }

    // ── Minting ───────────────────────────────────────────────────────────────
    function mint(address to, uint256 amount) external onlyMinter { _mint(to, amount); }
    function addMinter(address m) external onlyOwner { minters[m] = true; }
    function removeMinter(address m) external onlyOwner { minters[m] = false; }

    function _transfer(address from, address to, uint256 amount) internal {
        require(to != address(0), "Zero address");
        require(balanceOf[from] >= amount, "Insufficient balance");
        balanceOf[from] -= amount; balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }
    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "Zero address");
        totalSupply += amount; balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }
}
