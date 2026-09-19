# MB 会员内核继承实况

更新：2026-09-17。这里的“继承”只指原调用链确实执行 `L-kernel` 中的唯一实现；文件搬到适配层、模拟节点测试或试部署均不算继承完成。当前没有为本轮内核迁移部署 L0、L1 或 H6。

| 会员能力 | L-kernel 中的现有实现 | 原调用链 | 当前结论 |
| --- | --- | --- | --- |
| 自定义档案字段校验 | `src/member/MemberProfileRules.ts` | 原 `MemberCustomProfileOperations.ts` 直接导入 | 已继承这两个纯校验函数；配置/资料 SQL 和权限仍在原模块 |
| L 等级判定 | `src/node/SignedLevel.ts` | 原 `@shop/config/sfl-node-kernel` 转发；节点与会员调用者不改入口 | 已继承纯等级解析和分段；节点、关系、Realm 数据仍由原权威拥有 |
| MB 节点登记请求/结果规则 | `src/member/MemberNodeRegistration.ts`，共用的原解析辅助函数在 `src/node/NodeParsing.ts` | `MemberPort.registerHostedMemberNode` → 原 config 兼容出口 → L-kernel 解析 → 原 `organization.register_hosted_member_node` | 已继承原请求/结果解析；登记事务、账号/登录、数据库函数未迁入 |
| 节点归属、父链与关系版本纯规则 | `src/node/NodeTopology.ts`，共用解析辅助函数在 `src/node/NodeParsing.ts` | 原 `@shop/config/sfl-node-kernel` 兼容出口 → L-kernel 唯一实现 | 已继承原拓扑解析、父子关系和时间版本校验；数据库节点事实、关系写入和 L1 实际读取尚未由此验收 |
| 托管节点创建请求与结果解析 | `src/node/HostedNodeProvisioning.ts` | 原 `HostedNodeProvisioningPort` → config 兼容出口 → L-kernel 解析 → 原 `organization.provision_hosted_node` | 已继承原纯规则；创建 Realm/Mall 的事务及“MB 另开 ST”新业务衔接未实现 |
| 会员开店请求与结果解析 | `src/member/HostedMallOpening.ts` | 原 `MemberPort.openHostedMall` → config 兼容出口 → L-kernel 解析 → 原 `organization.open_hosted_member_mall` | 已继承纯请求/结果规则；开店事务、权限、节点变更及真实 L1 流程未迁入 |
| 会员另开 ST 后的原链引用 | `src/member/MemberStoreLineage.ts` 是新增只读规则 | 尚未接入新店建立、引用记录仓库或 L1 目录 | 依据最新决定保留原 MB 父链和关系版本，新 ST 引用原链；仅内核代码，不等同于旧开店 SQL 已升级 |
| 本店 MB 目录和详情 | 无 | 原 Member Reader → 原模块适配层 SQL | 只完成原模块内切薄，**尚未继承内核**；L1 真实详情仍有已知故障 |
| 邀请、关系写入和生命周期 | 无 | 原 SFL 模型、数据库函数及 Member/Identity 编排 | 待逐片切割；不重写或另建节点权威 |
| 跨 ST 资料共享 | `src/member/MemberShareFacts.ts` 是新增的固定名单事实及两侧标注纯规则 | 尚未建立共享记录仓库、目录适配或前端标注 | 仅内核代码；原 MB Membership 不变，非自动连续共享，不冒充邀请或分销关系 |
| MB 全域 4+4 身份码 | `src/member/MemberIdentityCode.ts` 为新规则的纯分配与格式函数 | 尚未接入原 `identity-display`、全域号段仓库或本店尾号仓库 | 仅内核代码已写且测试；现有六位 MB 码仍为运行路径，**未继承／未切换** |

本轮源码迁移不包含线上 bug 修复、数据库授权、前端 VI、订单、地址、导入、OP 或部署。L1 会员详情试点已回滚，线上仍运行试点前版本；详情故障见 [第一片报告](SLICE_01_REPORT.md)。

登记事务权威仍在 Identity/数据库函数，不能为迁移而复制。下一片按原源码核对档案、邀请和生命周期中可独立执行的原规则；目录 SQL、HTTP、Realm 会话和订单仍留在各自适配层。完成内核代码后，再分别验收 L1、L0、H6 的真实调用与数据边界。
