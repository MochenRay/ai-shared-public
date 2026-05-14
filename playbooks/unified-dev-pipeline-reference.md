# 统一开发管线参考

> 最近确认：2026-05-14
> 状态：`unified-dev-pipeline` 名称继续沿用；旧 v1 实现已废弃；Pocock 与 Superpowers 当前 adapter 已同步。

## 用途

本文件记录 UDP SOP contract 在当前机器上的技能映射、上游来源和跟踪状态。稳定阶段定义见 `unified-dev-pipeline.md`；本文件只负责 adapter，不定义 SOP。

## Name Contract

| Name | Status | Meaning |
|---|---|---|
| `unified-dev-pipeline` | active | UDP v2 thin-router entrypoint |
| UDP v1 / 2026-03-24 fusion | deprecated | historical Pocock × Superpowers fusion, not the runtime contract |

不要新建 `unified-dev-pipeline-v2` 作为长期入口；v2 继续占用正式名称，版本差异只在文档与锻造记录中说明。

## Adapter Matrix

| SOP 阶段 | 当前 adapter | 来源 | 本地状态 | 说明 |
|---|---|---|---|---|
| `setup` | `setup-matt-pocock-skills` | Pocock | installed 2026-05-14 | 用于 repo issue tracker、labels、domain docs 前置配置；小任务非硬门槛 |
| `explore` | `superpowers:brainstorming` + `grill-me` / `grill-with-docs` | Superpowers + Pocock | installed / plugin-managed | 默认用 Superpowers 探索，按需引入 domain docs grilling |
| `spec` | `write-a-prd` / `to-prd` | Human-local + Pocock | 本地 fork | 保留访谈式 PRD，吸收 Pocock glossary / issue tracker 机制 |
| `phase-plan` | `prd-to-plan` | Human-local | local-canonical | 两层计划制的第一层，不再假装 Pocock upstream fork |
| `task-plan` | `superpowers:writing-plans` | Superpowers | plugin-managed | 从 Phase Plan 展开成 agent 可执行任务 |
| `execute` | `superpowers:using-git-worktrees` + `superpowers:subagent-driven-development` / `superpowers:executing-plans` | Superpowers | plugin-managed, v5.1.0 verified | 已吸收 worktree consent、native worktree preference、continuous SDD |
| `implement` | `tdd` + `superpowers:test-driven-development` | Human-local + Superpowers + Pocock | customized, synced 2026-05-14 | 保留 TDD 铁律，吸收 Pocock 行为测试、domain glossary 与 vertical slice |
| `diagnose` | `diagnose` + `superpowers:systematic-debugging` | Pocock + Superpowers | installed + plugin-managed | 新增阶段，替代旧 `/triage` 的 bug 根因职责 |
| `verify` | `superpowers:verification-before-completion` | Superpowers | plugin-managed | 完成前硬护栏 |
| `review` | `superpowers:requesting-code-review` / `superpowers:receiving-code-review` | Superpowers | plugin-managed, v5.1.0 verified | 已转 generic dispatch，不绑定旧 named reviewer |
| `finish` | `superpowers:finishing-a-development-branch` | Superpowers | plugin-managed, v5.1.0 verified | 已吸收 environment detection、detached HEAD 与 worktree cleanup 变化 |
| `architecture` | `improve-codebase-architecture` | Pocock | customized, synced 2026-05-14 | 接入 `CONTEXT.md` / ADR / architecture glossary 后继续作为改进回路 |

## Stage Aliases

这些别名用于沟通，不保证都是当前 harness 的真实 slash command。

| Alias | SOP 阶段 | 当前落点 |
|---|---|---|
| `/brainstorm` / `/grill-me` | `explore` | `superpowers:brainstorming`，保留 grill-me 精神 |
| `/prd` | `spec` | `write-a-prd` |
| `/plan` | `phase-plan` | `prd-to-plan` |
| `/tasks` | `task-plan` | `superpowers:writing-plans` |
| `/issues` | issue 拆解 | `prd-to-issues` / Pocock `to-issues` 候选 |
| `/execute` | `execute` | `superpowers:subagent-driven-development` |
| `/dispatch` | `execute` | remote-agent-host / remote worker async route，属执行 adapter |
| `/tdd` | `implement` | `tdd` + Superpowers TDD |
| `/diagnose` | `diagnose` | Pocock `diagnose` 候选 + systematic debugging |
| `/triage` | issue 状态机 | Pocock `triage`；不再等同 bug 根因 |
| `/debug` | `diagnose` | `superpowers:systematic-debugging` |
| `/verify` | `verify` | `superpowers:verification-before-completion` |
| `/review` | `review` | Superpowers review skills |
| `/finish` | `finish` | `superpowers:finishing-a-development-branch` |
| `/architecture` | `architecture` | `improve-codebase-architecture` |

## Upstream Watch Registry

| Source | Tracked item | Local adapter | Local state | Pinned ref | Latest ref | Change class | Decision |
|---|---|---|---|---|---|---|---|
| `github:obra/superpowers` | repo / release | Superpowers adapters | plugin-managed | Codex/Claude verified v5.1.0 | `f2cbfbefebbf`, v5.1.0 | none | `synced` |
| `github:mattpocock/skills` | engineering skills | Pocock adapters | mixed: installed / customized / local-deprecated | `e74f0061bb67` for active adapters | `e74f0061bb67`, checked 2026-05-14 | none | `synced` |
| local | `prd-to-plan` | `phase-plan` | local-canonical | none | none | none | `keep` |
| local | `unified-dev-pipeline` skill | router | thin-router | legacy v1 deprecated | rewritten 2026-05-14 | foundation | `keep name, keep thin` |

