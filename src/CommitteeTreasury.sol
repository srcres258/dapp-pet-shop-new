// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.24;

import {CustomToken} from "./CustomToken.sol";
import {CustomPet} from "./CustomPet.sol";
import {Committee} from "./Committee.sol";
import {ProposalFactory} from "./ProposalFactory.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

/**
 * @title CommitteeTreasury 委员会资产管理
 * @author srcres258
 * @notice 本合约管理委员会的所有资产 (ETH, CT, CP 等), 也包括存储功能.
 * 资产通过提案进行转移或提取.
 * 本合约兼具 "商店" (Store) 功能, 提供面向普通用户的商店服务.
 * 商店服务可开可关, 商店中陈列各种 CP Token. 用户需使用 CT 购买.
 * 也可向商店出售 CP 以换取 CT.
 * 商店的购买 / 出售功能也可开可关.
 * 上述所有开关切换操作, 均需要经过委员会表决.
 */
contract CommitteeTreasury {
    using Math for uint256;

    CustomToken public ct;
    CustomPet public cp;
    Committee public committee;
    ProposalFactory public proposalFactory;

    bool public storeOpen = false;
    bool public storeBuyingEnabled = false;
    bool public storeSellingEnabled = false;

    mapping(uint256 => uint256) public cpPrices; // CP Token ID => 价格 (CT)
    uint256[] public listedCPs; // 商店中陈列的 CP

    event StoreToggled(bool open);
    event StoreBuyingToggled(bool enabled);
    event StoreSellingToggled(bool enabled);
    event CPListed(uint256 indexed tokenId, uint256 price);
    event AssetTransferred(address indexed from, string assetType, uint256 amountOrId);
    event AssetExtracted(address indexed to, string assetType, uint256 amountOrId);

    constructor(
        address _ctAddress,
        address _cpAddress,
        Committee _committee,
        ProposalFactory _proposalFactory
    ) {
        ct = CustomToken(_ctAddress);
        cp = CustomPet(_cpAddress);
        committee = _committee;
        proposalFactory = _proposalFactory;
    }

    /// @notice 接收 ETH (for stakes or direct transfers).
    function receiveETH() external payable {}

    /// @notice 委员会成员将资产转入本合约 (direct send, not store).
    function transferAsset(string memory assetType, uint256 amountOrId) external payable {
        require(committee.isMember(msg.sender), "Only committee members can transfer assets.");
        if (keccak256(bytes(assetType)) == keccak256(bytes("ETH"))) {
            require(msg.value == amountOrId, "ETH amount mismatch.");
        } else if (keccak256(bytes(assetType)) == keccak256(bytes("CT"))) {
            require(ct.transferFrom(msg.sender, address(this), amountOrId), "CT transfer failed.");
        } else if (keccak256(bytes(assetType)) == keccak256(bytes("CP"))) {
            cp.transferFrom(msg.sender, address(this), amountOrId);
        } else {
            revert("Unsupported asset type.");
        }
        emit AssetTransferred(msg.sender, assetType, amountOrId);
    }

    /// @notice 委员会成员发起提案, 将资产从本合约中提取到指定地址.
    function proposeExtract(address to, string memory assetType, uint256 amountOrId) external {
        require(committee.isMember(msg.sender), "Only committee members can propose asset extraction.");
        proposalFactory.createExtractProposal(to, assetType, amountOrId);
    }

    /// @notice 真正的资产提取逻辑. 提案通过后自动调用.
    function extractAsset(address to, string memory assetType, uint256 amountOrId) external {
        require(msg.sender == address(proposalFactory), "Unauthorized.");
        if (keccak256(bytes(assetType)) == keccak256(bytes("ETH"))) {
            (bool success, ) = payable(to).call{value: amountOrId}("");
            require(success, "ETH transfer failed.");
        } else if (keccak256(bytes(assetType)) == keccak256(bytes("CT"))) {
            require(ct.transfer(to, amountOrId), "CT transfer failed.");
        } else if (keccak256(bytes(assetType)) == keccak256(bytes("CP"))) {
            cp.transferFrom(address(this), to, amountOrId);
        } else {
            revert("Unsupported asset type.");
        }
        emit AssetExtracted(to, assetType, amountOrId);
    }

    /// @notice 发起提案, 切换商店开关.
    function proposeToggleStore() external {
        proposalFactory.createToggleStoreProposal();
    }

    /// @notice 切换商店开关逻辑. 提案通过后自动调用.
    function toggleStore() external {
        require(msg.sender == address(proposalFactory), "Unauthorized.");
        storeOpen = !storeOpen;
        emit StoreToggled(storeOpen);
    }

    /// @notice 发起提案, 切换商店购买功能开关.
    function proposeToggleStoreBuying() external {
        proposalFactory.createToggleStoreBuyingProposal();
    }

    /// @notice 切换商店购买功能开关逻辑. 提案通过后自动调用.
    function toggleStoreBuying() external {
        require(msg.sender == address(proposalFactory), "Unauthorized.");
        storeBuyingEnabled = !storeBuyingEnabled;
        emit StoreBuyingToggled(storeBuyingEnabled);
    }

    /// @notice 发起提案, 切换商店出售功能开关.
    function proposeToggleStoreSelling() external {
        proposalFactory.createToggleStoreSellingProposal();
    }

    /// @notice 切换商店出售功能开关逻辑. 提案通过后自动调用.
    function toggleStoreSelling() external {
        require(msg.sender == address(proposalFactory), "Unauthorized.");
        storeSellingEnabled = !storeSellingEnabled;
        emit StoreSellingToggled(storeSellingEnabled);
    }

    /// @notice 发起提案, 在商店中陈列新的 CP Token.
    function proposeListCP(uint256 tokenId, uint256 price) external {
        proposalFactory.createListCPProposal(tokenId, price);
    }

    /// @notice 在商店中陈列新的 CP Token 逻辑. 提案通过后自动调用.
    function listCP(uint256 tokenId, uint256 price) external {
        require(msg.sender == address(proposalFactory), "Unauthorized.");
        require(cp.ownerOf(tokenId) == address(this), "Treasury does not own this CP.");
        cpPrices[tokenId] = price;
        listedCPs.push(tokenId);
        emit CPListed(tokenId, price);
    }

    /// @notice 用户使用 CT 购买商店中的 CP Token (如果商店开启且购买功能启用).
    function buyCP(uint256 tokenId, uint256 providedCT) external {
        require(storeOpen, "Store is closed.");
        require(storeBuyingEnabled, "Store buying is disabled.");
        uint256 price = cpPrices[tokenId];
        require(price > 0, "CP not listed in store.");
        require(providedCT >= price, "Insufficient CT provided.");
        require(ct.transferFrom(msg.sender, address(this), providedCT), "CT transfer failed.");
        cp.transferFrom(address(this), msg.sender, tokenId);
        if (providedCT > price) {
            // 退还多余的 CT
            require(ct.transfer(msg.sender, providedCT - price), "CT refund failed.");
        }
        // 从商店中移除该 CP
        for (uint i = 0; i < listedCPs.length; i++) {
            if (listedCPs[i] == tokenId) {
                listedCPs[i] = listedCPs[listedCPs.length - 1];
                listedCPs.pop();
                break;
            }
        }
        delete cpPrices[tokenId];
    }

    /// @notice 用户将 CP Token 出售给商店以换取 CT (如果商店开启且出售功能启用).
    /// CT 价格为 (0, avg) 开区间内随机取值, 随机的种子值为当前区块高度.
    /// avg 为当前陈列的所有 CP 价格的平均值.
    function sellCPs(uint256[] memory tokenIds) external {
        require(storeOpen, "Store is closed.");
        require(storeSellingEnabled, "Store selling is disabled.");
        require(listedCPs.length > 0, "No CPs listed in store.");

        // 计算平均价格
        uint256 totalPrice = 0;
        for (uint i = 0; i < listedCPs.length; i++) {
            totalPrice += cpPrices[listedCPs[i]];
        }
        uint256 a = totalPrice / listedCPs.length; // a: 平均价格

        // 对用户要出售的每个 CP, 计算随机 CT 价格, 然后求和
        uint256 totalCT = 0;
        uint256 seed = block.number;
        for (uint i = 0; i < tokenIds.length; i++) {
            // 通过 keccak256 算法产生随机数.
            uint256 random = uint256(keccak256(abi.encodePacked(seed, i, msg.sender))) % a;
            totalCT += random;
            cp.transferFrom(msg.sender, address(this), tokenIds[i]); // 转移 CP 到委员会金库.
        }

        // 检查委员会金库是否有足够的 CT 支付
        require(ct.balanceOf(address(this)) >= totalCT, "Treasury has insufficient CT.");

        // 支付 CT 给用户
        require(ct.transfer(msg.sender, totalCT), "CT transfer failed.");
    }

    /// @notice Send ETH (internal, for committee remove stake).
    function sendETH(address to, uint256 amount) external {
        require(msg.sender == address(committee), "Only committee can send ETH.");
        (bool success, ) = payable(to).call{value: amount}("");
        require(success, "ETH transfer failed.");
    }
}
