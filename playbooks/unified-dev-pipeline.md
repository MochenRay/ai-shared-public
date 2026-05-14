# 统一开发管线

> 最近确认：2026-05-14
> 状态：`unified-dev-pipeline` 正式名称继续沿用；旧 v1 融合实现已废弃；当前版本为 UDP v2 foundation-router。

## 用途

把 Human 的 vibe coding 收敛成一条稳定、规范、可验证的工程 SOP。它解决的问题不是“用 Pocock 还是 Superpowers”，而是任何 coding 工作到来时，先知道处在哪个阶段、该用什么证据进入下一步、哪些护栏不能跳过。

本文件只定义稳定 SOP contract。具体技能、插件、路径、上游版本和本机映射，见 `unified-dev-pipeline-reference.md`。

## 命名与废弃口径

- `unified-dev-pipeline` 是长期稳定入口名，继续使用。
- 废弃的是 2026-03-24 的 UDP v1：一次性 Pocock × Superpowers 融合实现。
- 当前 `~/.agents/skills/unified-dev-pipeline/SKILL.md` 是 UDP v2 薄路由。
- 以后说“用 unified-dev-pipeline”，默认指 UDP v2；除非明确说“旧 v1”或“历史版本”，否则不再回到旧融合逻辑。

## 核心原则

- UDP 是 Human 的 coding SOP 控制层，不是 Pocock / Superpowers 的合并副本。
- 上游技能是 adapter，可吸收、替换或废弃；SOP contract 不随上游目录和命令名摇摆。
- 每个阶段都要能说清输入、输出、进入下一阶段的证据。
- `phase-plan` 给人判断方向；`task-plan` 给 agent 执行。
- `diagnose` 与 `triage` 分离：前者找根因，后者管 issue 状态机。
- `verify` 和 `review` 是硬护栏；无证据不称完成，不盲从反馈。

## SOP 阶段

| 阶段 | 目的 | 最小输出 |
|---|---|---|
| `setup` | 确认 repo context、issue tracker、domain docs、测试入口 | 上下文与工作区边界 |
| `explore` | 需求探索、方案澄清、读取现状 | 关键假设与待确认点 |
| `spec` | 冻结问题、目标、边界、验收标准 | PRD / spec |
| `phase-plan` | 给人看的阶段计划，按垂直切片拆解 | 阶段、验收、耐久架构决策 |
| `task-plan` | 给 agent 的执行计划 | 文件、命令、测试、预期结果 |
| `execute` | 在本地、worktree 或子 agent 中执行 | 改动范围与阶段结果 |
| `implement` | TDD / coding | 代码、测试、失败到通过的证据 |
| `diagnose` | bug / 性能问题根因诊断 | 复现 loop、假设、验证过的根因 |
| `verify` | 完成前证据验证 | 运行命令与结果 |
| `review` | 技术审查与反馈吸收 | findings、取舍、修复或拒绝理由 |
| `finish` | 合并、PR、保留或丢弃 | 最终状态、分支/PR/归档结果 |

`architecture` 是持续改进回路，不是主线必经阶段。它可由 `phase-plan`、`diagnose` 或 `review` 触发。

## 典型路线

新功能：

```text
setup -> explore -> spec -> phase-plan -> task-plan -> execute -> verify -> review -> finish
```

Bug 修复：

```text
setup -> diagnose -> implement -> verify -> review -> finish
```

小改动：

```text
implement -> verify -> finish
```

架构改进：

```text
setup -> explore -> architecture -> phase-plan -> task-plan -> execute -> verify -> review -> finish
```

## 阶段门禁

- 未知 repo context 时，不进入大规模执行。
- 未冻结 spec 时，不生成详细 task-plan。
- 未完成 phase-plan 时，不把任务拆成多个 agent 并行。
- 未建立复现或反馈 loop 时，不对 bug 乱猜补丁。
- 未执行验证命令时，不声称完成。
- review 反馈未经技术判断，不直接照单全收。

## 两层计划制

### Phase Plan

给人看，用来判断方向是否正确。内容包括：

- 垂直切片
- 用户价值或行为闭环
- 耐久架构决策
- 验收标准
- 明确不做什么

Phase Plan 不写易腐细节：文件路径、函数名、临时代码片段。

### Task Plan

给 agent 看，用来执行。内容包括：

- 要改的文件
- 要写的测试
- 命令和预期输出
- 每步完成条件
- 回滚或验证方式

Task Plan 可以写具体路径和代码细节，但必须来自已确认的 Phase Plan。

## 执行分流

默认先判断任务是否适合并行：

- 中大型实现、跨模块改造、可并行排障：优先 `git worktree + agents`。
- 非 Git 目录但可并行：先冻结目录边界，再用 agents 并行。
- 小改动、高度耦合、单一事实核查：单线程更合适。

主线程负责冻结合同、拆边界、集成结果、最终验证。子线程只在自己的边界内实现或排查，不自发扩边界。

## 跨模型 QA

跨模型 QA 是选用节点，不是每次必跑。

- `codex-qa`：计划完成后，让另一模型审 Phase Plan 或 Task Plan。
- `codex-verify`：实现完成后，让另一模型按计划逐项核验。

触发条件：

- 计划超过 3 个 phase。
- 涉及架构决策或跨模块改动。
- 主线程对计划或实现不够确定。

小改动和简单 bug 修复不需要强行跨模型审查。

## 稳定规则

- SOP contract 优先于具体命令名。
- adapter 变了，先改 reference；只有阶段语义变了，才改本文件。
- 上游 drift 只说明“可能有变化”，不等于“应吸收”。
- `verify`、`review`、`finish` 不因任务小而省略，只能按比例缩短。
- 最终只有主线程可以宣布本轮完成。
