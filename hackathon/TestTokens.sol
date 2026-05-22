// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title TestUSD  (TUSD)  — simple ERC-20 for DEX testing
 */
contract TestUSD {
    string  public name     = "TestUSD";
    string  public symbol   = "TUSD";
    uint8   public decimals = 18;
    uint256 public totalSupply;
    address public owner;

    mapping(address => uint256)                     public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner_, address indexed spender, uint256 value);

    modifier onlyOwner() { require(msg.sender == owner, "Not owner"); _; }

    constructor(uint256 initialSupply) {
        owner = msg.sender;
        _mint(msg.sender, initialSupply * 10 ** 18);
    }

    function transfer(address to, uint256 amt) external returns (bool) { _transfer(msg.sender, to, amt); return true; }
    function approve(address sp, uint256 amt) external returns (bool) { allowance[msg.sender][sp] = amt; emit Approval(msg.sender, sp, amt); return true; }
    function transferFrom(address from, address to, uint256 amt) external returns (bool) {
        require(allowance[from][msg.sender] >= amt, "Allowance");
        allowance[from][msg.sender] -= amt; _transfer(from, to, amt); return true;
    }
    function mint(address to, uint256 amt) external onlyOwner { _mint(to, amt); }

    function _transfer(address from, address to, uint256 amt) internal {
        require(balanceOf[from] >= amt, "Balance"); balanceOf[from] -= amt; balanceOf[to] += amt;
        emit Transfer(from, to, amt);
    }
    function _mint(address to, uint256 amt) internal {
        totalSupply += amt; balanceOf[to] += amt; emit Transfer(address(0), to, amt);
    }
}

/**
 * @title TestBTC  (TBTC)  — simple ERC-20 for DEX testing
 */
contract TestBTC {
    string  public name     = "TestBTC";
    string  public symbol   = "TBTC";
    uint8   public decimals = 18;
    uint256 public totalSupply;
    address public owner;

    mapping(address => uint256)                     public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner_, address indexed spender, uint256 value);

    modifier onlyOwner() { require(msg.sender == owner, "Not owner"); _; }

    constructor(uint256 initialSupply) {
        owner = msg.sender;
        _mint(msg.sender, initialSupply * 10 ** 18);
    }

    function transfer(address to, uint256 amt) external returns (bool) { _transfer(msg.sender, to, amt); return true; }
    function approve(address sp, uint256 amt) external returns (bool) { allowance[msg.sender][sp] = amt; emit Approval(msg.sender, sp, amt); return true; }
    function transferFrom(address from, address to, uint256 amt) external returns (bool) {
        require(allowance[from][msg.sender] >= amt, "Allowance");
        allowance[from][msg.sender] -= amt; _transfer(from, to, amt); return true;
    }
    function mint(address to, uint256 amt) external onlyOwner { _mint(to, amt); }

    function _transfer(address from, address to, uint256 amt) internal {
        require(balanceOf[from] >= amt, "Balance"); balanceOf[from] -= amt; balanceOf[to] += amt;
        emit Transfer(from, to, amt);
    }
    function _mint(address to, uint256 amt) internal {
        totalSupply += amt; balanceOf[to] += amt; emit Transfer(address(0), to, amt);
    }
}
