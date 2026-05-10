#import "mancls.typ": mancls, listing

#mancls(title: "宠物商店 V1.0", author: "宠物商店 V1.0", code: true)[

= 后端智能合约

== CustomToken.sol（自定义代币合约）
*文件路径:* src/CustomToken.sol
*文件大小:* 约 0.6 KB
*功能说明:* 基于 ERC-20 标准的自定义代币（CT）合约，负责代币的铸造与销毁操作。该合约是宠物商店生态系统中的核心经济代币，可与 ETH 进行双向兑换。

#listing("src/CustomToken.sol")

== CustomPet.sol（宠物 NFT 合约）
*文件路径:* src/CustomPet.sol
*文件大小:* 约 2.3 KB
*功能说明:* 基于 ERC-721 标准的宠物非同质化代币（NFT）合约，继承 ERC721URIStorage 和 ERC721Enumerable，实现宠物的铸造、销毁、所有权查询及元数据存储功能。

#listing("src/CustomPet.sol")

== Exchange.sol（代币兑换合约）
*文件路径:* src/Exchange.sol
*文件大小:* 约 1.8 KB
*功能说明:* 处理 ETH 与 CT 代币之间双向兑换的交易所合约，按照委员会设定的汇率 $k$ 进行兑换，支持动态调整汇率。

#listing("src/Exchange.sol")

== Trade.sol（交易合约）
*文件路径:* src/Trade.sol
*文件大小:* 约 3.7 KB
*功能说明:* 用户之间的宠物交易合约，支持指定买方、有效期和价格的交易创建，卖方存入宠物 NFT、买方支付 CT 完成交易，以及交易取消和过期处理逻辑。

#listing("src/Trade.sol")

== TradeFactory.sol（交易工厂合约）
*文件路径:* src/TradeFactory.sol
*文件大小:* 约 1.3 KB
*功能说明:* 交易工厂合约，负责创建和管理用户之间的交易实例，维护所有交易记录的地址列表。

#listing("src/TradeFactory.sol")

== Viewer.sol（用户状态查询合约）
*文件路径:* src/Viewer.sol
*文件大小:* 约 3.5 KB
*功能说明:* 用户状态查询合约，提供用户拥有的宠物 NFT 列表查询、用户作为卖方/买方的交易记录查询等功能，方便前端页面展示用户资产和交易状态。

#listing("src/Viewer.sol")

#pagebreak()

= 前端 Web 应用

== main.tsx（应用入口）
*文件路径:* frontend/src/main.tsx
*文件大小:* 约 0.5 KB
*功能说明:* React 应用的主入口文件，负责初始化 Web3 提供者（RainbowKit + Wagmi）、路由（BrowserRouter）并将根组件挂载到 DOM。

#listing("frontend/src/main.tsx")

== App.tsx（路由配置）
*文件路径:* frontend/src/App.tsx
*文件大小:* 约 0.8 KB
*功能说明:* 应用路由配置文件，定义页面路由规则，包括主页（Wallet）、Viewer 页面、Exchange 页面、Trade 页面和 PetManage 页面的路由映射。

#listing("frontend/src/App.tsx")

== index.tsx（钱包连接页面）
*文件路径:* frontend/src/pages/index.tsx
*文件大小:* 约 0.4 KB
*功能说明:* 首页——钱包连接页面，提供 Web3 钱包连接按钮，供用户连接钱包后访问其他功能页面。

#listing("frontend/src/pages/index.tsx")

#pagebreak()

== viewer.tsx（用户资产查看页面）
*文件路径:* frontend/src/pages/viewer.tsx
*文件大小:* 约 2.8 KB
*功能说明:* 用户资产查看页面，展示当前用户拥有的所有宠物 NFT（包含 Token ID 和 Token URI），以及用户参与的所有交易记录及角色（买方/卖方）。

#listing("frontend/src/pages/viewer.tsx")

#pagebreak()

== exchange.tsx（代币兑换页面）
*文件路径:* frontend/src/pages/exchange.tsx
*文件大小:* 约 3.6 KB
*功能说明:* 代币兑换页面，提供 ETH 与 CT 代币之间的双向兑换功能，展示用户 ETH/CT 余额及当前兑换汇率，支持用户输入兑换数量并执行兑换操作。

#listing("frontend/src/pages/exchange.tsx")

#pagebreak()

== trade.tsx（宠物交易页面）
*文件路径:* frontend/src/pages/trade.tsx
*文件大小:* 约 8.4 KB
*功能说明:* 宠物交易管理页面，支持创建新交易（指定买方、有效期、CT 价格）、存款宠物到交易合约、买方确认交易完成支付、卖方取消交易以及过期交易处理等功能。

#listing("frontend/src/pages/trade.tsx")

#pagebreak()

== pet-manage.tsx（宠物管理页面）
*文件路径:* frontend/src/pages/pet-manage.tsx
*文件大小:* 约 6.4 KB
*功能说明:* 宠物管理页面，提供宠物 NFT 的铸造（Mint）功能（上传图片至 IPFS 并设置元数据）和销毁（Burn）功能，以及查看当前钱包地址拥有的所有宠物列表。

#listing("frontend/src/pages/pet-manage.tsx")

#pagebreak()

== wagmi.tsx（Web3 提供者）
*文件路径:* frontend/src/lib/wagmi.tsx
*文件大小:* 约 2.9 KB
*功能说明:* Web3 提供者配置文件，整合 RainbowKit 钱包连接 UI、Wagmi 合约交互库和 TanStack Query，提供完整的 Web3 功能支持，包括多链配置和主题定制。

