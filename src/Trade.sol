// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.24;

import {CustomToken} from "./CustomToken.sol";
import {CustomPet} from "./CustomPet.sol";

/**
 * @title Trade 交易合约
 * @author srcres258
 * @notice 用户交易合约, 实现指定买方/有效期/价格 CT, 放入 CP,
 * 买方支付 CT 确认 (处理超额/不足退款), 过期/取消逻辑, 退还 CP/CT.
 */
contract Trade {
    address public seller;
    address public buyer;
    uint256 public expiration;
    uint256 public priceCT;
    bool public active = true;

    CustomToken public ct;
    CustomPet public cp;

    uint256[] public depositedCPs;

    event TradeConfirmed();
    event TradeCancelled();
    event TradeExpired();

    constructor(
        address _seller,
        address _buyer,
        uint256 _duration,
        uint256 _priceCT,
        address _ctAddress,
        address _cpAddress
    ) {
        seller = _seller;
        buyer = _buyer;
        expiration = block.timestamp + _duration;
        priceCT = _priceCT;
        ct = CustomToken(_ctAddress);
        cp = CustomPet(_cpAddress);
    }

    /// @notice 卖方存入 CP (可多次调用).
    function depositCP(uint256[] memory tokenIds) external {
        require(msg.sender == seller, "Only seller can deposit CP.");
        require(active, "Trade is not active.");
        for (uint256 i = 0; i < tokenIds.length; i++) {
            cp.transferFrom(seller, address(this), tokenIds[i]);
            depositedCPs.push(tokenIds[i]);
        }
    }

    /// @notice 买方确认交易并支付 CT.
    function confirm() external {
        require(msg.sender == buyer, "Only buyer can confirm trade.");
        require(active, "Trade is not active.");
        require(block.timestamp < expiration, "Trade has expired.");

        uint256 provided = ct.allowance(buyer, address(this)); // Assume approve first
        require(provided >= priceCT, "Insufficient CT approved.");

        require(ct.transferFrom(buyer, seller, priceCT), "CT transfer failed.");
        if (provided > priceCT) {
            // Refund excess CT, but since allowance, better handle in client
            require(ct.transferFrom(buyer, buyer, provided - priceCT), "CT refund failed.");
        }

        // Transfer CPs to buyer
        for (uint256 i = 0; i < depositedCPs.length; i++) {
            cp.transferFrom(address(this), buyer, depositedCPs[i]);
        }

        active = false;
        emit TradeConfirmed();
    }

    /// @notice 卖方取消交易, 退还 CP.
    function cancel() external {
        require(msg.sender == seller, "Only seller can cancel trade.");
        require(active, "Trade is not active.");

        // Return CPs to seller
        _returnCPs();

        active = false;
        emit TradeCancelled();
    }

    /// @notice 检查并处理过期交易, 退还 CP.
    /// (当交易过期后, 任何人均可调用此函数来处理过期逻辑. 可考虑写自动化脚本定期调用.)
    function expire() external {
        require(block.timestamp >= expiration, "Trade has not expired yet.");
        require(active, "Trade is not active.");

        // Return CPs to seller
        _returnCPs();

        active = false;
        emit TradeExpired();
    }

    /// @notice 内部函数: 退还 CP 给卖方.
    function _returnCPs() internal {
        for (uint256 i = 0; i < depositedCPs.length; i++) {
            cp.transferFrom(address(this), seller, depositedCPs[i]);
        }
        delete depositedCPs;
    }
}
