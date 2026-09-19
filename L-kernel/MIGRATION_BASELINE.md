# L-kernel 源码保全与切割项目基线

状态：**源码盘点与迁移范围已定；先原模块内切割切薄，后迁内核；本文件不批准生产接入或部署。** 盘点基线为桌面仓库 `/Users/Ethan/Desktop/zdt-next`、分支 `codex/L-kernel`、HEAD `4562a7a15818`，另有尚未提交的会员目录本地切割。此文件是工作地图，不是新的 LAW、接口契约、节点权威或安全门禁。

## 项目决定

目标不是把约 30 万行源码重写一遍，也不是把各模块整目录搬进 `L-kernel`。**最大限度保留原代码和原业务事实：只按职责切出真正共用的原实现，原调用点切薄；原样行为核对后，再单独修改 Ethan 已确认的新规则。** 不新造已有算法、状态机、数据库事实、节点模型、契约平台或页面。登录、订单、地址、导入、OP 和前端 VI 不因 MB 切割被吸入 MB 内核。

分类标记：`原位复用`＝现有代码继续作为唯一实现，不搬；`切割候选`＝从混合文件抽出一段原逻辑，尚未切时不能称为完成；`已切待验`＝已移出原逻辑，但还要继续核对等价与真实节点接线；`留在边界`＝它是必要依赖/适配器，但不是 MB 领域核心；`新增缺口`＝现有范围没有可确认的原实现，不得伪装成迁移。

## 全仓可保留的现有骨架

| 分类 | 现有代码与事实 | 保留方式及本轮证据 |
| --- | --- | --- |
| 原位复用 | `01_core_hexin/packages/config/src/SflNodeKernel.ts` 的 Node、Realm、Membership、父链、开店/升级请求与解析器 | 继续作为 SFL 节点模型来源；`L-kernel` 不复制第二套节点类型。 |
| 原位复用 | `01_core_hexin/packages/kernel/src/module_jiexianban/ModuleManifest.ts`、`ModuleCatalog.ts` | 保留已有模块描述与依赖解析器；当前检索到的 `new ModuleCatalog` 只在自身测试，不把“可用代码”误报为运行时已装配。 |
| 原位复用 | Commerce 现有 **35 个** `module.manifest.ts` 和各领域模块 | 保留现有模块所有权，不复制 35 份到新目录；先从 MB 切片验证薄接入，其他板块不动。 |
| 原位复用 | `@shop/contract`、`@shop/sdk`；并存的 `@smart-wing/api-contract` | 保留各自真实调用者，当前不做全局契约合并。后者的 `memberCode.ts` 是 **45 秒动态核验码协议**，不是永久 MB 身份码。 |
| 原位复用 | `AuthoritativeNodeContextResolver.ts`、现有 Host→NodeContext 路径、`identity.resolve_storefront_member_context` | 服务端可信入口与会员节点投影继续使用；不能用域名、前端配置或新 JSON 取代权威解析。 |
| 原位复用 | `organization.register_hosted_member_node`、`organization.membernoderegistration`、现有节点/会员数据库 Schema 与迁移 | SQL 和存储事实留在数据库适配层；不翻译为第二套 TypeScript 写入模型。 |
| 原位复用 | identity/account/session、access/permission/scope、`identity-display` 中的 OP 路径 | OP、认证及现有权限体系保持原实现；MB 切割不顺手修改或削弱。 |
| 原位复用 | order、purchase、cart、checkout、inventory、fulfillment、payment、finance、referral 等现有领域模块 | 四流仍由各自写入 Owner 持有；MB 只引用完整身份/节点事实，不把订单、资金和履约状态机搬入会员核心。 |
| 原位复用 | support、notification、现有 outbox/event 基础 | 客服和通信能力留在对应模块；不为 OP 跨店留言新造消息总线，更不把通信变成跨店管理权。 |
| 原位复用 | Console/H5 现有路由、会员页面、`IdentityBadge`、CSS/VI 与 `ConsoleModuleRegistry` | 前端原样保留；本阶段不改 VI、页面布局或交互。现有 UI Manifest 不等于已由单一后端 Manifest 自动装配。 |
| 原位复用 | 现有测试、PG17 夹具与 ERA 2.0 E01–E12 证据 | 当作回归参照和历史证据，不改成新业务规则或发布门禁。报告是 `MET / DEV VERIFIED / NOT REVIEWED`，不证明本次迁移或 H6 生产继承。 |
| 留在边界 | 部署、Runner、CDN、节点运行配置、Provider Extension | 它们仍在原层；不吸入 L-kernel，也不按审计设计稿重建发布系统。 |

