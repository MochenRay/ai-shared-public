# UDP v2 地基计划

> 最近确认：2026-05-14
> 状态：Phase 1-5 foundation-router 已执行；旧 UDP v1 已废弃；`unified-dev-pipeline` 名称继续指向当前 v2
> 目标：让 Human 的 vibe coding 有一条稳定、规范、可验证的工程 SOP；Pocock 与 Superpowers 是上游素材，不是直接真相层。

## 背景判断

Human 使用 `unified-dev-pipeline` 的核心动机不是追随某个热门仓库，而是弥补技术背景不足时的流程盲区：在需求、计划、实现、调试、验证、审查和收尾各阶段，都有清晰护栏。

旧版 UDP v1 的融合逻辑在 2026-03-24 成立：Pocock 提供需求、PRD、Issue、架构和工程设计哲学；Superpowers 提供纪律、TDD、计划、子 agent 执行、验证和 review。其问题不是方向错，而是把三层东西混在一份 skill 里：

- 稳定 SOP contract
- Pocock / Superpowers adapter mapping
- 具体本机执行细节与上游同步策略

现在 Pocock 与 Superpowers 都有变化，继续在旧 fork 上强行迭代会放大漂移风险。

## 总体价值判断

UDP v2 不应被 Pocock 或 Superpowers 任一方完全替代。

- Superpowers 更像完整工程纪律框架，适合作为默认执行与验证护栏。
- Pocock 更像工程语义与产品化协作工具箱，适合作为 PRD、Issue、domain docs、diagnose、architecture 的补强。
- Human-local 层负责把二者收敛成稳定 SOP，避免每次都重新判断“用哪套”。

因此，UDP v2 的定位是：

> Human 的 coding SOP 控制层，吸收 Pocock / Superpowers 的有效机制，但不照搬、不追随、不把上游文件当直接地基。

命名决策：不另起 `unified-dev-pipeline-v2`。`unified-dev-pipeline` 是稳定入口名，旧 v1 只作为历史记录保留。

## SOP Contract

UDP v2 的稳定阶段先冻结为以下 11 个阶段。阶段名是工作流语义，不等同于必须存在的 slash command。

| 阶段 | 目的 | 硬护栏 |
|---|---|---|
| `setup` | 确认 repo context、issue tracker、domain docs、测试入口 | 上下文不明时不大规模执行 |
| `explore` | 需求探索、方案澄清、上下文读取 | 不能跳过关键假设 |
| `spec` | 写 PRD / spec，冻结问题、边界、验收 | 不把愿望直接变代码 |
| `phase-plan` | 给人看的阶段计划，垂直切片，不写易腐细节 | 方向未确认不进执行计划 |
| `task-plan` | 给 agent 的执行计划，文件、命令、预期结果明确 | 模糊任务不得派发 |
| `execute` | 本地或子 agent 执行 | 先隔离工作区，按任务边界执行 |
| `implement` | TDD / coding | 关键行为先有失败信号或验证路径 |
| `diagnose` | bug / 性能问题根因诊断 | 先建立反馈 loop，不乱猜补丁 |
| `verify` | 完成前证据验证 | 无证据不称完成 |
| `review` | 技术审查与反馈吸收 | 不盲从、不表演式同意 |
| `finish` | 合并、PR、保留或丢弃 | 收尾前状态、测试、diff 必须清楚 |

`architecture` 不是主线必经阶段，而是从 `diagnose`、`review`、`phase-plan` 中触发的持续改进回路。

## Adapter Matrix

