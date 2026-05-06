# 统一开发管线

## 用途

把需求、实现、验证、评审收敛成一条稳定工作流，减少每次都要重新判断“现在该用哪套方法”的负担。

## 阶段地图

1. `brainstorm`：需求探索与方案讨论
2. `prd`：写需求文档，收拢边界
3. `plan`：做架构与阶段计划
4. `issues` / `tasks`：拆 issue 或 agent 任务
5. `execute` / `dispatch`：选择执行路线
6. `triage` / `debug` / `tdd`：bug 分诊、根因分析、编码修复
7. `verify`：验证，不带证据不声称完成
8. `review`：代码审查，不盲从外部反馈
9. `finish`：收尾、合并或归档
10. `architecture`：架构改进和深模块治理

## 典型路线

- 新功能：`brainstorm -> prd -> plan -> [codex-qa] -> issues/tasks -> execute/dispatch -> [codex-verify] -> verify -> review -> finish`
- Bug 修复：`triage -> debug（如需要） -> tdd -> verify -> review -> finish`
- 小改动：`tdd -> verify -> finish`

> `[codex-qa]` 和 `[codex-verify]` 是可选的跨模型异构审查节点，见下方「跨模型 QA」章节。

## 默认并行分流

1. 先判断任务是否命中默认并行条件：中大型实现、跨模块改造、可并行的排障或联调。
2. 再判断目标是否已经在 Git 中。
3. 如果目标已经是 Git 仓库，默认路径是 `git worktree + agents 集群`。
4. 如果目标还不是 Git 目录，默认路径是 `agents 集群` 先行，Git 放到收口后统一处理。
5. 只有任务很小、高度耦合、或阻塞点是单一事实核查/单机实验时，才默认不启用集群。

## 主线程流程

1. 冻结共享合同。
2. 判断是 `worktree + agents`，还是 `agents` 直接并行。
3. 按边界拆分子任务。
4. 派发给独立 `agent / worktree`。
5. 回收结果，解决冲突。
6. 做最终验证与验收。
7. 如有必要，再统一 Git 化或进入收尾。

## 共享合同最小模板

主线程在派发前，至少要明确以下 6 项：

- 目标
- 成功标准
- 真相层
- 边界
- 并行边界
- 集成顺序

如果这 6 项还没冻结，就不应提前大规模并行。

## 子线程规则

- 子 `agent / worktree` 只在自己边界内实现或排查。
- 不覆盖真相层和未合并改动。
- 返回改动范围、验证结果、未解决事项。
- 不自发扩边界；需要扩边界时，回到主线程重新冻结共享合同。

## 跨模型 QA（手动交接，选用）

> 前提：MacBook 同时开两个终端，Terminal 1 跑 Claude Code，Terminal 2 跑 Codex CLI（gpt-5.4 + xhigh）。

### 节点 1：`[codex-qa]` — 计划审查

Claude 在 Terminal 1 完成计划文件（如 `plans/feature-name.md`）后，切到 Terminal 2：

```bash
codex "Review plans/feature-name.md against the actual codebase.
Insert intermediate phases as 'Phase X.5' with 'Codex Finding' headings.
Append your findings only — do not rewrite or delete any existing phases."
```

你检查 Codex 的补充是否合理，决定是否采纳，再回 Terminal 1 继续。

### 节点 2：`[codex-verify]` — 实现核验

Claude 在 Terminal 1 完成实现后，切到 Terminal 2：

```bash
codex "Verify the implementation against plans/feature-name.md.
For each phase: PASS / FAIL / PARTIAL.
If FAIL or PARTIAL, explain what's missing and where."
```

### 触发条件（不是每次都要跑）

- 中大型功能（计划超过 3 个 phase）
- 涉及架构决策或跨模块改动
- 对自己的计划不够确定时

小改动和 bug 修复不需要跑跨模型审查，走原有路线即可。

---

## 稳定规则

- 这套管线的价值不在命令本身，而在把不同来源的方法论压成一个稳定阶段序列。
- 主流程应当稳定，边缘技能按需接入，避免主线被插件化能力稀释。
- `tdd`、`verify`、`review` 是三道硬约束节点，不应被跳过。
- 中大型任务默认优先并行，不需要等用户重复提醒。
- 最终只有主线程有权宣布本轮收口完成。
- 用户明显已经进入执行流、只做小修复、或没有新信息时，不反复插入方法论提示。

## 当前环境提示

- 在当前工作环境里，这些阶段名更适合作为阶段标签或意图口令，而不一定是原生命令。
- 具体触发词、技能映射、插件来源和安装位置，见 `unified-dev-pipeline-reference.md`。
- 不要把 playbook 写成大而空的流程宣讲；它只定义稳定阶段、并行分流和硬护栏。