35 个现有 Commerce Manifest 全部原位保留：`access`、`audit`、`benefit`、`capability`、`cart`、`catalog`、`channel`、`checkout_jiesuan`、`experience`、`extension`、`finance`、`fulfillment`、`identity`、`inventory`、`mall`、`marketing`、`member`、`notification`、`observability`、`order_dingdan`、`organization`、`partner`、`payment_zhifu`、`pricing`、`provisioning`、`purchase`、`qualification`、`referral`、`reporting`、`risk`、`runtime`、`support`、`verification`、`voucher`、`webbusiness`。这表示**保留范围**，不是宣称已经逐文件完成行为审计。

## MB 会员源码逐片标注

| 分类 | 源位置 | 处理边界 |
| --- | --- | --- |
| 已切待验 | `MemberCustomProfileOperations.ts` 的字段配置/值校验 → `L-kernel/src/member/MemberProfileRules.ts` | 原业务规则已切出、原操作调用共用函数；余下配置读取、SQL 写入和 HTTP 操作留原位。继续核对行为等价，不连带改档案存储。 |
| 原模块已切待验 | `MemberDirectoryReader.ts` 原商城会员目录 SQL → `member/04_adapters_shixian/persistence/MemberDirectoryQuery.ts` | 原 SELECT、筛选与参数顺序按原文切出，Reader 只负责用原数据库执行；尚未迁入内核，未据此宣称真实 L0/L1/H6 都继承。 |
| 原模块已切待验 | `MemberReadOperations.ts` 的会员详情 SQL → `member/04_adapters_shixian/persistence/MemberDetailReader.ts` | 原 SQL 逐字切出，范围检查、展示组合和响应合同留原动作；详情含订单统计，暂不迁内核。 |
| 切割候选 | `MemberReadOperations.ts` 的邀请关系、其他只读投影 | 逐个区分 MB 事实与管理员目录、订单视图；原路由/权限上下文留原位，不整文件搬家。 |
| 切割候选 | `RegistrationOperations.ts` 中 MB 登记片段、`MemberPort.registerHostedMemberNode` | 现有注册文件混合账号/凭据/OP/MB；先标出创建节点、Membership 和父链的原调用，再切 MB 事实编排。登录和 Session 不进 MB 核心；“已有账号”分支须单独核对。 |
| 切割候选 | `MemberCustomProfileOperations.ts` 其余 MB 档案业务规则、`MemberOperations.ts` 的 `member.profile.read` | 只在识别出原有独立规则时切出；`member.profile` 与 `access.membership` 仍是当前事实，不另建平行档案表。 |
| 留在边界 | `MemberPort.ts` 的 SQL 适配、`MemberModule.ts`、`member/index.ts`、`MemberCapabilities.ts`、`member/module.manifest.ts` | 保留现有接口和模块声明；在需要时把原调用切薄，不重复造公共 Port 或第二套 Manifest。 |
| 留在边界 | `MemberOperations.ts` 的地址动作、`MemberImportOperations.ts`、`MemberProfileImport.ts`、`MemberImportJob.ts`、`PgMemberImport.ts` | 地址和导入按 Ethan 决定保持独立；它们可能消费 MB 身份，但不属于基础 MB 内核。 |
| 留在边界 | `IdentityOperatorMemberModule.ts`、`MemberReadOperations.ts` 的管理员目录及 `withMemberIdentityDisplays` | OP 与 MB 分开审视；不因同处 `member` 目录而将管理逻辑移入 MB。 |
| 留在边界／待核 | `HostedMallOpeningOperation.ts`、`SovereignUpgradeOperation.ts` 与原 SFL 开店/升级 SQL | 暂保留原编排。最新产品讨论与现行 SFL 核心标准对“原节点升级/申请新店并平移关系”的表述有差异；先列精确事实与差异，不贸然切改历史血缘。 |
| 留在边界 | `MemberReadOperations.ts` 的 `member.storefront.orders.read` | 订单展示仍从订单事实读取，订单及退款写入 Owner 不随 MB 目录迁移。 |
| 原位复用 | `member/06_tests_ceshi/` 原有目录、读取、Port、自定义档案测试 | 原测试保留作为切割前后比对；不以新增 mock 单测替代原 SQL/节点路径回归。 |
| 切割候选＋定点升级 | `identity-display/IdentityCode.ts`、`IdentityDisplayPresenter.ts`、`IdentityDisplayContract.ts` 和 `identity_display.code_mapping` | 当前 OP4/MB6 共用实现，不能整块删除或重写。先切清 MB 原展示路径并保留 OP；等价后再按已确认的 MB 4+4 全域规则**单独**修改，旧六位 MB 在切换时直接失效、不留兼容。 |
| 新增缺口 | 全域 ST 前四位＋本店 MB 后四位的一次性分配、可撤回的跨 ST MB 资料共享 | 本轮在 MB/identity-display 路径未找到可直接平移的等价实现；先完成更广的来源核对，再定义最小新增部分。此前新写的分配器已撤回，未接入。 |

