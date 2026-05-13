# Claude 共享入口

本文件是 Claude 本地入口的薄适配层。

最小冷启动只读：

1. `/path/to/AI-Shared/README.md`
2. `/path/to/AI-Shared/agents/claude.md`

仅在以下情况追加读取：

- 需要写回共享层，或边界不清：`/path/to/AI-Shared/rules/policy.md`
- 需要项目延续：相关 `projects/<name>/project.md` 和 `handover.md`
- 需要稳定用户画像：相关 `profile/*` 或 `projects/private-profile-overlay/*`

说明：

- `~/.claude` 继续保存 Claude 自身原始会话、计划文件、插件和运行态
- 不把 `history.jsonl`、`projects/**/*.jsonl` 等原始历史当作共享记忆
- 如果本地 `rules`、`projects`、`memory` 或本地投影副本出现长期知识增量，先登记 `/path/to/AI-Shared/handoff/sync-queue.md`，再判断是否回写共享层；运行态和临时产物不要同步
- 如果上述必读路径实际读不到内容，先阻断依赖该上下文的任务并汇报；不能把“知道路径”当作“已读内容”
