// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.24;

import {CustomPet} from "./CustomPet.sol";
import {TradeFactory} from "./TradeFactory.sol";
import {Trade} from "./Trade.sol";

/**
 * @title Viewer 用户自身状态查询合约
 * @author srcres258
 * @notice 测试查看自身 CP/详情, 自身交易列表, 所有提案信息.
 */
contract Viewer {
    CustomPet public cp;
    TradeFactory public tradeFactory;

    constructor(CustomPet _cp, TradeFactory _tradeFactory) {
        cp = _cp;
        tradeFactory = _tradeFactory;
    }

    /// @notice 获取用户拥有的所有 CP 及其 URI.
    function getOwnedCPs(address user) external view returns (
        uint256[] memory tokenIds,
        string[] memory tokenURIs
    ) {
        uint256 balance = cp.balanceOf(user);
        tokenIds = new uint256[](balance);
        tokenURIs = new string[](balance);

        for (uint i = 0; i < balance; i++) {
            uint256 id = cp.tokenOfOwnerByIndex(user, uint256(i));
            tokenIds[i] = id;
            tokenURIs[i] = cp.tokenURI(id);
        }
    }

    /// @notice 获取用户发起的所有交易实例, 包括正在进行的和结束了的.
    function getUserTrades(address user) external view returns (address[] memory) {
        address[] memory allTrades = tradeFactory.getTrades();
        uint256 count = 0;
        for (uint256 i = 0; i < allTrades.length; i++) {
            Trade trade = Trade(allTrades[i]);
            if (trade.seller() == user) {
                count++;
            }
        }
        address[] memory userTrades = new address[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < allTrades.length; i++) {
            Trade trade = Trade(allTrades[i]);
            if (trade.seller() == user) {
                userTrades[index] = allTrades[i];
                index++;
            }
        }
        return userTrades;
    }
}
