# 统一开发管线参考

## 用途

记录统一开发管线的触发词映射、技能编排和执行分流，方便不同模型在本地环境中落地同一套阶段方法。

## 触发词映射

| 触发词 | 阶段 | 技能/来源 | 典型落点 |
|------|------|------|------|
| `/brainstorm` `/grill-me` | 需求探索 | brainstorming / grill-me | 需求澄清 |
| `/prd` | PRD | write-a-prd | 需求文档 |
| `/plan` | 计划 | prd-to-plan | 架构与阶段拆解 |
| `/issues` | Issue 拆解 | prd-to-issues | GitHub 或任务清单 |
| `/tasks` | 任务计划 | writing-plans 等 | 轻量计划 |
| `/execute` | 执行 | subagent-driven development | 本地执行或 agent 分工 |
| `/dispatch` | 派发 | remote-agent-host / async node | 远端异步执行 |
| `/tdd` | 编码修复 | tdd | 红绿重构 |
| `/triage` | Bug 分诊 | triage-issue | 根因定位 |
| `/debug` | 深度调试 | systematic debugging | 调试路线 |
| `/verify` | 完成前验证 | verification-before-completion | 证据化收尾 |
| `/review` | 代码审查 | receiving-code-review | CR 与反馈吸收 |
| `/finish` | 收尾 | finishing-a-development-branch | 交付闭环 |
| `/architecture` | 架构改进 | improve-codebase-architecture | 深模块治理 |

## 并行路径速查

| 场景 | 默认路径 | 主线程动作 | 子线程动作 |
|------|------|------|------|
| 中大型 Git 仓实现 | `git worktree + agents 集群` | 冻结共享合同、拆 worktree、集成、验证 | 在独立边界内实现 |
| 中大型非 Git 改造 | `agents 集群` | 冻结共享合同和目录边界、集成、验证 | 在独立边界内实现 |
| 高度耦合改动 | 单线程 | 明确不并行原因 | 不派发 |
| 单一实验阻塞 | 单线程 | 做事实核查或单机实验 | 不派发 |
| 可并行联调/排障 | `git worktree + agents 集群` 或 `agents 集群` | 切分故障面和验证面 | 各自排查并返回证据 |

## 共享合同最小清单

主线程在并行前，至少要冻结：

- 目标
- 成功标准
- 真相层
- 边界
- 并行边界
- 集成顺序

如果这些内容没有写清，就不应启动默认并行。

## 例外条件速查

- 任务很小，单线程更快
- 改动高度耦合，拆开只会增加冲突
- 阻塞点是单一事实核查或单机实验，无法并行

不走并行时，主线程应明确说明命中了哪一条例外。

## 安装与来源

- Pocock 类技能：通常位于 `~/.agents/skills/`
- 本地提取/融合技能：位于 `~/.agents/skills/` 或模型 home 的 skill 入口
- Superpowers 风格插件：保留在各自工具的 plugin/cache 运行态
- 统一路由规则：应该优先沉淀到 `AI-Shared/playbooks/`，本地只保留启动所需 projection

## 使用原则

- 主 playbook 负责稳定阶段序列；本文件负责本地落地参考。
- 触发词和技能来源可能随工具环境变化，但阶段骨架应保持稳定。
- 默认并行不是“能并就并”的无序分拆，而是“先冻结合同，再拆边界”的受控并行。
- 当某个触发词失效时，优先保留阶段意图，不要把整个方法论绑死在某个插件名上。
