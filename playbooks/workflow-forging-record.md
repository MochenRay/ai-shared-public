# 统一工作流锻造记录

> **定位**：这是唯一的工作流演进主文档。所有改造、升级、新素材吸收都在此留痕。
> **原则**：一条主干，持续锻造。新材料是矿石，不是成品——熔炼后只保留让武器更锋利的部分。

---

## 当前版本：v1.0（2026-03-24）

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

（暂无待锻造素材）

---

## 锻造原则

1. **一个问题**：这解决了我当前工作流的什么痛点？答不上来就丢掉。
2. **熔炼不是搬运**：提取有价值的机制，融入已有结构。不照搬别人的流程框架。
3. **收件箱缓冲**：不即时融合。攒批后集中判断，避免频繁微调。
4. **版本留痕**：每次锻造后更新版本号，记录 what + why + 来源。
5. **主干收敛**：业务无关的改进都收敛到同一条管线。只有处理本质不同的业务时才允许分叉。

---

## 演进历史

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
