# MB 会员板块：大块边界与全域编码定稿

状态：**大块划分与编码目标已定；尚未执行细切、编码替换或三节点接入。** 本文是切割工作地图，不新增节点、数据库、权限或公共契约权威。现有源码必须先保全并按职责切薄，不能照本文重写业务。

## 证据与适用范围

- [全代码库审计](../../05_docs_ziliao/docs_wendang/architecture/full-codebase-audit-20260913/12-final-summary.md)已并入本仓库。其基线是 2026-09-13 的 `5a1ce71eebbefaa826368a9e1dc17730f9363bc4`；4,238 个基线文件均登记在[覆盖清单](../../05_docs_ziliao/docs_wendang/architecture/full-codebase-audit-20260913/10-coverage-manifest.csv)，不表示每个文件均逐行深审。2026-09-16 新增的 `identity-display` 不在该审计基线内，须按当前源码另查。
- [ERA 2.0 E01–E12 重测](../../05_docs_ziliao/docs_wendang/architecture/19-E2.0-E01-E12正式重测报告.md)按 Ethan 的决定作为 C1/C2 继承参照；现有 ERA 文档未给出 C1/C2 的独立定义，这里不替它造义。当前结论为 `MET / DEV VERIFIED / NOT REVIEWED`，不证明本次切割、真实 L0/L1/H6 继承或生产状态；不能把其历史判据变成本项目新门禁。
- 以当前根 `LAW.md` 启用的 SFL 节点事实、现有数据库和 Ethan 本轮明确决定为准。审计建议只是问题线索，不能自动变成产品规则或源码改动。

## 会员系统的六个大块

| 大块 | 原代码和事实归属 | 进入共用 L-kernel 的部分 | 留在薄边界／平行系统 |
| --- | --- | --- | --- |
| 1. MB 登记与身份归属 | `identity/RegistrationOperations.ts`、`MemberPort.registerHostedMemberNode`、`access.membership`、`organization.register_hosted_member_node` | 从原流程切出 MB 登记事实、归属和状态规则；复用原数据库函数 | Account/Credential、手机/微信、Session、OP 登记与 HTTP 请求编排留在 Identity；不复制注册事务 |
| 2. 节点、父链与关系版本 | `SflNodeKernel.ts`、SFL node/relation/registration SQL 与原测试 | 可复用的节点/父链业务语义由同一 L-kernel 承载，L0/L1/H6 绑定各自权威节点事实 | SQL、事务、Realm 解析与数据库连接仍由原适配层拥有；不建立第二套节点表或三份实现 |
| 3. MB 档案与本店会员关系 | `member.profile`、`access.membership`、`MemberCustomProfileOperations.ts`、`MemberReadOperations.ts` | 已迁入的 `MemberProfileRules.ts` 保留；其余仅切有独立输入/输出的原档案规则与本店关系规则 | 原商城目录/详情查询、配置写入、订单统计、HTTP/SDK/前端视图留在原模块；目录和详情 SQL 已先原样移到原模块适配层 |
| 4. ST 间资料共享 | 现有本店会员目录、邀请与分销关系；目前无等价的跨 ST 共享事实 | 后续新增的“来源 ST 授权、接收 ST 查阅、可撤回”关系语义；原 MB 身份和号码不变 | 共享不转移订单，不自动合并接收店已有 MB；邀请、返佣和订单各由原 Owner 处理。此块不是旧源码平移，须另立最小新增范围 |
| 5. MB 生命周期与开店衔接 | `HostedMallOpeningOperation.ts`、`SovereignUpgradeOperation.ts`、SFL 开店/升级 SQL | 保留原 MB、身份码及历史；只在查清关系平移字段后切出可共用的状态规则 | 开店事务与节点/商城事实仍由原 Owner 执行，不把商城、支付或订单写入 MB 核心 |
| 6. 永久身份码与读展示 | `identity-display/IdentityCode.ts`、`IdentityDisplayPresenter.ts`、`identity_display.code_mapping`、原合同/Badge | **不作为 MB 业务主键或内核写入前提**；仅提供 MB 身份引用给原会员读接口 | 全域 ST 号段、各店尾号仓库和 presenter 独立；OP/ST/SU 编码平行，原 VI/组件保持，动态会员核验码不在此块 |

顺序是先固定 1–3 的原事实及调用链，再做 6 的 MB 编码独立升级；4 是新能力，5 涉及开店关系迁移，均不得混进最初的等价切割。6 不应阻断 1–3 的会员登记或读取。所谓“薄”，是原路由/响应、事务边界和现有权利检查不变，仅将已核实可共用的原逻辑移动到同一实现。

## 审计对应与风险分流

