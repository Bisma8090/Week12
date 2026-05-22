// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract SimpleSwap {
    // The two tokens in our pool
    IERC20 public tokenA;
    IERC20 public tokenB;
    
    // How many tokens are in the pool
    uint256 public reserveA;
    uint256 public reserveB;
    
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB);
    event Swapped(address indexed user, string direction, uint256 amountIn, uint256 amountOut);
    
    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }
    
    // Add liquidity to the pool
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(amountA > 0 && amountB > 0, "Amounts must be greater than 0");
        
        // Transfer tokens from user to this contract
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);
        
        // Update reserves
        reserveA += amountA;
        reserveB += amountB;
        
        emit LiquidityAdded(msg.sender, amountA, amountB);
    }
    
    // Swap Token A for Token B
    function swapAforB(uint256 amountAIn) external {
        require(amountAIn > 0, "Amount must be greater than 0");
        require(reserveB > 0, "No liquidity");
        
        // Calculate how much Token B user gets
        // Formula: amountOut = (reserveB * amountIn) / (reserveA + amountIn)
        uint256 amountBOut = (reserveB * amountAIn) / (reserveA + amountAIn);
        
        require(amountBOut > 0, "Insufficient output amount");
        require(amountBOut < reserveB, "Not enough liquidity");
        
        // Transfer tokens
        tokenA.transferFrom(msg.sender, address(this), amountAIn);
        tokenB.transfer(msg.sender, amountBOut);
        
        // Update reserves
        reserveA += amountAIn;
        reserveB -= amountBOut;
        
        emit Swapped(msg.sender, "A->B", amountAIn, amountBOut);
    }
    
    // Swap Token B for Token A
    function swapBforA(uint256 amountBIn) external {
        require(amountBIn > 0, "Amount must be greater than 0");
        require(reserveA > 0, "No liquidity");
        
        // Calculate how much Token A user gets
        uint256 amountAOut = (reserveA * amountBIn) / (reserveB + amountBIn);
        
        require(amountAOut > 0, "Insufficient output amount");
        require(amountAOut < reserveA, "Not enough liquidity");
        
        // Transfer tokens
        tokenB.transferFrom(msg.sender, address(this), amountBIn);
        tokenA.transfer(msg.sender, amountAOut);
        
        // Update reserves
        reserveB += amountBIn;
        reserveA -= amountAOut;
        
        emit Swapped(msg.sender, "B->A", amountBIn, amountAOut);
    }
    
    // Preview: How much will I get if I swap?
   function getSwapAmount(uint256 amountIn, bool _swapAforB) external view returns (uint256) {
    if (_swapAforB) {
        return (reserveB * amountIn) / (reserveA + amountIn);
    } else {
        return (reserveA * amountIn) / (reserveB + amountIn);
    }
}
    
    // View current pool status
    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }
}