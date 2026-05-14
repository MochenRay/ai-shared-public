# 统一工作流锻造记录

> **定位**：这是唯一的工作流演进主文档。所有改造、升级、新素材吸收都在此留痕。
> **原则**：一条主干，持续锻造。新材料是矿石，不是成品——熔炼后只保留让武器更锋利的部分。

---

## 当前版本：v2 foundation-router（2026-05-14）

> 2026-05-14：`unified-dev-pipeline` 名称继续作为正式入口；旧 v1 融合实现已废弃。当前入口是 `~/.agents/skills/unified-dev-pipeline/SKILL.md` 薄路由；稳定真相在 `unified-dev-pipeline.md` 与 `unified-dev-pipeline-reference.md`。

### 当前使用口径

- `unified-dev-pipeline.md`：稳定 SOP contract。
- `unified-dev-pipeline-reference.md`：adapter matrix、upstream watch registry 与当前吸收决策。
- `~/.agents/skills/unified-dev-pipeline/SKILL.md`：只做路由，不再保存完整历史与上游细节。
- 旧 v1 不再作为可执行或更新对象；它只保留在演进历史中用于追溯。
- Pocock adapters 已同步到 `e74f0061bb67`：新增 `setup-matt-pocock-skills`、`diagnose`、`grill-with-docs`、`triage`，选择性同步 `write-a-prd`、`prd-to-issues`、`tdd`，升级 `improve-codebase-architecture`，旧 `triage-issue` 降为兼容 shim。
- Superpowers adapters 已复核到 v5.1.0：Codex 插件文件与 upstream 一致，Claude plugin 已从 `5.0.5` 升到 `5.1.0`。

## 已废弃版本：v1.0（2026-03-24）

> 状态：deprecated。此节只作历史记录，不再作为 `unified-dev-pipeline` 的当前使用说明。

### 工作流全景

```
[1] 需求探索 ─── /brainstorm /grill-me
        │
[2] PRD 编写 ─── /prd
        │
[3] 架构计划 ─── /plan
        │
[4] 任务拆解 ─── /issues（Issue 驱动）或 /tasks（Task Plan）
        │
[5] 执行 ────── /execute（本机 Opus）或 /dispatch（remote worker）
        │
[6] 调试 ────── /triage（入口分诊）→ /debug（深度调试）
        │
[7] 验证 ────── /verify
        │
[8] Review ──── /review
        │
[9] 收尾 ────── /finish
        │
[10] 持续改进 ── /architecture

═══════════════════════════════════════════════════
全程注入：反理性化 + 不信任原则 + Git Guardrails
```

### 核心设计决策

| 决策 | 内容 | 理由 |
|------|------|------|
| 骨肉分离 | Pocock 做骨架（需求→计划→Issue→架构），Superpowers 做肌肉（纪律+审查+验证） | 各取所长，避免功能重叠 |
| 两层计划制 | Phase Plan（给人看，不写文件路径）+ Task Plan（给 agent 看，精确到代码） | 耐久性与可执行性兼得 |
| 双轨执行 | Issue 驱动（remote worker，AFK）+ 子 agent 驱动（local workstation，实时） | 适配双机架构 |
| TDD 融合 | Pocock 6 个设计哲学文件 + Superpowers Iron Law + 15 条借口封堵 | 设计深度 + 执行纪律 |
| 反理性化注入 | 35 条借口表 + 54 条 Red Flags 分散注入各技能 | 不是独立环节，而是全程免疫系统 |

### 14 个触发词速查

| 触发词 | 环节 | 来源 |
|--------|------|------|
| `/brainstorm` `/grill-me` | 需求探索 | SP + P 融合 |
| `/prd` | PRD 编写 | P |
| `/plan` | 架构计划 | P |
| `/issues` | Issue 拆解 | P |
| `/tasks` | 任务计划 | SP |
| `/execute` | 子 agent 执行 | SP |
| `/dispatch` | Issue 派发 | P + 双机 |
| `/tdd` | 编码 | P + SP 融合 |
| `/triage` | Bug 分诊 | P（已增强） |
| `/debug` | 深度调试 | SP |
| `/verify` | 完成前验证 | SP |
| `/review` | Code Review | SP |
| `/finish` | 收尾 | SP + P |
| `/architecture` | 架构改进 | P |

### 关键文件位置

| 文件 | 路径 |
|------|------|
| 统一路由 | `~/.claude/skills/unified-dev-pipeline/SKILL.md` |
| Pocock 技能 | `~/.agents/skills/` |
| Superpowers 插件 | `~/.claude/plugins/cache/superpowers-marketplace/superpowers/5.0.5/` |
| 融合/提取技能 | `~/.agents/skills/{verification-before-completion,receiving-code-review}/` |
| 不信任原则 | `~/.agents/skills/_principles/distrust.md` |
| 触发提醒规则 | `~/.claude/projects/-Users-example/memory/feedback_pocock_skills_reminders.md` |
| 管线索引 | `~/.claude/projects/-Users-example/memory/pocock-skills.md` |

