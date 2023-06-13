// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IBridge.sol";

contract Bridge is IBridge, Ownable {
    error InsufficientBalance();
    error InvalidTokenAddress();

    uint256 private reserveA; // reserve of tokenA
    uint256 private reserveB; // reserve of tokenB

    address public tokenA_addr;
    address public tokenB_addr;

    constructor(address _tokenA, address _tokenB) {
        tokenA_addr = _tokenA;
        tokenB_addr = _tokenB;
    }

    /**
     * @dev stake token into contract
     * @param tokenIn the address of ERC20 token to stake
     * @param amount the amount of ERC20 token to stake
     * @return success the result of tx
     */
    function stake(
        address tokenIn,
        uint256 amount
    ) external override returns (bool success) {
        if(tokenIn != tokenA_addr && tokenIn != tokenB_addr) {
            revert InvalidTokenAddress();
        }
        uint256 outputAmount = getAmountOut(amount, tokenIn);
        address tokenOut;
        if (tokenIn == tokenA_addr) {
            IERC20(tokenA_addr).transferFrom(_msgSender(), address(this), amount);
            reserveA += amount;
            reserveB -= outputAmount;
            tokenOut = tokenB_addr;
        } else {
            IERC20(tokenB_addr).transferFrom(_msgSender(), address(this), amount);
            reserveB += amount;
            reserveA -= outputAmount;
            tokenOut = tokenA_addr;
        }
        success = true;

        emit Stake(_msgSender(), tokenOut, outputAmount);
    }

    /**
     * @dev transfer token from contract to account address
     * @param token_addr the address of ERC20 token
     * @param outputAmount the amount of ERC20 to transfer
     * @return success the result of tx
     */
    function mint(
        address account,
        address token_addr,
        uint256 outputAmount
    ) external override onlyOwner returns (bool success) {
        if(token_addr != tokenA_addr && token_addr != tokenB_addr) {
            revert InvalidTokenAddress();
        }

        IERC20(token_addr).transfer(account, outputAmount);

        address tokenIn;
        uint256 amountIn = getAmountIn(outputAmount, token_addr);
        if (token_addr == tokenA_addr) {
            reserveA -= outputAmount;
            reserveB += amountIn;
            tokenIn = tokenB_addr;
        } else {
            reserveB -= outputAmount;
            reserveA += amountIn;
            tokenIn = tokenA_addr;
        }

        success = true;

        emit Mint(account, tokenIn, amountIn);
    }

    /**
     * @dev show the contract balance of the specified token
     * @param token_addr the address of ERC20 token
     * @return balance the balance of token_addr
     */
    function balanceOfToken(
        address token_addr
    ) public view override returns (uint256 balance) {
        return IERC20(token_addr).balanceOf(address(this));
    }

    /**
     * @dev get AmountOut by inputAmount
     * @param inputAmount the amount of input token
     * @param inputToken the address of input token
     * @return outputAmount the amount user will get
     */
    function getAmountOut(
        uint256 inputAmount,
        address inputToken
    ) public view override returns (uint256 outputAmount) {
        if (inputToken == tokenA_addr) {
            outputAmount = (inputAmount * reserveB) / (reserveA + inputAmount);
        } else if (inputToken == tokenB_addr) {
            outputAmount = (inputAmount * reserveA) / (reserveB + inputAmount);
        } else {
            revert InvalidTokenAddress();
        }

        if(outputAmount == 0) revert InsufficientBalance();
    }

    /**
     * @dev get inputAmount by outputAmount
     * @param outputAmount the amount of output token
     * @param outputToken the address of output token
     * @return inputAmount the amount user should input
     */
    function getAmountIn(
        uint256 outputAmount,
        address outputToken
    ) public view override returns (uint256 inputAmount) {
        if(outputToken != tokenA_addr && outputToken != tokenB_addr) {
            revert InvalidTokenAddress();
        }
        (uint256 _reserveA, uint256 _reserveB) = getReserve();
        if (outputToken == tokenA_addr) {
            inputAmount = (_reserveB * outputAmount) / (_reserveA - outputAmount);
        } else {
            inputAmount = (_reserveA * outputAmount) / (_reserveB - outputAmount);
        }

        if(inputAmount == 0) revert InsufficientBalance();
    }

    /**
     * @dev get reserve of tokenA and tokenB
     * @return _reserveA the reserve of tokenA
     * @return _reserveB the reserve of tokenB
     */
    function getReserve() public view override returns (uint256 _reserveA, uint256 _reserveB) {
        (_reserveA, _reserveB) = (reserveA, reserveB);
    }

    /**
     * @dev add liquidity
     * @param amountA the amount of tokenA
     * @param amountB the amount of tokenB
     * @return success the result of tx
     */
    function addReserve(uint256 amountA, uint256 amountB) public override returns (bool success) {
        IERC20(tokenA_addr).transferFrom(_msgSender(), address(this), amountA);
        IERC20(tokenB_addr).transferFrom(_msgSender(), address(this), amountB);
        success = true;
    }
}
