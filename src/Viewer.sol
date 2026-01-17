// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.24;

import {CustomPet} from "./CustomPet.sol";
import {TradeFactory} from "./TradeFactory.sol";
import {ProposalFactory} from "./ProposalFactory.sol";
import {Trade} from "./Trade.sol";
import {Proposal} from "./Proposal.sol";

/**
 * @title Viewer 用户自身状态查询合约
 * @author srcres258
 * @notice 测试查看自身 CP/详情, 自身交易列表, 所有提案信息.
 */
contract Viewer {
    CustomPet public cp;
    TradeFactory public tradeFactory;
    ProposalFactory public proposalFactory;

    constructor(CustomPet _cp, TradeFactory _tradeFactory, ProposalFactory _proposalFactory) {
        cp = _cp;
        tradeFactory = _tradeFactory;
        proposalFactory = _proposalFactory;
    }

    // /// @notice 获取用户拥有的所有 CP 及其 URI.
    // function getOwnedCPs(address user) external view returns (
    //     uint256[] memory tokenIds,
    //     string[] memory tokenURIs
    // ) {
    //     uint256 balance = cp.balanceOf(user);
    //     tokenIds = new uint256[](balance);
    //     tokenURIs = new string[](balance);

    //     for (uint i = 0; i < balance; i++) {
    //         uint256 id = cp.tokenOfOwnerByIndex(user, uint256(i));
    //         tokenIds[i] = id;
    //         tokenURIs[i] = cp.tokenURI(id);
    //     }
    // }

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

    /// @notice 获取所有活跃提案的信息.
    function getActiveProposals() external view returns (address[] memory) {
        return proposalFactory.getActiveProposals();
    }

    /// @notice 获取所有历史提案的信息.
    function getHistoricalProposals() external view returns (address[] memory) {
        return proposalFactory.getHistoricalProposals();
    }

    /// @notice 获取提案的详细信息.
    function getProposalDetails(address proposalAddress)
        external
        view
        returns (
            address _initiator,
            uint256 _startTime,
            uint256 _endTime,
            string memory _proposalType,
            uint256 _yesWeight,
            uint256 _noWeight,
            bool _executed
        )
    {
        Proposal proposal = Proposal(proposalAddress);
        return proposal.getInfo();
    }
}
