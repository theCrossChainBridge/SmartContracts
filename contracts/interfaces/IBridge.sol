// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

interface IBridge {
    // =============================== Event ===============================
    event Stake(address indexed account, address token_addr, uint256 amount);
    event Mint(address indexed account, address token_addr, uint256 amount);

    // =============================== Read Functions ===============================
    function balanceOfToken(address token_addr) view external returns (uint256 balance);

    // =============================== Write Functions ===============================
    function stake(address token_addr, uint256 _amount) external returns (bool success);
    function mint(address account, address token_addr, uint256 amount) external returns (bool success);
}