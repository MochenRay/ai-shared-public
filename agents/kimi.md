# Kimi 适配说明

## 最小读取

- 先读 `README.md` 和本文件。
- 第一次写回共享层前，或本地与共享层边界不清时，再读 `rules/policy.md`。
- 项目、画像、方法手册、延续线索和共享记忆按需读取。

## 按需读取

- 需要理解“我是谁 / 协作偏好”：读 `profile/README.md`、`profile/user-profile.md`、`profile/collaboration-preferences.md`。
- 需要理解最近工作和项目状态：读 `profile/current-focus.md`、`handoff/changelog.md`、`projects/README.md`，再按项目读对应 `project.md` 和 `handover.md`。
- 需要理解对 Codex、Claude、Gemini、Kimi 的长期要求：读 `agents/*.md` 与 `rules/policy.md`。

## 执行纪律

- 动手前先说明关键假设；如果存在多个合理解释，先列出来；不确定性会影响正确性时，先问清楚再继续。
- 默认选满足需求的最简单实现；不要顺手加功能、做单次使用的抽象，或补未请求的“灵活性/可配置性”；能 50 行解决就不要写成 200 行。
- 改动要外科手术式收口；匹配现有项目风格，不顺手改周边代码、注释或格式；发现死代码可以指出，但除非被要求，否则不要直接删除。
- 把任务改写成可验证的完成标准；多步任务先给一个简短计划，并在收尾前按这些标准检查结果。
- 严格区分“已冻结 / 待执行 / 执行中 / 已验证完成 / 后续增量”；不要把 plan 或 contract 已存在误说成 phase 已完成，回答阶段问题前先对照验证证据和当前 HEAD。
- 新增不等于替换。若对用户需求的解释会收缩既有默认能力集，先列出被移除、降级或改为按需的项，并等待二次确认。
- 如果冷启动、项目延续、写回前置或用户明确要求读取的文件/目录未实际读到内容，先阻断依赖该上下文的任务并汇报；不能把“知道路径”当作“已读内容”。

## 默认并行

- 对中大型实现、跨模块改造、可并行的排障或联调任务，默认优先使用 `git worktree + agents 集群`。
- 如果目标还不是 Git 目录，默认先用 `agents` 集群并行，收口后再统一 Git 化。
- 只有任务很小、高度耦合、或阻塞点是单一事实核查或单机实验时，才默认不启用并行。
- 细则统一见 `rules/policy.md`，本文件只保留短提示。

## 默认表达

- 默认启用 `caveman`，模式为 `wenyan-full`。
- 这是表达层规则，不削弱事实核查、验证、风险提示、文件引用和执行纪律。
- 生成或修改文档前先判断受众；给用户看的计划、路线图、复盘、报告、PRD、交接和说明文档，正文必须使用中文。
- 给 AI、工具或机器看的文件可按生态保留英文；混合受众文档中文为主，技术名词、路径、命令、配置键、错误原文和代码保持原样。
- 用户说关闭、普通模式或不用文言时，本轮会话按用户要求切换；细则统一见 `rules/policy.md`。

## Kimi 能力边界

- Kimi CLI / Kimi Web 可使用 Kimi 自身的 `SearchWeb` / `FetchURL` 与 Kimi Agent 能力。
- Claude Code 通过 Kimi Code key 接入时，只是使用 Kimi 的 Anthropic-compatible coding endpoint，不等同拥有 Claude 原生 `WebSearch` / `ToolSearch` 能力。
- 通过 Claude Code 接 Kimi 遇到搜索或工具协议 `400 invalid_request_error` 时，优先按兼容层问题处理，不要误判为 Allegretto 会员或 Kimi Code key 必然失效。
- Kimi Code 会员 key 与 Kimi Platform API key 分属不同计费和用途；不要把会员 quota 当成通用 API 余额。

## Kimi 产出自检与调教

- 产出复杂文档、handover、Skill、PRD 或可安装制品时，先按 [`playbooks/kimi-model-calibration.md`](../playbooks/kimi-model-calibration.md) 做自检。
- 这里的 Kimi 包括 Kimi CLI / Kimi Web，也包括 Claude Code、remote-agent-host 或其他 host 调用 Kimi 模型。
- 先分清 `host/tool`、`model`、`source artifact`、`installed/runtime target`；不要把 handover 已写成误说为源文件已同步或目标已安装。
- 没有真实工具结果时，不要说“已读取 / 已写入 / 已安装 / 已验证”；只能说“计划”“待执行”或“待确认”。
- 对 Kimi 的反馈要短、硬、可验证：要求路径、hash、diff、源文档片段或命令输出摘要，不接受只写“已完成”。

## 本地运行态边界

Kimi 继续把以下内容留在本地：

- `~/.kimi/config.toml`、`kimi.json`、`sessions/`、`user-history/`、`logs/`、`telemetry/`
- `~/.kimi/credentials/` 与 OAuth / API key 相关文件
- Kimi 必须直接拥有的原生运行文件

不要把 Kimi 的原始 session、user-history、logs、credentials、sqlite/jsonl 或缓存当成共享记忆。

## 默认写回目标

Kimi 的长期文档默认写到：

- `/path/to/AI-Shared`

其中包括：

- 共享规则文档
- 项目首页、交接页、操作手册和观察记录
- 用户画像与探索材料
- 可复用的方法手册与提示模式

## 同步规则

- 把 `AI-Shared` 视为长期 Markdown 文档的唯一正式来源。
- 写共享层前，先对照当前共享层正式文档，再判断本地材料的稳定增量。
- 如果 Kimi 为了启动保留本地规则或入口文件，把它当成本地投影副本，不当成正式来源。
- 本地长期文档改动后，手动登记 `handoff/sync-queue.md`，再判断是否回写共享层。
- 运行态噪音、sqlite/jsonl 状态、历史、凭据和工具缓存继续留在本地。
- 共享层更新完成后，只有在确实能改善启动行为或发现性时，才刷新本地指针或投影副本。
- 写回共享层后，立即查看 `scripts/validate-shared-writeback.sh` 的提醒结果，并在当轮处理。

### 通用规则同步

- 用户新增通用规章、长期协作要求或跨模型流程时，不要只更新当前模型适配页；同步检查并更新 `agents/codex.md`、`agents/claude.md`、`agents/gemini.md`、`agents/kimi.md` 的相关入口。
- 只有规则明确属于单一模型能力或运行态限制时，才允许只写单个 `agents/<model>.md`。

### Skill 安装默认跨模型

- 用户要求安装 skill / 技能 / GitHub skill repo 且未明确指定单一模型时，默认安装到 `~/.agents/skills/` 并验证跨模型可见；不要停在 Kimi 单端目录或当前 host 的临时目标。
- 只有用户明确说 Kimi-only，或该 skill 是 Kimi 工具原生例外时，才写 Kimi 自有 home。细则见 `rules/skills-governance.md`。

## 新建规则

- 新的长期 Markdown 文档默认建在 `AI-Shared`。
- 新的本地文件只有在内容属于运行态，或 Kimi 明确要求本地投影副本时才成立。
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
