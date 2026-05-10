#import "mancls.typ": mancls

#mancls(title: "宠物商店 V1.0", author: "宠物商店 V1.0")[

= 软件总体描述

== 软件名称及版本

软件中文名称：宠物商店

软件英文名称：Pet Shop DApp

版本号：V1.0

== 软件用途及适用范围

宠物商店（Pet Shop DApp）是一个基于区块链技术的去中心化宠物交易应用，用户可以在平台上铸造（创建）自己的宠物 NFT（非同质化代币）、管理宠物资产、与其他用户进行宠物交易，并可在内置交易所中完成 ETH 与自定义代币（CT）之间的兑换。该软件面向对区块链数字资产有兴趣的个人用户，构建了一个安全、透明、可验证的宠物数字资产交易生态系统。

== 运行环境

- *操作系统:* Windows、macOS、Linux 等主流操作系统
- *浏览器:* 支持 Web3 功能的现代浏览器（Chrome、Firefox、Edge 等）
- *区块链网络:* Ephemery 测试链（Chain ID: 39438155）或本地 Anvil 测试链（Chain ID: 31337）
- *前端运行环境:* Node.js 16.0 及以上版本，pnpm 包管理器
- *后端运行环境:* 以太坊虚拟机（EVM）兼容的区块链节点
- *其他依赖:* Web3 钱包插件（如 MetaMask）用于与区块链交互

= 软件技术架构

== 系统架构概述

宠物商店采用前后端分离的去中心化应用（DApp）架构。前端为基于 React + TypeScript + Vite 构建的 Web 应用，通过 wagmi 和 RainbowKit 与区块链上的智能合约进行交互。后端为部署在以太坊虚拟机（EVM）兼容区块链上的一组 Solidity 智能合约，承载所有核心业务逻辑和数据。

#align(center)[
```text
用户浏览器 → Web3 钱包（MetaMask 等）
           ↓
React Web 应用（前端交互层）
           ↓
wagmi / RainbowKit（Web3 接口层）
           ↓
Solidity 智能合约（业务逻辑层）
           ↓
EVM 区块链网络（数据持久层）
```
]

== 后端技术栈

- *智能合约语言:* Solidity 0.8.24
- *开发框架:* Foundry（Forge、Cast、Anvil）
- *标准库:* OpenZeppelin Contracts v5（ERC-20、ERC-721、ERC-721URIStorage、ERC-721Enumerable）
- *区块链网络:* Ethereum 兼容链（支持 EVM）

*智能合约模块划分:*

宠物商店后端由 6 个核心智能合约组成，分为 3 个功能层次：

+ *代币层（Token Layer）:*
  - CustomToken.sol — ERC-20 同质化代币（CT），用于交易支付
  - CustomPet.sol — ERC-721 非同质化代币（宠物 NFT），支持元数据存储
+ *业务层（Business Layer）:*
  - Exchange.sol — ETH/CT 代币双向兑换交易所
  - Trade.sol — 点对点宠物交易合约
  - TradeFactory.sol — 交易创建与工厂管理
+ *查询层（Query Layer）:*
  - Viewer.sol — 用户资产与交易状态查询

== 前端技术栈

- *核心框架:* React 19 + TypeScript（严格模式）
- *构建工具:* Vite
- *包管理器:* pnpm
- *Web3 交互:* wagmi v2 + RainbowKit + viem
- *状态管理:* TanStack Query（React Query）
- *路由:* React Router v6
- *样式:* Tailwind CSS + shadcn/ui 组件库
- *IPFS 上传:* Pinata SDK

= 功能详细说明

== 钱包连接功能

*功能描述:* 用户通过 Web3 钱包（如 MetaMask）连接应用，获取区块链身份后即可访问所有功能模块。

*实现方式:* 前端通过 RainbowKit 提供统一的连接 UI，用户点击连接按钮后，Wagmi 负责管理钱包连接状态，连接信息（账户地址等）通过 React Context 传递给各页面组件。

*相关文件:* pages/index.tsx、components/wallet/ConnectButton.tsx、lib/wagmi.tsx

#image("pic/0.png")

== 宠物管理功能

*功能描述:* 登录用户可以铸造（创建）新的宠物 NFT，并可将已有的宠物 NFT 销毁。

*铸造流程:* 用户填写宠物名称、描述并上传图片后，前端将图片上传至 IPFS（通过 Pinata 服务），生成图片 URI；随后创建包含名称、描述和图片 URI 的 JSON 元数据文件，上传至 IPFS 生成元数据 URI；最后调用 CustomPet 合约的 mint 函数，将元数据 URI 与用户钱包地址绑定，完成宠物 NFT 的铸造。

*销毁流程:* 用户输入要销毁的宠物 Token ID，调用 CustomPet 合约的 burn 函数完成销毁。

*列表查看:* 通过 Viewer 合约的 getOwnedCPs 函数查询用户拥有的所有宠物 NFT，以表格形式展示 Token ID 和 Token URI。

