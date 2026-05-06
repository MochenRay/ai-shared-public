# 方法手册索引

## 用途

`playbooks/` 用来保存足够稳定、可以在 Codex、Claude、Gemini、Kimi 之间复用的方法与流程模式。

## 适合放这里的内容

- 工作流方法
- 阶段地图
- 任务拆分模式
- 跨会话仍然稳定的提示模式或记录模式

## 不该放这里的内容

- 项目快照
- 原始任务历史
- 对话回放
- 机器专属操作手册
- 还没有经过反复验证的一次性提示技巧

## 当前文件

- `unified-dev-pipeline.md`
- `unified-dev-pipeline-reference.md`
- `task-slicing.md`
- `todo-capture.md`
- `prompt-patterns.md`
- `dialogue-guardrails.md`
- `memory-maintenance.md`
- `rule-system-maintenance.md`
- `workflow-forging-record.md`
- `decision-validation.md` — 方案启动前的 6 维验证清单（工具选择、双机分工、安全边界、因果链、超级个体、复杂度）
- `handover-writing.md` — 项目 `handover.md` 的用途、结构、长度纪律与推荐模板
- `unified-dev-pipeline-sync.md` — `unified-dev-pipeline` 的 Pocock / Superpowers 上游同步流程
- `kimi-model-calibration.md` — Kimi 产出前自检、外部调教和审稿方法，覆盖 Kimi CLI/Web 与 Claude Code 等 host 调用 Kimi 模型的场景
