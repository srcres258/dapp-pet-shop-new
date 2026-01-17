// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.24;

import {Trade} from "./Trade.sol";

/**
 * @title TradeFactory 交易工厂
 * @author srcres258
 * @notice 交易工厂合约, 用于用户创建交易实例.
 */
contract TradeFactory {
    address public ctAddress;
    address public cpAddress;

    address[] public trades;

    event TradeCreated(address indexed trade);

    constructor(address _ctAddress, address _cpAddress) {
        ctAddress = _ctAddress;
        cpAddress = _cpAddress;
    }

    /// @notice 创建新的交易实例.
    function createTrade(address _buyer, uint256 _duration, uint256 _priceCT) external {
        Trade trade = new Trade(
            msg.sender,
            _buyer,
            _duration,
            _priceCT,
            ctAddress,
            cpAddress
        );
        trades.push(address(trade));

        emit TradeCreated(address(trade));
    }

    /// @notice 获取所有交易实例地址.
    function getTrades() external view returns (address[] memory) {
        return trades;
    }
}
