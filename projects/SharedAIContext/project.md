# SharedAIContext

## 用途

把 `/path/to/AI-Shared` 建成 Codex、Claude、Gemini、Kimi 共用的长期知识主仓。

## 范围

- 共享规则与薄适配说明
- 共享用户画像、健康和自我探索材料
- 共享记忆索引、决策与行为纠偏
- 共享项目定位、操作手册、观察记录和交接页
- 共享方法手册、提示模式与延续线索
- 根入口和本地入口投影所依赖的来源文件

## 非范围

- 原始聊天历史
- sqlite/jsonl 运行态
- 当前生效设置、钩子、计划文件和锁文件
- 插件运行态或缓存
- 被当成当前正式文档读取的迁移备份

## 状态

- 2026-04-06 以 `v0` 骨架形式初始化。
- 2026-04-06 从“只放蒸馏层”改成“长期知识主仓”。
- 第一轮完整共享知识迁移的基础已经完成。
- 本地入口已指向 `AI-Shared`；本地 `MEMORY.md` 现在主要承担路由和运行态说明。

## 当前成熟度

- 基础状态：可用
- 正式边界：长期文档在 `AI-Shared`，运行态在本地目录
- 当前阶段：持续维护和刷新，不再是首次迁移阶段

## 正式导航

- 共享目录索引位于 `rules/README.md`、`profile/README.md`、`memory/MEMORY.md`、`projects/README.md`、`playbooks/README.md`、`continuations/README.md` 和 `entrypoints/README.md`。
- 迁移历史相关观察记录继续保留在 `observations/`。
