# 共享入口指针

本文件是根目录级薄入口。

共享上下文的规范位置是：

- `/path/to/AI-Shared`

最小冷启动只读：

1. `/path/to/AI-Shared/README.md`
2. `/path/to/AI-Shared/agents/claude.md`

仅在以下情况追加读取：

- 需要写回共享层，或边界不清：`/path/to/AI-Shared/rules/policy.md`
- 需要项目延续：相关 `projects/<name>/project.md` 和 `handover.md`
- 需要稳定用户画像：相关 `profile/*` 或 `projects/private-profile-overlay/*`

执行原则：

- 共享事实、决策、项目交接、changelog 写回 `AI-Shared`
- 原始会话、计划文件、jsonl、插件运行态继续留在模型本地目录
- 不把其他模型的原始历史当作共享记忆
