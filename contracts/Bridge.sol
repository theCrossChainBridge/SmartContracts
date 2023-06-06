// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IBridge.sol";

contract Bridge is IBridge, Ownable {
    error InsufficientBalance();

    address public targetContractAddr;

    /**
     * @notice 
     */
    mapping (address account => mapping (address tokenAddr => uint256 balance)) public tokenBalanceOf;

    /**
     * @dev stake token into contract
     * @param token_addr the address of ERC20 token
     * @param amount the amount of ERC20 token to stake
     */
    function stake(address token_addr, uint256 amount) external override checkTargetBalance(token_addr, amount) returns (bool success) {
        IERC20(token_addr).transferFrom(msg.sender, address(this), amount);
        tokenBalanceOf[msg.sender][token_addr] += amount;

        success = true;

        emit Stake(msg.sender, token_addr, amount);
    }

    /**
     * @dev transfer token from contract to account address
     * @param token_addr the address of ERC20 token
     * @param amount the amount of ERC20 to transfer
     */
    function mint(address account, address token_addr, uint256 amount) external override onlyOwner returns (bool success) {
        IERC20(token_addr).transfer(account, amount);
        tokenBalanceOf[account][token_addr] -= amount;

        success = true;

        emit Mint(account, token_addr, amount);
    }

    /**
     * @dev show the contract balance of the specified token
     * @param token_addr the address of ERC20 token
     */
    function balanceOfToken(address token_addr) view public override returns (uint256 balance) {
        return IERC20(token_addr).balanceOf(address(this));
    }

    /**
     * @dev set the target contract address
     * @param addr the target contract address
     */
    function setTargetContractAddr(address addr) external override onlyOwner returns (bool success) {
        targetContractAddr = addr;

        success = true;
    }

    /**
     * @dev check the target contract has the enough balance of token
     */
    modifier checkTargetBalance(address token_addr, uint256 amount) {
        if(IBridge(targetContractAddr).balanceOfToken(token_addr) < amount) {
            revert InsufficientBalance();
        }
        _;
    }
}