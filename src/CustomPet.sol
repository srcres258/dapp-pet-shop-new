// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ProposalFactory} from "./ProposalFactory.sol";

/**
 * @title CustomPet 宠物代币
 * @author srcres258
 * @notice ERC-721 代币 CustomPet. 该代币的铸造与销毁由委员会管理.
 */
contract CustomPet is ERC721URIStorage, ERC721Enumerable {
    ProposalFactory public proposalFactory = ProposalFactory(address(0));
    uint256 private _tokenIdCounter;

    constructor() ERC721("CustomPet", "CP") {}

    modifier requiresProposalFactorySet() {
        _requiresProposalFactorySet();
        _;
    }

    function _requiresProposalFactorySet() private view {
        require(address(proposalFactory) != address(0), "ProposalFactory has not been set yet.");
    }

    /// @notice 设置 ProposalFactory 地址.
    function setProposalFactory(ProposalFactory _proposalFactory) external {
        proposalFactory = _proposalFactory;
    }

    /// @notice 发起提案, 使用 URI 铸造新的 Token.
    function proposeMint(address to, string memory uri) external requiresProposalFactorySet {
        // Only committee members, checked in factory.
        proposalFactory.createMintCPProposal(to, uri);
    }

    /// @notice 真正的 Token 铸造逻辑. 提案通过后自动调用.
    function mint(address to, string memory uri) external requiresProposalFactorySet {
        require(msg.sender == address(proposalFactory), "Unauthorized.");
        uint256 tokenId = _tokenIdCounter++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    /// @notice 发起提案, 销毁指定的 Token.
    function proposeBurn(uint256 tokenId) external requiresProposalFactorySet {
        // Only committee members, checked in factory.
        proposalFactory.createBurnCPProposal(tokenId);
    }

    /// @notice 真正的 Token 销毁逻辑. 提案通过后自动调用.
    function burn(uint256 tokenId) external requiresProposalFactorySet {
        require(msg.sender == address(proposalFactory), "Unauthorized.");
        _burn(tokenId);
    }

    /* 注: 由于继承了 ERC721Enumerable, 需要重写以下函数. */

    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function destroy(uint256 tokenId) external requiresProposalFactorySet {
        require(msg.sender == address(proposalFactory), "Unauthorized");
        _burn(tokenId);
    }

    function _increaseBalance(address account, uint128 amount) internal virtual override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, amount);
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        virtual
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }
}
