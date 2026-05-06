# 共享知识主仓

> Public export note: this is a sanitized template/example export of a private
> shared-context repository. Private memory, profile material, handoff logs,
> backups, archived material, credentials, and private project records are
> intentionally excluded. See `PUBLIC_EXPORT_MANIFEST.md`.

> 规范路径：`/path/to/AI-Shared`
> 用途：作为 Codex、Claude、Gemini、Kimi 共用的长期文档与知识主仓。

## 这个目录是什么

这里用于保存会跨会话、跨模型持续复用的文档与知识。

适合放在这里的内容：

- 稳定事实与已确认决策
- 用户画像、健康基线、自我探索材料
- 项目首页、交接页、操作手册、观察记录
- 可复用的方法手册与提示模式
- 共享规则与模型适配说明
- 根入口与本地入口的来源文件

不该放在这里的内容：

- 原始聊天历史
- 隐藏推理
- sqlite/jsonl 运行文件
- 工具缓存与插件运行态
- 当前生效设置、锁文件、临时计划

## 最小启动路径

默认冷启动只读：

1. `README.md`
2. `agents/<model>.md`

只在需要时再继续读取：

- `rules/policy.md`：第一次写回共享层前，或边界不清时
- `rules/README.md`：需要浏览规则目录时
- `profile/README.md`：需要稳定用户画像时
- `projects/README.md`：需要选择或浏览项目文档时
- `playbooks/README.md`：需要复用方法与流程模式时
- `continuations/README.md`：需要延续未完成线索时
- `memory/MEMORY.md`：需要跨项目记忆索引时
- `entrypoints/README.md`：需要维护根入口或本地入口投影时
- `handoff/sync-queue.md`：本地长期文档发生变化，需要判断是否同步共享层时
- `handoff/inbox.md` 与 `handoff/changelog.md`：需要跨模型协作、追踪全局历史或跳转到项目月志时

## 默认并行策略

- 对中大型实现、跨模块改造、可并行的排障或联调任务，默认优先使用 `git worktree + agents 集群` 并行推进。
- 如果目标已经是 Git 仓库，主线程先冻结共享合同，再拆 `worktree` 与 `agent` 边界。
- 如果目标还不是 Git 目录，主线程先冻结共享合同和目录边界，再用 `agents` 集群并行推进；是否 Git 化，放到收口后统一决定。
- 只有任务很小、高度耦合、或当前阻塞点是单一事实核查/单机实验时，才默认不启用集群。
- 这不是可选建议，而是默认执行方式；细则见 `rules/policy.md`。

## 默认表达压缩

- Codex、Claude、Gemini、Kimi 默认启用 `caveman` 表达压缩，默认模式为 `wenyan-full`。
- 这是表达层规则，不削弱事实核查、验证、风险提示、文件引用和执行纪律。
- 用户明确说关闭、普通模式或不用文言时，本轮会话按用户要求切换；细则见 `rules/policy.md`。

## 正式边界

- `AI-Shared` 默认是长期 Markdown 文档的正式来源。
- 只要是长期文档，即使内容很详细、暂时主要由某一个模型使用，也默认放在这里。
- 本地目录只对运行态和工具原生配置负责。
- 如果本地长期内容已经稳定，应优先提升到 `AI-Shared`，不要把本地副本长期当成正式版本维护。
- 如果某个工具为了自动加载必须保留本地副本，本地文件是投影副本，不是第二份正式来源。
- 但如果某个项目已经在 `AI-Shared/projects/README.md` 中被明确标注为“已归档”或“正式来源已回迁本地仓库”，则以该项目页说明为准，不再把 `AI-Shared` 视为它的正式来源。
- 当前已知例外：`WorkflowLearnSystem` 已归档到 `archive/WorkflowLearnSystem/`，正式来源在本地仓库 `VibeDoingEverything/VibeDoing/WorkflowLearn/_系统/WorkflowLearnSystem/`。

## 备份边界

- `backups/` 只用于归档。
- 正常遍历、读取、写回时忽略 `backups/`。
- 只有在审计迁移历史或恢复旧快照时才读取其中内容。

## 启动提示词

新开 Codex、Claude、Gemini、Kimi 会话时，可以直接使用下面这段话：

```text
请把 /path/to/AI-Shared 视为 Codex、Claude、Gemini、Kimi 共用的长期知识主仓。
先读取 README.md 和 /path/to/AI-Shared/agents/<model>.md。
只有在准备写回共享层，或边界不清时，再读取 /path/to/AI-Shared/rules/policy.md。
如果本地长期文档发生变化，先看 /path/to/AI-Shared/handoff/sync-queue.md，登记候选项，再判断是否回写共享层正式文档。
中大型实现、跨模块改造、可并行排障或联调任务，默认优先使用 git worktree + agents 集群；只有任务很小、高度耦合、或阻塞点是单一事实核查/单机实验时，才默认不启用并行。
正常工作时忽略 /path/to/AI-Shared/backups。
不要把原始聊天历史、sqlite/jsonl 文件、缓存、插件运行态或当前生效设置当成共享记忆。
把长期事实、规则、操作手册、方法手册、画像更新、延续线索、决策、项目交接和 changelog 记录写回 AI-Shared。
```

## 写回后检查

- 共享层统一写后检查脚本是 `scripts/validate-shared-writeback.sh`。
- Markdown 文档超过 200 行时会提醒你判断：拆分、压缩，还是暂时保留。
- 超过 300 行时会触发强提醒，默认优先拆成“母文件 + 子文件”。
- 如果本地长期文档发生了变化，但还没判断要不要同步，可以先登记到 `handoff/sync-queue.md`。
- 目标是支持渐进式加载，不是为了变短而直接删掉内容。

## 目录总览

- `rules/README.md`：规则索引与旧入口说明
- `profile/README.md`：用户画像、健康与自我探索索引
- `memory/MEMORY.md`：稳定记忆、决策与待决问题索引
- `projects/README.md`：项目首页、交接页、操作手册与观察记录索引
- `playbooks/README.md`：可复用的方法手册
- `continuations/README.md`：可继续延展的线索
- `handoff/`：跨模型协作记录、同步队列与变更历史
- `agents/`：模型适配说明
- `entrypoints/README.md`：根入口与本地入口投影的来源文件
- `backups/`：迁移归档快照，正常遍历时排除

## 本地运行态

以下目录继续保存各模型的本地运行态：

- Codex：`~/.codex`
- Claude：`~/.claude`
- Gemini：`~/.gemini`
- Kimi：`~/.kimi`

这些目录可以保留原始会话、计划、缓存、插件状态、当前生效设置和工具原生运行文件。