| 审计记录 | 本次用途 |
| --- | --- |
| [AU-103 注册](../../05_docs_ziliao/docs_wendang/architecture/full-codebase-audit-20260913/records/AU-103-identity-registration/summary.md)、[AU-689 多 Realm](../../05_docs_ziliao/docs_wendang/architecture/full-codebase-audit-20260913/records/AU-689-multi-realm-membership/summary.md) | 1 的原事务、已有账号分支、Realm/Membership 对应必须保留；登录/Session 不迁入 MB 核心 |
| [AU-704 会员节点投影](../../05_docs_ziliao/docs_wendang/architecture/full-codebase-audit-20260913/records/AU-704-storefront-member-context/summary.md)、[AU-725 节点合同](../../05_docs_ziliao/docs_wendang/architecture/full-codebase-audit-20260913/records/AU-725-sfl-node-lifecycle-contract-tests/summary.md) | 2 与本店目录的保全参照；这些 G0 文件不得当作重复代码删除 |
| [AU-147 Member 读取](../../05_docs_ziliao/docs_wendang/architecture/full-codebase-audit-20260913/records/AU-147-member-operations-read/summary.md)、[AU-677 自定义档案](../../05_docs_ziliao/docs_wendang/architecture/full-codebase-audit-20260913/records/AU-677-storefront-member-custom-profile/summary.md)、[AU-659 目录](../../05_docs_ziliao/docs_wendang/architecture/full-codebase-audit-20260913/records/AU-659-storefront-member-directory/summary.md) | 3 的原查询、档案字段及 Mall 读模型；应用投影不能冒充 MB 核心事实 |
| [AU-690 开店](../../05_docs_ziliao/docs_wendang/architecture/full-codebase-audit-20260913/records/AU-690-hosted-mall-opening/summary.md) | 5 的既有事务与历史语义；原实现为“原 consumer node 升级”，与 Ethan 后来提出“申请新店节点、平移后续关系、保留原 MB”有差异，**不能在切割时暗中任选一版** |
| [F-0036/P1](../../05_docs_ziliao/docs_wendang/architecture/full-codebase-audit-20260913/04-findings.md) | 自定义档案两条写 Operation 当前声明 `member.read`。这是现有权限语义问题，不会因代码搬家自动修复；本次不改变权限或增加门禁，单独登记并由 Ethan 决定业务语义 |
| F-0237/P2、F-0288/P2 | 分别属于 Compatibility 跨商城资料写入和 HBBTZN 历史 L6 回填；只作保全/复核线索，不借内核迁移顺手更改旧写入或历史迁移 |

其余审计 P1 不因为提到了 Member/Membership 就划归 MB 内核。所有发现都基于 9 月 13 日源码；真正修改前须对照修改当日的现行实现。

## MB 全域身份码：确定的目标

1. 形式 `MB-PPPPSSSS`。`PPPP` 是全域一次性分配给**会员原归属 ST** 的四位号段；`SSSS` 在该 ST 自己的持久化仓库一次性分配给完整 MB Membership ID。一个 ST 只读/分配自己的尾号，不读取别店尾号表。全域号段仓库只记录 ST→号段，不存 MB 档案。
2. 新码全域唯一、分配后不变；作废号段与尾号均不回收。共享到另一 ST 时仍显示原 MB 码。角色、等级、姓名、手机号、Realm 展示或关系变化不触发重发；码也不是登录凭据、写目标、权限或跨 ST 数据入口。
3. 字符集目标为 `0123456789ABCDEFGHJKMNPQRSTUVWXYZ`（保留数字 0/1，排除字母 O/I/L），每四位 `33⁴ = 1,185,921` 个组合；号段和单店尾号分别有此理论容量。容量不是承诺无限增长，接近上限时需单独制定扩容版本，不自动改变八位格式。
4. 号段分配一次发生在 ST 初始化/登记阶段，会员分配只在本店持久化尾号；不让每个会员请求往返全域库。原系统真实 ST/`operating_node_id`/商城绑定必须先核对，不能以手机号、域名或 Scope 文本猜测号码段主人。
5. 从当前 `identity-display` 中先隔离并保留 OP 路径及可复用的碰撞处理；MB 原六位、按 `context_id` 的映射和展示消费者逐一盘点。**等价切割完成后另起编码升级**：新 4+4 映射启用时旧六位 MB 码失效，不作旧码查询、翻译或重发；不删除 Membership/关系/订单，不误删 45 秒动态会员核验码。
6. 前端只消费后端可选展示字段；暂时无法分配新码时保持原接口原显示，不阻断登记、目录或交易。读写与订单仍使用完整 Membership ID。

## ERA 作为继承参照，不作为新门禁

- E01：同一实现供不同节点使用，节点间原有数据边界不被迁移改变。
- E02：父链、关系版本和历史路径在切割前后可对账。
- E04：同凭据跨 Realm 的身份和会话不串流；OP/MB 仍独立。
- E07：开店前后 MB 及历史连续性；该项原测试的“原节点升级”场景不能直接证明新店节点＋平移关系的新产品决定。
- E09：原注册、编码分配和生命周期写入的幂等语义不被切割改变；不新增验证步骤。
- E12：本店查询与共享查阅各走原有归属/授权事实；模拟隔离通过不能冒充真实 L0/L1/H6 继承。

下一轮才做逐文件细切清单：每片列原文件及 SQL、原事务与输出、切出位置、薄调用、行为等价证据和 L0/L1/H6 各自真实接入证据。未列清楚的能力留原位，不为追求“100% 迁入”整模块搬家。
