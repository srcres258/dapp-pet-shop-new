// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.24;

import {Proposal} from "./Proposal.sol";
import {Committee} from "./Committee.sol";
import {Exchange} from "./Exchange.sol";
import {CustomPet} from "./CustomPet.sol";
import {CommitteeTreasury} from "./CommitteeTreasury.sol";

/**
 * @title ProposalFactory 提案工厂
 * @author srcres258
 * @notice 提案工厂合约, 用于创建各种表决事项的提案实例.
 * (调整 k, mint CP, destroy CP, 修改 t, 商店开关, 上架/定价, 传送/提取资产等.)
 */
contract ProposalFactory {
    Committee public committee;
    Exchange public exchange = Exchange(payable(0));
    CustomPet public cp;
    CommitteeTreasury public treasury;

    address[] public activeProposals;
    address[] public historicalProposals;

    uint256 public votingTime = 30 seconds; // 默认投票时间: 30 秒

    event ProposalCreated(address indexed proposalAddress, string proposalType);

    constructor(Committee _committee, CustomPet _cp, CommitteeTreasury _treasury) {
        committee = _committee;
        cp = _cp;
        treasury = _treasury;
    }

    modifier requiresExchangeSet() {
        _requiresExchangeSet();
        _;
    }

    function _requiresExchangeSet() private view {
        require(address(exchange) != address(0), "Exchange has not been set yet.");
    }

    /// @notice Set the Exchange for the factory.
    function setExchange(Exchange _exchange) external {
        exchange = _exchange;
    }

    /// @notice Modifier to check committee member.
    modifier onlyCommittee() {
        _onlyCommittee();
        _;
    }

    function _onlyCommittee() private view {
        require(committee.isMember(msg.sender), "Restricted to committee members.");
    }

    /// @notice 创建调整 k 的提案.
    function createAdjustKProposal(uint256 newK) external onlyCommittee requiresExchangeSet {
        Proposal prop = new Proposal(address(this), votingTime, "AdjustK");
        prop.setTarget(address(exchange));
        prop.setData(abi.encodeWithSignature("adjustK(uint256)", newK));
        activeProposals.push(address(prop));
        emit ProposalCreated(address(prop), "AdjustK");
    }

    /// @notice 创建铸造 CP 的提案.
    function createMintCPProposal(address to, string memory tokenURI) external onlyCommittee {
        Proposal prop = new Proposal(address(this), votingTime, "MintCP");
        prop.setTarget(address(cp));
        prop.setData(abi.encodeWithSignature("mint(address,string)", to, tokenURI));
        activeProposals.push(address(prop));
        emit ProposalCreated(address(prop), "MintCP");
    }

    /// @notice 创建销毁 CP 的提案.
    function createBurnCPProposal(uint256 tokenId) external onlyCommittee {
        Proposal prop = new Proposal(address(this), votingTime, "BurnCP");
        prop.setTarget(address(cp));
        prop.setData(abi.encodeWithSignature("burn(uint256)", tokenId));
        activeProposals.push(address(prop));
        emit ProposalCreated(address(prop), "BurnCP");
    }

    /// @notice 创建修改投票时间 t 的提案.
    function createChangeVotingTimeProposal(uint256 newTime) external onlyCommittee {
        Proposal prop = new Proposal(address(this), votingTime, "ChangeVotingTime");
        prop.setTarget(address(this));
        prop.setData(abi.encodeWithSignature("setVotingTime(uint256)", newTime));
        activeProposals.push(address(prop));
        emit ProposalCreated(address(prop), "ChangeVotingTime");
    }

    /// @notice 创建切换商店开关的提案.
    function createToggleStoreProposal() external onlyCommittee {
        Proposal prop = new Proposal(address(this), votingTime, "ToggleStore");
        prop.setTarget(address(treasury));
        prop.setData(abi.encodeWithSignature("toggleStore()"));
        activeProposals.push(address(prop));
        emit ProposalCreated(address(prop), "ToggleStore");
    }

    /// @notice 创建切换商店购买功能开关的提案.
    function createToggleStoreBuyingProposal() external onlyCommittee {
        Proposal prop = new Proposal(address(this), votingTime, "ToggleStoreBuying");
        prop.setTarget(address(treasury));
        prop.setData(abi.encodeWithSignature("toggleStoreBuying()"));
        activeProposals.push(address(prop));
        emit ProposalCreated(address(prop), "ToggleStoreBuying");
    }

    /// @notice 创建切换商店出售功能开关的提案.
    function createToggleStoreSellingProposal() external onlyCommittee {
        Proposal prop = new Proposal(address(this), votingTime, "ToggleStoreSelling");
        prop.setTarget(address(treasury));
        prop.setData(abi.encodeWithSignature("toggleStoreSelling()"));
        activeProposals.push(address(prop));
        emit ProposalCreated(address(prop), "ToggleStoreSelling");
    }

    /// @notice 创建上架 CP 及定价的提案.
    function createListCPProposal(uint256 tokenId, uint256 price) external onlyCommittee {
        Proposal prop = new Proposal(address(this), votingTime, "ListCP");
        prop.setTarget(address(treasury));
        prop.setData(abi.encodeWithSignature("listCP(uint256,uint256)", tokenId, price));
        activeProposals.push(address(prop));
        emit ProposalCreated(address(prop), "ListCP");
    }

    /// @notice 创建提取资产的提案.
    function createExtractProposal(address to, string memory assetType, uint256 amountOrId) external onlyCommittee {
        Proposal prop = new Proposal(address(this), votingTime, "ExtractAsset");
        prop.setTarget(address(treasury));
        prop.setData(abi.encodeWithSignature("extractAsset(address,string,uint256)", to, assetType, amountOrId));
        activeProposals.push(address(prop));
        emit ProposalCreated(address(prop), "ExtractAsset");
    }

    /// @notice 当提案的投票截止时, 由提案自动调用本函数.
    function resolveProposal(address proposalAddress, bool passed) external {
        require(msg.sender == proposalAddress, "Unauthorized."); // Only callable by the proposal itself.

        // 移除活跃提案列表中的该提案.
        for (uint256 i = 0; i < activeProposals.length; i++) {
            if (activeProposals[i] == proposalAddress) {
                activeProposals[i] = activeProposals[activeProposals.length - 1];
                activeProposals.pop();
                break;
            }
        }

        // 添加到历史提案列表.
        historicalProposals.push(proposalAddress);

        if (passed) {
            Proposal prop = Proposal(proposalAddress);
            address target = prop.target();
            bytes memory data = prop.data();
            (bool success,) = target.call(data);
            require(success, "Proposal execution failed.");
        }
    }

    /// @notice 设置新的投票时间 t (由提案调用).
    function setVotingTime(uint256 newTime) external {
        require(msg.sender == address(this), "Unauthorized."); // Self-call from proposal.
        votingTime = newTime;
    }

    /// @notice 获取所有活跃的提案列表.
    function getActiveProposals() external view returns (address[] memory) {
        return activeProposals;
    }

    /// @notice 获取所有历史提案列表.
    function getHistoricalProposals() external view returns (address[] memory) {
        return historicalProposals;
    }
}