| SOP 阶段 | 默认来源 | 当前判断 | UDP v2 处理 |
|---|---|---|---|
| `setup` | Pocock `setup-matt-pocock-skills` | 旧 UDP 缺失 | 新增为可选前置，按项目需要启用 |
| `explore` | Superpowers `brainstorming` + Pocock `grill-with-docs` | Superpowers 仍强 | 保留 Superpowers 主导，吸收 domain docs grilling |
| `spec` | Pocock `to-prd` / Human-local `write-a-prd` | Pocock 新版偏“综合当前上下文” | 保留 Human-local 访谈式 PRD，吸收 Pocock issue tracker / glossary 机制 |
| `phase-plan` | Human-local 两层计划制 | 仍是核心资产 | 明确标为 Human-local canonical |
| `task-plan` | Superpowers `writing-plans` | 仍强 | 保留，要求从 Phase Plan 展开 |
| `execute` | Superpowers `using-git-worktrees` + `subagent-driven-development` / `executing-plans` | v5.1.0 强调 consent 与 native worktree | 更新适配，不再默认隐式创建 worktree |
| `implement` | Superpowers `test-driven-development` + Pocock `tdd` | 可融合 | 保留 TDD 铁律，吸收 Pocock 行为测试与 vertical slice 解释 |
| `diagnose` | Pocock `diagnose` + Superpowers `systematic-debugging` | 旧 `/triage` 语义已错位 | 新增 `diagnose`，从 `triage` 中拆出 bug 根因分析 |
| `verify` | Superpowers `verification-before-completion` | 仍是硬护栏 | 保留 |
| `review` | Superpowers `requesting-code-review` / `receiving-code-review` | v5.1.0 已整合 named agent | 更新为 generic dispatch 模型 |
| `finish` | Superpowers `finishing-a-development-branch` | v5.1.0 worktree 逻辑重写 | 吸收 provenance cleanup 与 detached HEAD 处理 |
| `architecture` | Pocock `improve-codebase-architecture` | 新版依赖 `CONTEXT.md` / ADR | 保留但接入 domain glossary / ADR 前置 |

## 吸收原则

吸收上游更新前，逐条问：

1. 它是否解决 Human 当前工作流痛点？
2. 它是否能进入稳定 SOP，而不是只适合某个仓库？
3. 它是否减少认知负担，而不是增加触发词负担？
4. 它是否有明确验证方式？
5. 它是否尊重 `~/.agents/skills/` 作为 universal truth layer？
6. 它是否会破坏 Human-local 两层计划制？

符合以上多数条件，才吸收。否则记录为素材，不进主线。

## 上游跟踪机制

UDP v2 需要把“跟踪上游”与“吸收上游”分开。前者可以自动化，后者必须人工判断。

### Watch Registry

建立一份 registry，记录每个上游来源的当前状态。建议字段：

| 字段 | 含义 |
|---|---|
| `source` | `github:mattpocock/skills` / `github:obra/superpowers` / local |
| `tracked_item` | repo、release、skill path 或 plugin version |
| `local_adapter` | UDP 中对应阶段或本地 skill |
| `local_state` | `plugin-managed` / `upstream-pristine` / `local-fork` / `local-canonical` |
| `last_checked_at` | 最近检查日期 |
| `pinned_ref` | 本地已评估的 commit / tag / release |
| `latest_ref` | 上游当前 commit / tag / release |
| `change_class` | `none` / `path` / `content` / `semantic` / `major` |
| `decision` | `ignore` / `watch` / `merge` / `reassess` / `deprecate` |

registry 可以先放在 `unified-dev-pipeline-reference.md` 或独立 `unified-dev-pipeline-upstream-watch.md`；不应塞进 `unified-dev-pipeline/SKILL.md`。

### 检查节奏

- 每月例行检查一次。
- 用户说“更新 UDP / 检查上游 / Superpowers 或 Pocock 有变化吗”时立即检查。
- GitHub release、重大目录重组、核心 skill `name / description` 改变时触发人工复核。
- 检查结果只更新 registry 和锻造记录；未经人工判断，不改本地 skill。

### 分类规则

| 类型 | 判断方式 | 处置 |
|---|---|---|
| `path` | 文件移动、目录重组，但 `name / description` 基本不变 | 修同步脚本或路径，不改 SOP |
| `content` | 文本变化，但阶段语义不变 | 按 adapter 人工 merge |
| `semantic` | `name / description`、阶段职责或输入输出改变 | 进入 `reassess`，先审价值 |
| `major` | release notes 提示 workflow / execution / review / setup 机制改变 | 进入锻造 session，不直接更新 |

### 汇报格式

每次检查上游后，只给四类结论：

1. `No action`：无变化或不影响 UDP。
2. `Patch adapter`：可小改 adapter，不动 SOP。
3. `Reassess stage`：某阶段语义变了，要重新判断。
4. `Foundation impact`：影响 UDP 地基，需重开 foundation plan。