## 节点与审计边界

- 当前配置 `02_platform_pingtai/infrastructure/projects_xiangmu/hbbtzn/deployment/aliyun.yml` 把 `h6.hbbtzn.com` 列为 L1 storefront alias，声明 `node:hbbtzn:l1 / realm:l1` 和共享业务宿主。**H6 目标为 L2，不代表现在已经是独立 Hosted L2。** 文件只能证明版本库声明，生产现状需单独观察。
- 同一配置声明 `databaseTopology: shared-host-database`；Ethan 希望各 L-kernel 最终有独立数据库，这是目标差距，不得写成已实现。SFL 现行标准仍把 L0～L11 视为同类节点的不同管理段；本次 ST/MB 是身份和能力切片，不另建一套 L 节点权威。
- ERA 2.0 正式重测报告的证据基线是 `3fce7f…`，本盘点 HEAD 是 `4562a7…`；其 E01–E12 是开发环境、合成/局部样本的保证，不给本轮改动背书，也不应变成新的实施门禁。
- `L kernel 中枢`任务的中央架构底稿基于较早 `d388f09…`，有值得保留的 ModuleCatalog、领域 Schema、Node/Realm/Host 区分等观察；其中“内核只含无业务主板”与 Ethan 本次“先建设 L-kernel 下 MB 切片”应以当前明确决定为准。本文将公共骨架与 `L-kernel/member` 分层，不把其他业务规则硬塞入公共主板。
- 现行 [SFL 核心标准](../05_docs_ziliao/docs_wendang/governance/standards/02-SFL核心标准.md) 将四流定义为订单、商品、现金、财务，并规定各流保持各自写入所有者；本轮不因“吸星大法”合并四流写入表或历史交易。

## 后续切割顺序与记录格式

1. 先冻结本表中的原路径、调用者、数据库事实和原测试；只读查清后再选一段可共用原逻辑。
2. 先在**原模块内**把原代码按职责切出并保留行为；原位置仅改为薄委托。逐片记录原路径→新路径、是否逐字/语义一致、测试和数据库证据。
3. 等这片切割验明，再把已确定的新规则作为**独立改动**处理，列出行为差异；不以“迁移”名义暗改身份、父链、订单或权限。
4. MB 内核完成后才分别验证 L0、L1、H6 的真实节点绑定。代码已抽出、测试已模拟、接口已接入、生产已部署是四种不同状态，分别报告。

本轮建立项目范围和源码复用地图，并只在原 `member` 模块内切薄目录与详情查询；未迁入内核、未改变原路由、未提交、未部署。详细产品决定见 [`member/WORKING_AGREEMENTS.md`](member/WORKING_AGREEMENTS.md)。

关键源码入口：[`SflNodeKernel.ts`](../01_core_hexin/packages/config/src/SflNodeKernel.ts)、[`ModuleCatalog.ts`](../01_core_hexin/packages/kernel/src/module_jiexianban/ModuleCatalog.ts)、[`MemberOperations.ts`](../01_core_hexin/services/commerce/src/modules/member/03_application_yingyong/MemberOperations.ts)、[`MemberReadOperations.ts`](../01_core_hexin/services/commerce/src/modules/member/03_application_yingyong/MemberReadOperations.ts)、[`MemberPort.ts`](../01_core_hexin/services/commerce/src/modules/member/01_public_gongkai/MemberPort.ts)、[`RegistrationOperations.ts`](../01_core_hexin/services/commerce/src/modules/identity/05_interface_jieru/http/RegistrationOperations.ts)、[`MemberDirectoryQuery.ts`](../01_core_hexin/services/commerce/src/modules/member/04_adapters_shixian/persistence/MemberDirectoryQuery.ts)、[`identity-display/IdentityCode.ts`](../01_core_hexin/services/commerce/src/modules/identity-display/IdentityCode.ts)、[`H6/L1 运行声明`](../02_platform_pingtai/infrastructure/projects_xiangmu/hbbtzn/deployment/aliyun.yml)。
