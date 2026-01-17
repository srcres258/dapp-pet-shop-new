// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.24;

import {Committee} from "./Committee.sol";
import {ProposalFactory} from "./ProposalFactory.sol";

/**
 * @title Proposal 提案合约
 * @author srcres258
 * @notice 抽象提案合约, 定义通用提案结构, 包括发起者, 表决时间 t,
 * 投票逻辑 (加权基于质押 ETH), 统计通过/失效, 查看正在/历史提案信息.
 */
contract Proposal {
    ProposalFactory public factory;
    Committee public committee;

    address public initiator;
    uint256 public startTime;
    uint256 public endTime;
    string public proposalType;

    mapping(address => bool) public voted;
    mapping(address => bool) public votes; // true 表示赞成, false 表示反对
    uint256 public yesWeight;
    uint256 public noWeight;

    address public target;
    bytes public data; // 调用数据

    bool public executed;

    event Voted(address indexed voter, bool vote);
    event ProposalEnded(bool passed);

    constructor(address _factory, uint256 _votingTime, string memory _type) {
        factory = ProposalFactory(_factory);
        committee = factory.committee();
        initiator = msg.sender;
        startTime = block.timestamp;
        endTime = block.timestamp + _votingTime;
        proposalType = _type;
    }

    /// @notice Set target (called by factory immediately after creation).
    function setTarget(address _target) external {
        require(msg.sender == address(factory), "Only factory can set target.");
        target = _target;
    }

    /// @notice Set data (called by factory immediately after creation).
    function setData(bytes memory _data) external {
        require(msg.sender == address(factory), "Only factory can set data.");
        data = _data;
    }

    /// @notice 委员会成员对提案进行投票 (赞成/反对).
    function vote(bool yes) external {
        require(block.timestamp < endTime, "Voting period has ended.");
        require(committee.isMember(msg.sender), "Only committee members can vote.");
        require(!voted[msg.sender], "Member has already voted.");

        uint256 stake = committee.stakes(msg.sender);
        require(stake > 0, "Member has no stake.");
        voted[msg.sender] = true;
        votes[msg.sender] = yes;
        if (yes) {
            yesWeight += stake;
        } else {
            noWeight += stake;
        }

        emit Voted(msg.sender, yes);
    }

    /// @notice 结束提案, 统计结果并执行通过的提案.
    /// (当提案逾期后, 任何人均可调用. 推荐写一个自动化脚本专门检测这个, 每当有提案逾期就调用结束它.)
    function endProposal() external {
        require(block.timestamp >= endTime, "Voting period is still ongoing.");
        require(!executed, "Proposal has already been executed.");

        executed = true;
        uint256 totalWeight = yesWeight + noWeight;
        // 判断提案是否通过:
        // 1. 当无人投票 (总权重为 0) 时, 视为未通过.
        // 2. 否则, 若赞成票权重超过总投票权重的 50%, 则视为通过.
        bool passed = (totalWeight > 0) && ((yesWeight * 100 / totalWeight) > 50);
        factory.resolveProposal(address(this), passed);

        emit ProposalEnded(passed);
    }

    /// @notice 获取提案当前状态.
    function getInfo() external view returns (
        address _initiator,
        uint256 _startTime,
        uint256 _endTime,
        string memory _proposalType,
        uint256 _yesWeight,
        uint256 _noWeight,
        bool _executed
    ) {
        return (
            initiator,
            startTime,
            endTime,
            proposalType,
            yesWeight,
            noWeight,
            executed
        );
    }
}
