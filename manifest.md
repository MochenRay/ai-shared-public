# 清单

> 最近更新：2026-04-29
> 状态：当前生效
> 范围：Codex、Claude、Gemini、Kimi 共用的长期知识主仓
> 说明：本文件用于维护、索引和守卫配置，不是最小冷启动路径。

## 正式入口文件

- `README.md`：共享层总入口与使用说明
- `agents/<model>.md`：模型适配说明
- `rules/policy.md`：共享层正式规则
- `rules/README.md`：规则索引
- `profile/README.md`：画像索引
- `memory/MEMORY.md`：共享记忆索引
- `projects/README.md`：项目索引
- `playbooks/README.md`：方法手册索引
- `continuations/README.md`：延续线索索引
- `entrypoints/README.md`：入口投影索引
- `handoff/sync-queue.md`：本地变更待判断队列
- `handoff/changelog.md`：变更日志索引与入口

## 目录约定

### `rules/`

- 共享层正式规则文档放在这里。
- 内容已经一致的规则，优先在这里收敛。
- 直接影响启动的规则保持短小；补充说明放到子文件。

### `profile/`

- 用户级事实、偏好、健康基线和自我探索材料。
- 当子目录能让结构更清楚时，可以继续细分。
- `README.md` 负责暴露当前生效的画像树。

### `memory/`

- 共享索引、稳定事实、已确认决策、纠偏摘要和待决问题。
- 不放原始聊天记录或隐藏推理倾倒。

### `projects/`

- 每个项目或运行域一个目录。
- `project.md` 保存稳定定位。
- `handover.md` 保存当前状态和下一步上下文。
- `changelog/YYYY/YYYY-MM.md` 用于记录该项目自己的冻结、实现、验证和推进历史。
- `runbooks/`、`observations/`、`reference/` 等子目录可以用于放长期项目文档。
- `README.md` 负责暴露当前生效的项目树。

### `playbooks/`

- 可复用的方法手册与稳定流程模式。
- 这里放方法，不放一次性任务过程。

### `continuations/`

- 跨模型仍值得继续的未完成线索。
- 这里放方向，不放原始对话回放。

### `handoff/`

- `sync-queue.md` 用于记录“本地长期文档变更，是否需要同步共享层”的待判断事项。
- `inbox.md` 用于短期跨模型协作事项。
- `changelog/YYYY/YYYY-MM.md` 用于记录共享层全局变更的月志正文。
- `changelog.md` 只做索引；全局与项目级正文分别写入对应的月志文件。

### `agents/`

- Codex、Claude、Gemini、Kimi 的薄适配说明。
- 如果只是模型启动行为差异，先写在这里，不要先新建规则文件。

### `entrypoints/`

- 根入口和本地入口投影的来源文件。
- 本地已部署入口可以从这里复制。

### `backups/`

- 只用于归档快照。
- 正常遍历和写回时排除。
- 仅在迁移审计或恢复时读取。

## 守卫写入白名单

<!-- guard-write-globs:start -->
- `README.md`
- `manifest.md`
- `AGENTS.md`
- `CLAUDE.md`
- `GEMINI.md`
- `rules/*.md`
- `rules/*/*.md`
- `agents/*.md`
- `profile/*.md`
- `profile/*/*.md`
- `memory/*.md`
- `memory/*/*.md`
- `playbooks/*.md`
- `continuations/*.md`
- `handoff/*.md`
- `handoff/*/*.md`
- `handoff/*/*/*.md`
- `projects/*.md`
- `projects/*/*.md`
- `projects/*/*/*.md`
- `projects/*/*/*/*.md`
- `entrypoints/*.md`
- `entrypoints/*/*.md`
- `scripts/*.sh`
<!-- guard-write-globs:end -->

## 行数守卫

- 统一写后检查会从这里读取行数阈值和白名单。
- 超过 200 行时提醒判断是否拆分、压缩或暂时保留。
- 超过 300 行时强提醒，默认优先拆成“母文件 + 子文件”。
- 如果某个文件确实要暂时保持超长，请先在白名单登记。

<!-- 行数提醒阈值:200 -->
<!-- 行数强提醒阈值:300 -->
<!-- 行数白名单:start -->
<!-- 行数白名单:end -->

## 不负责的事情

- 统一原始会话存储
- 共享 sqlite 或 jsonl 运行文件
- 替代各模型原生的记忆系统
- 把当前生效设置和钩子当成共享 Markdown 记忆

## 冲突处理

详见 `rules/policy.md`。

本文件只负责索引和守卫配置，不重复正文规则。
