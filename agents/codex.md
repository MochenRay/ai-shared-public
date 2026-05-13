# Codex 适配说明

## 最小读取

- 先读 `README.md` 和本文件。
- 第一次写回共享层前，或本地与共享层边界不清时，再读 `rules/policy.md`。
- 项目、画像、方法手册、延续线索和共享记忆按需读取。

## 执行纪律

- 动手前先说明关键假设；如果存在多个合理解释，先列出来；不确定性会影响正确性时，先问清楚再继续。
- 默认选满足需求的最简单实现；不要顺手加功能、做单次使用的抽象，或补未请求的“灵活性/可配置性”；能 50 行解决就不要写成 200 行。
- 改动要外科手术式收口；匹配现有项目风格，不顺手改周边代码、注释或格式；发现死代码可以指出，但除非被要求，否则不要直接删除。
- 把任务改写成可验证的完成标准；多步任务先给一个简短计划，并在收尾前按这些标准检查结果。
- 严格区分“已冻结 / 待执行 / 执行中 / 已验证完成 / 后续增量”；不要把 plan 或 contract 已存在误说成 phase 已完成，回答阶段问题前先对照验证证据和当前 HEAD。
- 如果冷启动、项目延续、写回前置或用户明确要求读取的文件/目录未实际读到内容，先阻断依赖该上下文的任务并汇报；不能把“知道路径”当作“已读内容”。

## 默认并行

- 对中大型实现、跨模块改造、可并行的排障或联调任务，默认优先使用 `git worktree + agents 集群`。
- 如果目标还不是 Git 目录，默认先用 `agents` 集群并行，收口后再统一 Git 化。
- 只有任务很小、高度耦合、或阻塞点是单一事实核查或单机实验时，才默认不启用并行。
- 细则统一见 `rules/policy.md`，本文件只保留短提示。

## 默认表达

- 默认启用 `caveman`，模式为 `wenyan-full`。
- 这是表达层规则，不削弱事实核查、验证、风险提示、文件引用和执行纪律。
- 用户说关闭、普通模式或不用文言时，本轮会话按用户要求切换；细则统一见 `rules/policy.md`。

## 审 Kimi 产出

- 当任务是评价、调教或接手 Kimi 产出时，读取 [`playbooks/kimi-model-calibration.md`](../playbooks/kimi-model-calibration.md)。
- 先区分 `host/tool`、`model`、`source artifact`、`installed/runtime target`；尤其注意 Kimi 可能由 Claude Code、remote-agent-host 等 host 调用，而不只是 Kimi CLI。

## 本地运行态边界

Codex 继续把以下内容留在本地：

- `~/.codex/history.jsonl`、`sessions/`、`archived_sessions/`、sqlite 文件
- 当前生效设置、插件缓存和运行态
- Codex 必须直接拥有的原生运行文件

## 默认写回目标

Codex 的长期文档默认写到：

- `/path/to/AI-Shared`

其中包括：

- 共享规则文档
- 项目首页、交接页、操作手册和观察记录
- 用户画像与探索材料
- 可复用的方法手册与提示模式

## 同步规则

- 把 `AI-Shared` 视为长期 Markdown 文档的唯一正式来源。
- 写共享层前，先对照当前共享层正式文档，再判断本地材料的稳定增量。
- 如果 Codex 为了启动保留了本地规则或入口文件，把它当成本地投影副本，不当成正式来源。
- Codex CLI 目前不支持本地 hooks；本地长期文档改动后，手动登记 `handoff/sync-queue.md`，再判断是否回写共享层。
- 运行态噪音、sqlite/jsonl 状态和工具缓存继续留在本地。
- 共享层更新完成后，只有在确实能改善启动行为或发现性时，才刷新本地指针或投影副本。
- 大改前可先运行 `scripts/compare-shared-context.sh <local> <shared>` 辅助比对。
- 写回共享层后，立即查看 `scripts/validate-shared-writeback.sh` 的提醒结果，并在当轮处理。

### 通用规则同步

- 用户新增通用规章、长期协作要求或跨模型流程时，不要只更新当前模型适配页；同步检查并更新 `agents/codex.md`、`agents/claude.md`、`agents/gemini.md`、`agents/kimi.md` 的相关入口。
- 只有规则明确属于单一模型能力或运行态限制时，才允许只写单个 `agents/<model>.md`。

### Skill 安装默认跨模型

- 用户要求安装 skill / 技能 / GitHub skill repo 且未明确指定单一模型时，默认安装到 `~/.agents/skills/` 并验证跨模型可见；不要停在 `~/.codex/skills` 单端安装。
- 只有用户明确说 Codex-only，或该 skill 是 Codex 工具原生例外时，才写 `~/.codex/skills`。细则见 `rules/skills-governance.md`。

### 多仓发布闭环顺序

当一次发布同时涉及项目仓、投影仓和 `AI-Shared` 状态写回时，`AI-Shared` 必须最后 PR+merge：

1. 先完成项目仓 PR+merge。
2. 再同步投影仓，完成投影仓 PR+merge，并跑 stale / 公网 smoke 等远端验证。
3. 最后一次性更新 `AI-Shared` 的项目状态、交接页和 changelog，再 PR+merge。

不要先合并共享仓状态后再继续改项目仓或投影仓；否则共享层会记录尚未稳定的中间态，并在后续动作后再次偏移。

### 写前三检（无 hooks 的补偿控制）

在写入 AI-Shared 任何文件前，先确认：
1. **路径合法**：对照 `manifest.md` 的守卫写入白名单
2. **行数安全**：写后文件不超过 200 行；如需超长，在白名单登记
3. **变更登记**：长期文档修改后，在 `handoff/sync-queue.md` 登记待判断条目

## 新建规则

- 新的长期 Markdown 文档默认建在 `AI-Shared`。
- 新的本地文件只有在内容属于运行态，或 Codex 明确要求本地投影副本时才成立。
- 如果共享 Markdown 文档超过 200 行，就判断是拆分、压缩，还是暂时保留；超过 300 行时默认优先拆成“母文件 + 子文件”。

## 常见写回位置

- 共享规则 -> `rules/`
- 用户事实与探索材料 -> `profile/`
- 已确认共享决策 -> `memory/decisions.md`
- 可复用的方法 -> `playbooks/*.md`
- 未完成但值得继续的探索 -> `continuations/*.md`
- 本地变更待判断事项 -> `handoff/sync-queue.md`
- 当前协作事项 -> `handoff/inbox.md`
- 项目续写状态 -> `projects/<name>/handover.md`
