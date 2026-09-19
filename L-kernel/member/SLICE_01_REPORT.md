# 第一片｜本店会员目录与基础档案

状态：**原 Member 模块内切割和前后端分层测试已完成，代码已提交；L1 曾单目标试部署并已回滚，真实会员详情尚未通过。目录/详情 SQL 尚未迁入 L-kernel。** 本片不包含自定义档案写入、邀请/订单事实、MB 4+4 编码或跨 ST 共享。

## 原代码保全与薄接入

| 原位置 | 本片切出位置 | 原调用保留 |
| --- | --- | --- |
| `03_application_yingyong/MemberDirectoryReader.ts` 的本店目录 SQL | `04_adapters_shixian/persistence/MemberDirectoryQuery.ts` | 原 Reader 仍接收原数据库和 Mall scope，按原顺序绑定五个参数 |
| `03_application_yingyong/MemberReadOperations.ts` 的详情 SQL | `04_adapters_shixian/persistence/MemberDetailReader.ts` | 原动作仍处理原访问上下文、可选身份展示、响应 Schema 与错误；数据库查询仍由原连接执行 |

与切割前 `f7bb770b3` 第一父提交中的原 SQL 比对：目录 **1,284 字符逐字相同**（SHA-256 `eeb82de69ab923b0eb8ce54980b81c8953bfda6315ded1d71fd5891991811da0`）；详情 **3,586 字符逐字相同**（SHA-256 `5e0902954b5f7607d4666a12ca5a9c9bfdc2c5eb7608b016fbf3e8f5952afe7d`）。本片不新增第二套表、节点模型或路由，原合同、SDK、Console 组件与 VI 未修改。此前迁入 L-kernel 的 `MemberProfileRules.ts` 保留，但目录/详情 SQL 不搬入纯业务内核。

## 本轮验证

- Commerce 原 `member/06_tests_ceshi` 六个测试文件：**21 项通过**。PGlite 覆盖本 Mall 列表/搜索/分页、OP 与 MB 同 Principal 不混列、目录可选身份展示、详情、邀请及订单投影。此次补充两个原有范围语义的反例：别店 Scope 查本店详情返回 `RESOURCE_NOT_FOUND`；同 Principal 的 OP Membership 不会成为 MB 详情。
- Console `StorefrontMemberRoute.test.tsx`：**13 项通过**，核对现有 SDK 请求与页面展示；这是模拟 HTTP，不是连接真实 L1 后端。
- L-kernel `MemberProfileRules.test.ts`：**2 项通过**。Commerce、Console、L-kernel TypeScript 类型检查均通过。
- 初次从子包启动 `pnpm exec` 时，pnpm 尝试从公网拉取仓内 `@shop/*` 包并移动了两项本地依赖，测试未运行。已将依赖移回原位置、删除本次生成的 L-kernel 锁文件；随后直接使用仓库现有测试运行器，上述测试与类型检查通过。未修改受控依赖、工作流或锁文件。

## 真实 L1 试点与回退（2026-09-17）

- 桌面正本 `codex/L-kernel` 提交 `891227a55`；以当时 L1 生产 Source `c0a3a1084` 为基底准备独立试点提交 `b59bdb381`。试点只发布 `hbbtzn-l1/identity-api`，未切桌面分支，也未发布 L0/H6。
- 发布前线上会员目录可读 12 人，但打开详情返回 `RESOURCE_SCOPE_NOT_FOUND`。原控制器把详情路径里的 Membership ID 当作 Scope 资源解析；试点保留完整路径 ID，改为在原权限流程内解析当前商城。相应的 5 个会员目标入口测试通过；详情 SQL 仍按商城 ID 与完整 Membership ID 查询，跨商城及 OP 冒充 MB 的反例测试通过。
- 试点部署后原错误消失，详情进一步报 `INTERNAL_ERROR`。请求 `6c9d5957-5f8c-4beb-9dc0-a666678f026a` 的 L1 服务日志定位到 `permission denied for schema ordering`。原详情 SQL 读取 `ordering.orderrecord`，而 L1 Identity API 运行角色不具备该 Schema 读取能力；会员订单列表和自定义档案的“已消费”标签也读取此表。现有自定义档案表的迁移仅给 `shopapp` 授权，不能据此宣称其 L1 Identity API 路径可用。
- 已通过同一 Runner 的单目标回滚，将 L1 `identity-api` current 恢复为 `c0a3a1084`，服务健康；网页再测恢复为原 `RESOURCE_SCOPE_NOT_FOUND`。试点源码仍在独立分支，但**生产当前不是该提交**。下一步先核定会员读取所需数据库权限和数据归属，不盲目扩大 Identity API 的订单表权限，也不以本次试部署宣称内核继承完成。

## 尚未迁入／不能宣称的结果

- 这片是**原模块内的等价切薄**，不是把 SQL 搬入 L-kernel。后续只有从详情/档案中识别出独立的纯业务规则，才按原实现切入共用内核；订单统计仍由订单事实所有者负责。
- 测试中的 `mall:one`、`mall:two` 和查询参数 `mall:hbbtzn` 都是开发夹具，不代表真实 L1 数据库、Realm 或生产部署已接入。真实 L1 试点已证实目录可读、详情仍失败且已回滚；L0/H6 也尚未正式继承。
- 现有六位 MB 展示码、Identity 注册、开店、跨店共享、OP、地址、导入及审计 P1 F-0036 均未因本片改变。没有新增安全门禁或确认步骤。