## 禁止事项

- 不因 Pocock 目录改名就自动重写 UDP。
- 不把 Superpowers 的 mandatory skill 规则原样压过用户节奏。
- 不让 `/triage` 同时承担 issue 状态机与 bug 根因诊断。
- 不把本机 remote worker 派发命令写进 SOP contract 层。
- 不把上游 drift 检查当成语义正确性证明。
- 不把自动检查结果等同于允许吸收上游更新。

## 执行切片

### Phase 1：冻结文档地基

- 更新 `playbooks/unified-dev-pipeline.md`：只写稳定 SOP contract。
- 更新 `playbooks/unified-dev-pipeline-reference.md`：只写 adapter matrix 与当前本机映射。
- 更新 `playbooks/workflow-forging-record.md`：记录 v2 foundation 计划，不宣称已落地。

### Phase 2：修上游同步能力

- 已修 `~/.claude/scripts/upstream-diff.py`：通过 GitHub tree 定位 `skills/*/<name>/SKILL.md`。
- 已在 drift 报告中区分 `path drift`、`content drift`、`semantic drift`。
- 已对相似度极低或 `name / description` 语义改变的项输出 `REASSESS`，不允许自动覆盖。
- 已建立 upstream watch registry，记录 Pocock / Superpowers 的 pinned ref、latest ref、change class 与人工 decision。

### Phase 3：重建 Pocock adapter

- 已审 `setup-matt-pocock-skills`、`diagnose`、`grill-with-docs`、`zoom-out`、`prototype` 的候选映射。
- 已安装 Pocock adapter：`setup-matt-pocock-skills`、`diagnose`、`grill-with-docs`、`triage`。
- 已将旧 `triage-issue` 拆成 `diagnose` 与 `triage` 两个语义。
- 已将 `prd-to-plan` 标记为 Human-local canonical，而非 Pocock upstream fork。
- 已选择性同步 `write-a-prd`、`prd-to-issues`、`tdd`，保留 Human-local 访谈、HITL/AFK 与 TDD Iron Law。
- 已升级 `improve-codebase-architecture` 到 Pocock glossary / ADR / deepening 语义。

### Phase 4：更新 Superpowers adapter

- 已复核 Superpowers v5.1.0 变化；Codex 插件 skills 与 upstream `v5.1.0` 字节一致。
- 已通过 Claude plugin manager 将 `superpowers@superpowers-marketplace` 从 `5.0.5` 升级到 `5.1.0`；Claude 需重启后完全生效。
- 已吸收 v5.1.0 变化：legacy slash command 删除、worktree consent、generic code-review dispatch、continuous SDD。
- 已将 UDP 中的 `/brainstorm` 等表达改为“阶段别名”，不再暗示真实 slash command 必然存在。

### Phase 5：改写本地 skill

- 已改 `~/.agents/skills/unified-dev-pipeline/SKILL.md`，使其只做薄路由。
- 已移除 skill 内完整历史、上游细则和 remote worker 命令。
- 已同步验证 `~/.claude/skills/` symlink mirror。

## 验证标准

完成 UDP v2 后，必须通过以下检查：

- `bash /path/to/AI-Shared/scripts/validate-shared-writeback.sh`
- `python3 ~/.claude/scripts/upstream-diff.py` 输出可解释，不以 404 误报当前 Pocock tree。
- upstream watch registry 能显示 Pocock / Superpowers 当前 pinned ref、latest ref、change class 与 decision。
- 新功能路线能说清：`setup -> explore -> spec -> phase-plan -> task-plan -> execute -> verify -> review -> finish`
- bug 路线能说清：`diagnose -> implement -> verify -> review -> finish`
- issue workflow 能说清：`triage` 只管状态机，不再混同根因诊断。
- 任一阶段能指出当前 adapter 来源与真相层。

## 当前不做

- 不直接覆盖 7 个 Pocock fork。
- 不立即升级或改写 Superpowers 插件。
- 不删除 UDP v1。
- 不创建新的大量触发词。

当前地基升级已收口。后续只做例行 upstream watch：Pocock 跑 `upstream-diff.py`，Superpowers 用插件管理器升级后再比对 upstream tag。