*相关文件:* pages/pet-manage.tsx、hooks/Viewer.ts、hooks/CustomPet.ts

#image("pic/1.png")

== 代币兑换功能

*功能描述:* 用户可以在内置交易所中将 ETH 兑换为 CT 代币，或将 CT 代币兑换回 ETH。

*兑换规则:* 兑换汇率由 Exchange 合约中的参数 $k$ 决定（1 CT = $k$ wei ETH），由委员会负责动态调整。用户输入兑换的 CT 数量后，系统根据当前汇率计算出对应的 ETH 金额（以太坊 wei 单位）。

*ETH → CT 兑换:* 用户向 Exchange 合约发送指定数量的 ETH，合约按汇率计算应铸造的 CT 数量并转入用户钱包。

*CT → ETH 兑换:* 用户调用 exchangeCTToETH 函数，燃烧（销毁）指定数量的 CT，合约从其 ETH 余额中按汇率转出对应的 ETH 给用户。

*相关文件:* pages/exchange.tsx

#image("pic/2.png")

== 宠物交易功能

*功能描述:* 用户之间可以进行点对点的宠物 NFT 交易，卖方创建交易并存入宠物 NFT，买方支付 CT 代币完成交易。

*交易创建:* 卖方指定买方地址、交易有效期（秒）和 CT 价格后，由 TradeFactory 合约部署一个新的 Trade 合约实例。

*存款宠物:* 卖方调用 Trade 合约的 depositCP 函数，将一个或多个宠物 NFT（Token ID 列表）转入交易合约地址托管。

*确认交易:* 买方首先需要授权 Trade 合约可以使用自己的 CT 代币（approve），然后调用 confirm 函数完成支付。Trade 合约将卖方的 CT 转给卖方，同时将托管的宠物 NFT 转给买方。

*取消交易:* 在交易有效期内，卖方可随时调用 cancel 函数取消交易，合约将托管的宠物 NFT 退还给卖方。

*过期处理:* 超过有效期后，任何人都可以调用 expire 函数处理过期交易，合约将托管的宠物 NFT 退还给卖方。

*相关文件:* pages/trade.tsx、contracts/Trade.sol、contracts/TradeFactory.sol

#image("pic/3.png")

== 用户资产与交易查询功能

*功能描述:* 登录用户可以查看自己拥有的所有宠物 NFT 列表，以及自己作为买方或卖方参与的所有交易记录。

*查询方式:* 前端通过 Viewer 合约提供的一系列只读函数进行查询：

- getOwnedCPs — 获取用户拥有的所有宠物及 URI
- getUserSellingTrades — 获取用户作为卖方的所有交易
- getUserBuyingTrades — 获取用户作为买方的所有交易
- getUserAllTrades — 获取用户参与的所有交易（买卖双方合计）

*相关文件:* pages/viewer.tsx、contracts/Viewer.sol、hooks/Viewer.ts

#image("pic/4.png")

= 软件数据流

== 宠物铸造数据流

用户提交宠物信息 → 前端上传图片至 IPFS → 前端上传元数据至 IPFS → 调用 CustomPet.mint() 合约方法 → 区块链记录宠物 NFT 所有权

== 交易流程数据流

卖方创建交易（TradeFactory.createTrade）→ 卖方授权 Trade 合约使用 CT（CustomToken.approve）→ 卖方存款宠物（Trade.depositCP）→ 买方授权 Trade 合约使用 CT（CustomToken.approve）→ 买方确认交易（Trade.confirm）→ 区块链完成 CT 和宠物 NFT 的双向转移

= 软件接口说明

== 主要合约接口

=== CustomPet 合约

- *mint(address to, string memory uri)* — 铸造新宠物 NFT
- *burn(uint256 tokenId)* — 销毁宠物 NFT
- *balanceOf(address owner)* — 查询用户宠物数量
- *tokenOfOwnerByIndex(address owner, uint256 index)* — 按索引获取用户宠物 ID
- *tokenURI(uint256 tokenId)* — 获取宠物元数据 URI

=== CustomToken 合约

- *mint(address to, uint256 amount)* — 铸造 CT 代币
- *burn(address from, uint256 amount)* — 销毁 CT 代币
- *balanceOf(address account)* — 查询代币余额
- *transfer(address to, uint256 amount)* — 转账
- *approve(address spender, uint256 amount)* — 授权

=== Exchange 合约

- *exchangeETHToCT()* — 用 ETH 兑换 CT（payable）
- *exchangeCTToETH(uint256 ctWeiAmount)* — 用 CT 兑换 ETH
- *adjustK(uint256 newK)* — 调整汇率
- *k()* — 查询当前汇率

=== Trade 合约

- *depositCP(uint256[] memory tokenIds)* — 卖方存入宠物
- *confirm()* — 买方确认交易并支付
- *cancel()* — 卖方取消交易
- *expire()* — 处理过期交易

= 用户界面说明

宠物商店 Web 应用包含以下页面：