---

## 锻造素材收件箱

> 看到好的实践、技巧、工作流片段，先扔这里。攒 3-5 条后做一次集中锻造 session。
> 每条记录：来源 + 核心点 + 可能解决的痛点。没有明确痛点的不放。

- 2026-05-14 | UDP v2 foundation | 目标是把 `unified-dev-pipeline` 从一次 Pocock × Superpowers 融合产物升级为 Human coding SOP 控制层；先冻结 SOP contract，再写 adapter matrix，最后决定吸收哪些上游更新。计划见 `playbooks/udp-v2-foundation-plan.md`。

---

## 锻造原则

1. **一个问题**：这解决了我当前工作流的什么痛点？答不上来就丢掉。
2. **熔炼不是搬运**：提取有价值的机制，融入已有结构。不照搬别人的流程框架。
3. **收件箱缓冲**：不即时融合。攒批后集中判断，避免频繁微调。
4. **版本留痕**：每次锻造后更新版本号，记录 what + why + 来源。
5. **主干收敛**：业务无关的改进都收敛到同一条管线。只有处理本质不同的业务时才允许分叉。

---

## 演进历史

### v2 foundation-router — 同名入口接管（2026-05-14）

**状态**：已落地。`unified-dev-pipeline` 继续作为正式名称，旧 v1 融合实现废弃。

**动机**：Pocock / Superpowers 上游继续迭代后，旧 UDP 不应作为一次性融合副本继续强行同步。新地基把 UDP 定义为 Human coding SOP 控制层，再用 adapter matrix 吸收上游变化。

**已完成**：
- 新增 `playbooks/udp-v2-foundation-plan.md`
- 改写 `playbooks/unified-dev-pipeline.md` 为 SOP contract
- 改写 `playbooks/unified-dev-pipeline-reference.md` 为 adapter reference + upstream watch registry
- 修 `~/.claude/scripts/upstream-diff.py`，支持 GitHub tree 定位 Pocock 多层 `skills/*/<name>/SKILL.md`，并输出 `path` / `content` / `semantic` 分类
- 审 Pocock / Superpowers 当前 adapter 候选，冻结吸收 / 不吸收决策
- 改写 `~/.agents/skills/unified-dev-pipeline/SKILL.md` 为薄路由
- 安装首批 Pocock adapter：`setup-matt-pocock-skills`、`diagnose`、`grill-with-docs`
- 将 `git-guardrails-claude-code`、`grill-me` 的上游路径更新到 Pocock 新目录
- 将 `tdd` 选择性同步到 Pocock `e74f0061bb67`，保留 Human-local Iron Law 与 Superpowers checklist
- 安装 Pocock `triage` issue 状态机，旧 `triage-issue` 降为兼容 shim
- 选择性同步 `write-a-prd` 与 `prd-to-issues`，保留 Human-local 访谈流、HITL/AFK 和两层计划 bridge
- 升级 `improve-codebase-architecture` 到 Pocock 新 glossary / ADR / deepening 语义
- 复核 Superpowers v5.1.0：Codex 插件 skills 与 upstream `f2cbfbefebbf` 一致；Claude `superpowers@superpowers-marketplace` 已通过 plugin manager 升级到 `5.1.0`

**下一步**：
- 只保留例行 upstream watch；新变化按 `path/content/semantic/major` 分类处理

### v1.0 — Pocock × Superpowers 融合落地（2026-03-24）

**来源**：Matt Pocock 技能体系 + Jesse Vincent Superpowers v5.0.5
**动机**：两套独立的优秀工作流，各有盲区。Pocock 缺验证和 CR，Superpowers 缺架构和设计哲学。

**锻造过程**：
1. **独立分析**（各出学习报告）→ 识别各自强项和盲区
2. **可行性评估**（9 维度互补性分析）→ 唯一冲突点：计划粒度
3. **设计融合方案 v1** → 确定"骨肉分离"原则
4. **逐文件审读 + v2 方案** → Agent Teams 基于源文件事实出具终版
5. **Phase 1-3 部署** → 14 个文件改动，全部落地

**关键产出**：
- 10 环节统一管线
- 14 个触发词
- TDD 融合版（设计哲学 + 执行纪律）
- 反理性化全程注入
- 不信任原则共享文件
- 两层计划制

**详细文档**：
- 分析：`~/Documents/Pocock技能学习报告.md`、`~/Documents/Superpowers技能学习报告.md`
- 方案 v1：`~/Documents/Pocock×Superpowers统一整合方案.md`
- 方案 v2（终版）：`~/Documents/Pocock×Superpowers统一整合方案-v2.md`

### v0 — 基线（2026-03 之前）

独立使用各技能，无统一管线。Pocock 和 Superpowers 分别安装，靠用户记忆选择用哪个。认知负荷高，经常跳过应该执行的环节。
