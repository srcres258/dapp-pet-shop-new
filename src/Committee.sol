// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.24;

import {CommitteeTreasury} from "./CommitteeTreasury.sol";

/**
 * @title Committee 委员会
 * @author srcres258
 * @notice 本合约管理委员会成员. 用户通过向该合约质押 ETH 以成为委员会成员.
 * 成员可随时增加或者减少质押量. 若质押量减少为 0, 则退出委员会.
 */
contract Committee {
    CommitteeTreasury public treasury;

    mapping(address => uint256) public stakes;
    address[] public members;

    event JoinedCommittee(address indexed member, uint256 amount);
    event AddedStake(address indexed member, uint256 amount);
    event RemovedStake(address indexed member, uint256 amount);
    event LeftCommittee(address indexed member);

    constructor(CommitteeTreasury _treasury) {
        treasury = _treasury;
    }

    /// @notice 质押 ETH 以加入委员会.
    function join() external payable {
        require(msg.value > 0, "Must stake some ETH to join the committee.");
        require(stakes[msg.sender] == 0, "Already a committee member.");
        stakes[msg.sender] = msg.value;
        members.push(msg.sender);
        treasury.receiveETH{value: msg.value}(); // Send to treasury
        emit JoinedCommittee(msg.sender, msg.value);
    }

    /// @notice 增加质押量.
    function addStake() external payable {
        require(msg.value > 0, "Must stake some ETH to add stake.");
        require(stakes[msg.sender] > 0, "Not a committee member.");
        stakes[msg.sender] += msg.value;
        treasury.receiveETH{value: msg.value}(); // Send to treasury
        emit AddedStake(msg.sender, msg.value);
    }

    /// @notice 减少质押量 (部分或者全部).
    function removeStake(uint256 amount) external {
        require(stakes[msg.sender] >= amount, "Insufficient stake to remove.");
        stakes[msg.sender] -= amount;
        treasury.sendETH(msg.sender, amount); // Treasury sends ETH back
        emit RemovedStake(msg.sender, amount);

        // 如果质押量减少为 0, 则退出委员会.
        if (stakes[msg.sender] == 0) {
            // 从成员列表中移除
            for (uint256 i = 0; i < members.length; i++) {
                if (members[i] == msg.sender) {
                    members[i] = members[members.length - 1];
                    members.pop();
                    break;
                }
            }
            emit LeftCommittee(msg.sender);
        }
    }

    /// @notice 获取当前委员会成员列表.
    function getMembers() external view returns (address[] memory) {
        return members;
    }

    /// @notice 检查某个地址是否为委员会成员.
    function isMember(address addr) external view returns (bool) {
        return stakes[addr] > 0;
    }
}
