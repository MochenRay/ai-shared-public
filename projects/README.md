# Projects

本目录用于保存项目或运行域的长期定位、当前 handover、操作手册、观察记录、冻结合同和项目级 changelog。

公开版包含：

- `SharedAIContext/`：共享上下文机制说明
- `SkillsInfrastructure/`：跨模型 skills 治理说明
- `ExampleProject/`：项目目录形态示意，不含真实业务内容

## Project Shape

```text
projects/<Name>/
  project.md
  handover.md
  plans/
  reference/
  runbooks/
  observations/
  changelog/
```

## Boundary

- `project.md`：稳定定位和边界。
- `handover.md`：当前快照和下一步入口。
- `plans/`：阶段计划或任务拆解。
- `reference/`：冻结合同、技术基线、长期参考。
- `runbooks/`：可重复执行的操作流程。
- `observations/`：已整理的观察记录，不放原始聊天。
- `changelog/`：项目级推进历史。