+ *首页（Wallet Page）:* 应用入口页面，显示钱包连接按钮，提示用户连接钱包后使用。路由：/

  #image("pic/0.png")

+ *用户资产页（Viewer Page）:* 展示当前用户拥有的所有宠物 NFT 列表（Token ID、Token URI）以及参与的所有交易记录（交易地址、角色）。路由：/viewer

  #image("pic/1.png")

+ *代币兑换页（Exchange Page）:* 提供 ETH/CT 双向兑换功能，展示用户 ETH/CT 余额和当前汇率。路由：/exchange

  #image("pic/2.png")

+ *宠物交易页（Trade Page）:* 支持创建新交易、存款宠物、确认/取消/过期处理等交易全生命周期管理，以表格形式展示所有相关交易。路由：/trade

  #image("pic/3.png")

+ *宠物管理页（Pet Manage Page）:* 提供宠物 NFT 的铸造（Mint）和销毁（Burn）功能，并展示当前钱包的宠物列表。路由：/pet-manage

  #image("pic/4.png")

所有页面共享统一的主布局（MainLayout），包含顶部导航栏（宠物商店名称及五个页面导航链接）和底部版权信息。

= 软件使用方式

+ 使用本 DApp 前, 需要先连接钱包 (在Wallet Page).

  #image("pic/5.png")
  
+ 在自己的钱包 App 中确认连接.

  #image("pic/6.png")
  
+ 随后再前往各界面, 即可正常操作.

  #image("pic/7.png")
  
  #image("pic/8.png")
  
  #image("pic/9.png")
  
  #image("pic/10.png")

= 关键算法及业务流程

== 代币兑换算法

Exchange 合约的兑换算法如下：

- *ETH → CT:* $"ctAmount" = "ethWeiAmount" times 10^18 / k$
- *CT → ETH:* $"ethWeiAmount" = "ctWeiAmount" times k / 10^18$

其中 $k$ 为汇率参数（1 CT 对应的 ETH wei 数量），初始值由合约部署时设定，可通过 adjustK 函数动态调整。

== 宠物交易业务流程

宠物交易业务流程如图所示：

#align(center)[
```text
开始
  ↓
卖方创建交易（TradeFactory.createTrade）
  ↓
卖方是否存入宠物？
  ├─ 是 → 调用 Trade.depositCP → 交易状态 active=true
  ├─ 否 → 交易状态 active=true
  └─ 取消 → 卖方是否取消交易？
          └─ 是 → 调用 Trade.cancel → 交易终止，宠物 NFT 退回卖方

交易状态 active=true
  ↓
买方是否确认交易？
  ├─ 是 → 调用 Trade.confirm → 交易完成，CT 与宠物 NFT 互换
  └─ 否 → 交易是否已过期？
          └─ 是 → 调用 Trade.expire → 交易终止，宠物 NFT 退回卖方
```
]

= 数据存储说明

宠物商店的数据存储分为链上和链下两部分：

- *链上存储:* 所有核心业务数据（宠物 NFT 的所有权、代币余额、交易状态、汇率参数等）存储在以太坊虚拟机区块链上，由各智能合约的状态变量管理，数据一经确认不可篡改。
- *链下存储:* 宠物图片和元数据文件存储在 IPFS（InterPlanetary File System）分布式存储网络中，前端仅存储指向 IPFS 资源的 URI 链接。这种设计既保证了数据去中心化，又降低了链上存储成本。

= 安全措施说明

宠物商店在设计与实现中采取了以下安全措施：

+ *权限控制:* 关键操作均通过 require 语句进行访问控制检查，如 depositCP 仅允许卖方调用，confirm 仅允许买方调用，cancel 和 expire 均有严格的角色和时间条件限制。
+ *余额验证:* Exchange 合约在 CT→ETH 兑换前检查合约 ETH 余额是否充足，防止因流动性不足导致转账失败。
+ *低级别调用检查:* 对 transferFrom 等低级别调用进行成功与否的检查（bool success），确保操作实际完成后才继续执行。
+ *整数运算:* 兑换计算中使用 $10^18$（1 ether）作为精度因子，防止小数精度丢失问题。
+ *前端输入验证:* 前端组件对用户输入进行必要性检查（如宠物名称、描述、图片文件的存在性），在提交按钮上设置 disabled 状态防止空值提交。

= 使用限制及注意事项

+ 本软件目前部署在 Ephemery 测试链上，测试网上的资产无实际价值，仅供功能验证使用。
+ 用户需要自行准备 Web3 钱包（如 MetaMask）并确保钱包中有足够的测试 ETH 用于操作。
+ 交易有效期设置不宜过短，应确保买方有充足时间检查交易并完成支付。
+ 宠物图片和元数据通过 Pinata 服务上传至公共 IPFS 网络，上传内容将被公开访问，请勿上传敏感信息。
+ 智能合约一旦部署便无法修改，业务逻辑漏洞可能导致不可挽回的资产损失，请勿在生产环境未经审计的情况下使用。

]
