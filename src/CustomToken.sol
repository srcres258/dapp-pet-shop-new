// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title CustomToken (CT)
 * @author srcres258
 * @notice ERC-20 代币 CustomToken. 本合约处理基本的代币铸造与销毁事务.
 * 这些事务由外部功能进行调用 (如 Exchange 合约).
 */
contract CustomToken is ERC20 {
    constructor() ERC20("CustomToken", "CT") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}
