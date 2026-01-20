// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.24;

import {CustomToken} from "./CustomToken.sol";
import {ProposalFactory} from "./ProposalFactory.sol";

/**
 * @title Exchange 交易所
 * @author srcres258
 * @notice 本交易所处理 ETH 到 CT 以及 CT 到 ETH 的兑换事务.
 * 其中汇率为 k, 是动态变动的, 由委员会负责调整.
 * @dev Note: This contract assumes it has access to ProposalFactory
 * for initiating k adjustments.
 */
contract Exchange {
    CustomToken public ct;
    ProposalFactory public proposalFactory;
    uint256 public k; // 汇率. 1 CT = k wei = k * 10^-18 ETH

    event ExchangedETHToCT(address indexed user, uint256 ethAmount, uint256 ctAmount);
    event ExchangedCTToETH(address indexed user, uint256 ctAmount, uint256 ethAmount);
    event KAdjusted(uint256 oldK, uint256 newK);

    constructor(CustomToken _ct, ProposalFactory _proposalFactory, uint256 _k) {
        ct = _ct;
        proposalFactory = _proposalFactory;
        k = _k;
    }

    receive() external payable {}

    /// @notice 以 k 汇率兑换 ETH 为 CT
    function exchangeETHToCT() external payable {
        require(msg.value > 0, "Must send ETH to exchange for CT.");
        uint256 ctAmount = msg.value * 1 ether / k;
        ct.mint(msg.sender, ctAmount);
        emit ExchangedETHToCT(msg.sender, msg.value, ctAmount);
    }

    /// @notice 以 k 汇率兑换 CT 为 ETH
    function exchangeCTToETH(uint256 ctWeiAmount) external {
        require(ctWeiAmount > 0, "Must specify CT amount to exchange for ETH.");
        uint256 ethWeiAmount = ctWeiAmount * k / 1 ether;
        require(address(this).balance >= ethWeiAmount, "There is no sufficient ETH in the exchange.");
        ct.burn(msg.sender, ctWeiAmount);
        (bool success,) = payable(msg.sender).call{value: ethWeiAmount}("");
        require(success, "ETH transfer failed.");
        emit ExchangedCTToETH(msg.sender, ctWeiAmount, ethWeiAmount);
    }

    /// @notice 提交更改汇率 k 的提案, 供委员会来表决
    function proposeAdjustK(uint256 newK) external {
        // 假设调用者是委员会成员. 真正的检查由 ProposalFactory 内部完成.
        proposalFactory.createAdjustKProposal(newK);
    }

    /// @notice 内部函数. 当提案通过时调用以调整 k
    function adjustK(uint256 newK) external {
        // Only callable by Proposal contract after passing.
        require(msg.sender == address(proposalFactory), "Unauthorized.");
        uint256 oldK = k;
        k = newK;
        emit KAdjusted(oldK, newK);
    }
}
