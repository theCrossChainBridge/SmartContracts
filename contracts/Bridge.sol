// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IBridge.sol";

contract Bridge is IBridge, Ownable {
    error InsufficientBalance();

    uint256 reserveA; // reserve of tokenA
    uint256 reserveB; // reserve of tokenB

    address public TokenA_addr;
    address public TokenB_addr;

    constructor (address _TokenA, address _TokenB) {
        TokenA_addr = _TokenA;
        TokenB_addr = _TokenB;
    }


    /**
     * @dev stake token into contract
     * @param token_addr the address of ERC20 token
     * @param amount the amount of ERC20 token to stake
     */
    function stake(address token_addr, uint256 amount) external override returns (bool success) {

        uint256 outputAmount = getAmountOut(amount, token_addr);
        if (token_addr == TokenA_addr) {
            IERC20(TokenA_addr).transferFrom(msg.sender, address(this), amount);
            reserveB -= outputAmount;
        } else if (token_addr == TokenB_addr) {
            IERC20(TokenB_addr).transferFrom(msg.sender, address(this), amount);
            reserveA -= outputAmount;
        } else {
            revert("error address");
        }

        success = true;

        emit Stake(msg.sender, token_addr, outputAmount);
    }

    /**
     * @dev transfer token from contract to account address
     * @param token_addr the address of ERC20 token
     * @param amount the amount of ERC20 to transfer
     */
    function mint(address token_addr, uint256 outputAmount) external override onlyOwner returns (bool success) {
        uint256 amount = getAmountIn(outputAmount, token_addr);
        if (token_addr == TokenA_addr) {
            IERC20(TokenB_addr).transfer(msg.sender, outputAmount);
            reserveA += amount;
        } else if(token_addr == TokenB_addr) {
            IERC20(TokenA_addr).transfer(msg.sender, outputAmount);
            reserveB += amount;
        } else {
            revert("error address");
        }

        success = true;

        emit Mint(msg.sender, token_addr, amount);
    }

    /**
     * @dev show the contract balance of the specified token
     * @param token_addr the address of ERC20 token
     */
    function balanceOfToken(address token_addr) view public override returns (uint256 balance) {
        return IERC20(token_addr).balanceOf(address(this));
    }

    // get AmountOut by inputAmount
    function getAmountOut(uint256 inputAmount, address inputToken) public view returns (uint256 outputAmount) {
        if (inputToken == TokenA_addr) {
            outputAmount = (inputAmount * reserveB) / (reserveA + inputAmount);
        } else if (inputToken == TokenB_addr) {
            outputAmount = (inputAmount * reserveA) / (reserveB + inputAmount);
        } else {
            revert("address error");
        }
        
        return outputAmount;

    }

    // get inputAmount by outputAmount
    function getAmountIn(uint256 outputAmount, address outputToken) public view returns (uint256 inputAmount) {
        if (outputToken == TokenA_addr) {
            inputAmount = (reserveB * outputAmount) / (reserveA - outputAmount);
        } else if (outputToken == TokenB_addr) {
            inputAmount = (reserveA * outputAmount) / (reserveA - outputAmount);
        } else {
            revert("address error");
        }

        return inputAmount;
    }


    
}
