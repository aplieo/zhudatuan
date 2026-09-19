# 会员系统源码切割框架

状态：工作框架，不是新合同或第二套事实源。执行顺序按 Ethan 最新决定：**先在原会员模块内切割并切薄，再考虑把合格切片移入 L-kernel**。先前已经迁入内核的 `MemberProfileRules.ts` 暂时保留，不为追求形式上的顺序再折返或重写。

## 原代码的五个位置

| 现有位置 | 保留职责 | 本次处理 |
| --- | --- | --- |
| `01_public_gongkai/` | `MemberPort`、能力出口和原接口 | 保留；只在确有必要时让内部调用更薄，不建第二个 Port |
| `03_application_yingyong/` | 请求编排、原操作 ID、已有作用域与响应 | 原路由和请求/响应不变；把混在动作里的原 SQL、纯规则按职责切出 |
| `04_adapters_shixian/` | 原 SQL、数据库与外部服务调用 | 原样承接从应用动作切出的持久化代码；仍由原数据库执行，不创建新事实表 |
| `05_interface_jieru/` | 模块入口、HTTP/Jobs 连接 | 原样保留，不因为分层而重画页面或重配入口 |
| `06_tests_ceshi/` | 原行为测试、节点/数据库夹具 | 保留并复跑，用于比较切割前后；模拟节点不能冒充真实继承 |

这里的“薄”只表示动作层不再同时承载大段 SQL、UI/权限/登录/订单等无关实现。**切薄不是减少业务规则，也不是换算法。** 原事务边界、SQL 文本、参数顺序、返回字段、错误码与现有权限调用保持原样；任何变更都要作为后续独立升级说明。

## 按职责划线，不整文件搬家

| 原文件/调用 | 会员可切片 | 留在原处的边界 |
| --- | --- | --- |
| `MemberDirectoryReader.ts`、`MemberReadOperations.ts` | 本店 MB 目录查询；之后逐项考察详情和邀请关系只读投影 | 原 HTTP 动作、Scope/分页/合同解析；管理员目录、订单视图仍分开 |
| `MemberCustomProfileOperations.ts` | 已有字段校验；以后仅切出独立的 MB 档案业务规则 | 配置/档案 SQL、请求上下文和操作入口仍在原模块 |
| `RegistrationOperations.ts` 与 `MemberPort.registerHostedMemberNode` | 仅现有 MB 登记事实的编排候选 | Account、Credential、OP 登记、Session、短信/微信、登录流程均留原 Owner；SFL 节点函数直接复用 |
| `MemberOperations.ts` | `member.profile.read` 的原资料读取可单独核对 | 地址动作和 `member.malls.open`/主权升级入口不自动属于 MB 核心 |
| `HostedMallOpeningOperation.ts`、`SovereignUpgradeOperation.ts` | 暂不切 | 节点/开店领域现有编排先保留，历史关系语义未核清前不动 |
| `MemberImportOperations.ts`、`MemberProfileImport.ts`、`PgMemberImport.ts`、`MemberImportJob.ts` | 暂不切 | 导入是独立外围能力，不吸进 MB 基础事实 |
| `identity-display/IdentityCode.ts`、`IdentityDisplayPresenter.ts` | 后续先区分原 OP/MB 展示路径，再切原 MB 片 | OP 原路径必须保留；4+4 是之后的定点规则修改，不是源代码切割本身 |

## 三步执行，不混成一次重写

1. **原模块内切割**：确定一段原代码的输入、输出、SQL/事务及调用者；移动原文到原模块内对应文件，原调用只留下转发。原测试及直接相关测试通过，记录差异为零或精确列差异。
2. **源模块切薄**：确认混合文件不再承担该片内部细节，但它仍保留原路由、会话/权限边界和响应。任何不能无损切出的逻辑继续留在原处，不为了层数强拆。
3. **再迁入 L-kernel**：只移动已验证可共用的切片，并保持原数据库、节点模型及 HTTP 入口作为适配层。先内核代码完成，再分别验收 L0、L1、H6；不从 mock 推断生产继承。

已在原模块内切薄两片：

| 切片 | 原代码 → 原模块内新位置 | 不变证据 | 尚未做的事 |
| --- | --- | --- | --- |
| 本店 MB 目录 | `MemberDirectoryReader.ts` 原 SQL → `04_adapters_shixian/persistence/MemberDirectoryQuery.ts` | 与切割前 SQL 逐字相同（1284 字符），参数顺序不变；Reader 仍用原数据库 | 尚未迁入内核；模拟 L0/L1/H6 不证明真实节点继承 |
| 本店 MB 详情 | `MemberReadOperations.ts` 原 SQL → `04_adapters_shixian/persistence/MemberDetailReader.ts` | 与切割前 SQL 逐字相同（3586 字符），原范围检查/展示/响应仍在动作层 | 详情含邀请和订单统计，是原模块组合视图，不把订单事实吸入 MB 核心 |

邀请、登记及其余动作仍在原处，须各自另列原调用与证据，不能自动套用上述两片结论。

本轮核验：Commerce 类型检查通过；原 `member/06_tests_ceshi` 目录的 6 个测试文件、21 项测试通过；L-kernel 类型检查及现有档案规则测试通过。两段 SQL 均与切割前版本逐字相同。以上不表示真实 L0/L1/H6 已完成继承或生产接入。
