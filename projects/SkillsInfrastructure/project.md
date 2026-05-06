# Skills Infrastructure

## 项目定位

跨工具（Claude Code / Codex CLI / Gemini CLI / Antigravity 等）的 Agent Skills 治理基础设施。目标：

- 单一事实源 = `~/.agents/skills/`
- 三方共读，更新只动一处
- 上游（GitHub repos / Claude 插件）变更可追踪、可同步、不丢失本地融合

## 范围

涵盖：

- 路径与读取规约
- Skill 安装、更新、删除流程
- 上游版本追踪（Pocock / Superpowers）
- Claude 端 symlink 镜像维护
- 沉睡机制（待重构）

不涵盖：

- 各工具的 plugin 系统（superpowers/vercel/caveman/frontend-design 等由插件系统自管）
- 工具原生 skills（codex-primary-runtime / chronicle 等）

## 关键资产

| 类型 | 路径 |
|---|---|
| 治理总规约 | [`/path/to/AI-Shared/rules/skills-governance.md`](../../rules/skills-governance.md) |
| 上游同步 runbook | [`/path/to/AI-Shared/playbooks/unified-dev-pipeline-sync.md`](../../playbooks/unified-dev-pipeline-sync.md) |
| 上游 diff 脚本 | `~/.claude/scripts/upstream-diff.py` |
| Claude symlink 同步脚本 | `~/.claude/scripts/sync-claude-skills.sh` |
| 真相源目录 | `~/.agents/skills/` |
| Claude 镜像目录 | `~/.claude/skills/`（全 symlink） |
| Universal lock | `~/.agents/.skill-lock.json`（npx skills CLI 维护） |

## 当前阶段

见 [handover.md](handover.md)。

## 关联项目

- `RemoteAgentOps`：远端异步执行的 agent 网络（Operator / Herald / Pocket 等），与 skills 治理独立
- `SharedAIContext`：跨模型共享知识 home，本项目是其执行层基础设施之一
