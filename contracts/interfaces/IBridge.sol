// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

interface IBridge {
    // =============================== Event ===============================
    event Stake(address indexed account, address tokenOut, uint256 amount);
    event Mint(address indexed account, address tokenIn, uint256 amount);

    // =============================== Read Functions ===============================
    function balanceOfToken(address token_addr) view external returns (uint256 balance);
    function getReserve() external view returns (uint256 _reserveA, uint256 _reserveB);

    function getAmountIn(uint256 outputAmount, address outputToken) external view returns (uint256 inputAmount);
    function getAmountOut(uint256 inputAmount, address inputToken) external view returns (uint256 outputAmount);

    // =============================== Write Functions ===============================
    function stake(address token_addr, uint256 _amount) external returns (bool success);
    function mint(address account, address token_addr, uint256 amount) external returns (bool success);
    function addReserve(uint256 amountA, uint256 amountB) external returns (bool success);
}