## Change Class Rules

| Type | Meaning | Action |
|---|---|---|
| `none` | 无实质变化 | 记录检查日期即可 |
| `path` | 路径或目录变化，语义基本不变 | 修同步脚本或路径 |
| `content` | 文本变化，阶段职责不变 | 人工 merge adapter |
| `semantic` | 名称、职责、输入输出改变 | 先重评阶段价值 |
| `major` | release notes 显示 workflow / execution / review / setup 变化 | 开锻造 session，不直接更新 |
| `foundation` | 影响 SOP 地基 | 回到 `udp-v2-foundation-plan.md` |

## Upstream Diff Snapshot

最近检查：2026-05-14，命令：`python3 ${HOME}/.claude/scripts/upstream-diff.py`。

| Local skill | Upstream match | Change class | Decision |
|---|---|---|---|
| `setup-matt-pocock-skills` | `skills/engineering/setup-matt-pocock-skills` | `none` | installed |
| `diagnose` | `skills/engineering/diagnose` | `none` | installed |
| `grill-with-docs` | `skills/engineering/grill-with-docs` | `none` | installed |
| `git-guardrails-claude-code` | `skills/misc/git-guardrails-claude-code` | `none` | path patched |
| `grill-me` | `skills/productivity/grill-me` | `none` | path patched |
| `tdd` | `skills/engineering/tdd` | `none` | selective merge done |
| `write-a-prd` / `to-prd` | `skills/engineering/to-prd` | `none` | selective merge done |
| `prd-to-issues` / `to-issues` | `skills/engineering/to-issues` | `none` | selective merge done |
| `improve-codebase-architecture` | `skills/engineering/improve-codebase-architecture` | `none` | semantic upgrade done |
| `triage` | `skills/engineering/triage` | `none` | installed |
| `triage-issue` | local compatibility shim | local-deprecated | root cause moved to `diagnose`; issue state moved to `triage` |

脚本现在能识别 Pocock `skills/*/<name>/SKILL.md` 多层路径；当前 Pocock adapter 检查 `exit=0`。

## Superpowers Snapshot

最近检查：2026-05-14。

| Harness | Path / Source | Verified state | Notes |
|---|---|---|---|
| Codex App | `${HOME}/.codex/plugins/cache/openai-curated/superpowers/1141b764/skills` | skill files match upstream `v5.1.0` | current Codex runtime source |
| Claude Code | `superpowers@superpowers-marketplace` | plugin updated from `5.0.5` to `5.1.0` | restart required by Claude CLI |
| Upstream | `github:obra/superpowers` | `f2cbfbefebbf`, package `5.1.0` | compared against local clone |

旧 Claude `5.0.5` cache 目录仍存在，但 `installed_plugins.json` 指向 `5.1.0`；不要手删 cache，交给 Claude plugin manager 管理。

## Adapter Review Decisions

最近审查：2026-05-14。

- Pocock `setup-matt-pocock-skills`：吸收为可选 `setup` 前置，适合有 issue tracker / domain docs / ADR 的 repo；不作为每个小任务的硬门槛。
- Pocock `grill-with-docs`：吸收 glossary / ADR / domain docs 机制，补强 `explore` 与 `spec`；不替代 Human-local 访谈式澄清。
- Pocock `diagnose`：吸收为 bug 根因主线，强调先建立反馈 loop；旧 `triage-issue` 不再承担根因诊断。
- Pocock `triage`：限定为 issue tracker 状态机；仅在项目已有 issue tracker 和标签约定时启用。
- Pocock `to-prd` / `to-issues`：新版语义已偏“从当前上下文综合并发布到 issue tracker”；保留 Human-local `write-a-prd` 与两层计划制，只吸收 domain glossary、issue tracker 和 vertical slice 机制。
- Pocock `tdd`：作为 content merge candidate；保留本地 Iron Law，吸收 vertical slice、行为测试、反 horizontal slice 的解释。
- Pocock `prototype` / `zoom-out`：作为探索辅助，不进入 UDP 主线必经阶段。
- Superpowers v5.1.0：已吸收 legacy slash command 移除、worktree consent/native preference、generic code-review dispatch、continuous subagent execution；不让 upstream mandatory gate 覆盖 Human-local 节奏。

## 后续待处理

1. 后续若 Pocock 再更新，先跑 `upstream-diff.py`；`path/content` 可小改，`semantic/major` 回到本 reference 审查。
2. 后续若 Superpowers 再更新，先用 plugin manager 升级，再比对 Codex/Claude skill files 与 upstream tag。

## 维护规则

- 修改 SOP 阶段前，先改 `udp-v2-foundation-plan.md` 或另开锻造记录。
- 上游变化先进入 watch registry，不直接改本地 skill。
- 本地 skill 内容只动 `~/.agents/skills/<name>/SKILL.md`，Claude 端通过 symlink mirror 同步。
- 若某 adapter 被废弃，优先保留阶段意图，再找替代来源。