#listing("frontend/src/lib/wagmi.tsx")

#pagebreak()

== chains.ts（区块链网络配置）
*文件路径:* frontend/src/lib/chains.ts
*文件大小:* 约 1.2 KB
*功能说明:* 区块链网络配置，定义 Ephemery 测试链和本地 Anvil 测试链的网络参数（Chain ID、RPC 地址、原生货币等）。

#listing("frontend/src/lib/chains.ts")

#pagebreak()

== utils.ts（工具函数）
*文件路径:* frontend/src/lib/utils.ts
*文件大小:* 约 0.2 KB
*功能说明:* 通用工具函数，封装 clsx 和 tailwind-merge 的类名合并功能（cn 函数），用于组件中 Tailwind CSS 类名的有条件合并。

#listing("frontend/src/lib/utils.ts")

#pagebreak()

== constants.ts（合约配置）
*文件路径:* frontend/src/constants.ts
*文件大小:* 约 0.8 KB
*功能说明:* 合约配置文件，导入各智能合约的 ABI 定义和已部署合约地址，并配置 Pinata IPFS 服务的 JWT 认证信息。

#listing("frontend/src/constants.ts")

#pagebreak()

== Viewer.ts（Viewer 合约 Hook）
*文件路径:* frontend/src/hooks/Viewer.ts
*文件大小:* 约 2.4 KB
*功能说明:* Viewer 智能合约的 React Hook 封装，提供查询用户拥有的宠物列表（useOwnedCPs）、查询用户所有交易（useUserAllTrades）和查询交易详情（useTradeDetails）的功能。

#listing("frontend/src/hooks/Viewer.ts")

#pagebreak()

== CustomPet.ts（CustomPet 合约 Hook）
*文件路径:* frontend/src/hooks/CustomPet.ts
*文件大小:* 约 2.5 KB
*功能说明:* CustomPet 智能合约的 React Hook 封装，通过 publicClient 查询用户拥有的宠物 NFT 列表，支持实时刷新用户资产数据。

#listing("frontend/src/hooks/CustomPet.ts")

#pagebreak()

== MainLayout.tsx（页面布局组件）
*文件路径:* frontend/src/components/layout/MainLayout.tsx
*文件大小:* 约 1.7 KB
*功能说明:* 应用主布局组件，包含顶部导航栏（Pet Shop DApp 标题及页面导航链接）、页面内容区域（Outlet 渲染子页面）和底部版权信息。

#listing("frontend/src/components/layout/MainLayout.tsx")

#pagebreak()

== ConnectButton.tsx（钱包连接按钮）
*文件路径:* frontend/src/components/wallet/ConnectButton.tsx
*文件大小:* 约 0.3 KB
*功能说明:* 钱包连接按钮组件，封装 RainbowKit 的 ConnectButton，为用户提供连接 Web3 钱包的入口界面。

#listing("frontend/src/components/wallet/ConnectButton.tsx")

#pagebreak()

== button.tsx（按钮组件）
*文件路径:* frontend/src/components/ui/button.tsx
*文件大小:* 约 2.0 KB
*功能说明:* 基于 Radix UI Slot 和 CVA（Class Variance Authority）的按钮组件，支持多种变体（default/destructive/outline/secondary/ghost/link）和尺寸（default/sm/lg/icon）。

#listing("frontend/src/components/ui/button.tsx")

#pagebreak()

== input.tsx（输入框组件）
*文件路径:* frontend/src/components/ui/input.tsx
*文件大小:* 约 0.5 KB
*功能说明:* 表单输入框组件，基于 Radix UI 原语构建，提供统一的文本输入样式。

#listing("frontend/src/components/ui/input.tsx")

#pagebreak()

== label.tsx（标签组件）
*文件路径:* frontend/src/components/ui/label.tsx
*文件大小:* 约 0.3 KB
*功能说明:* 表单标签组件，基于 Radix UI Label 原语构建，提供无障碍访问支持的标签渲染。

#listing("frontend/src/components/ui/label.tsx")

#pagebreak()

== checkbox.tsx（复选框组件）
*文件路径:* frontend/src/components/ui/checkbox.tsx
*文件大小:* 约 0.6 KB
*功能说明:* 复选框组件，基于 Radix UI Checkbox 原语构建，提供可访问的复选框交互功能。

#listing("frontend/src/components/ui/checkbox.tsx")

#pagebreak()

== table.tsx（表格组件）
*文件路径:* frontend/src/components/ui/table.tsx
*文件大小:* 约 0.8 KB
*功能说明:* 表格组件，包含 Table、TableHeader、TableBody、TableRow、TableHead 和 TableCell 等子组件，用于结构化展示宠物列表、交易记录等数据。

#listing("frontend/src/components/ui/table.tsx")

#pagebreak()

== index.css（全局样式）
*文件路径:* frontend/src/index.css
*文件大小:* 约 3.8 KB
*功能说明:* 全局样式文件，引入 Tailwind CSS 和 tw-animate-css，定义 Oklch 色彩系统的主题变量（包括亮色和暗色模式），并配置 Tailwind \@theme 自定义变量。

#listing("frontend/src/index.css")

#pagebreak()

== App.css（应用样式）
*文件路径:* frontend/src/App.css
*文件大小:* 约 0.1 KB
*功能说明:* 应用级别的样式补充文件，用于覆盖或扩展默认样式。

#listing("frontend/src/App.css")

]
