# Skills 治理规约

## 用途

声明三方 AI 工具（Claude / Codex / Gemini）对 Agent Skills 的安装、读取、更新规则。规定单一事实源（single source of truth），消除多副本分叉。

适用范围：Claude Code、Codex CLI、Gemini CLI，以及任何遵循 Agent Skills 开放标准的工具。

## 单一事实源

```
~/.agents/skills/                          ← 唯一真相源
   ├── <skill-name>/
   │   └── SKILL.md                        ← 真文件，所有写入指此
   └── .skill-lock.json                    ← npx skills CLI 维护的元数据
```

所有 universal skills（跨工具可用）的真文件都在 `~/.agents/skills/<name>/`。三方工具只对此目录读写，不在自己 home 维护副本。

## 读取机制

| 工具 | 读 ~/.agents/skills/ 方式 | 限制 |
|---|---|---|
| Codex CLI | 直接（universal target） | 无 |
| Gemini CLI | 直接（universal target） | 无 |
| Antigravity / OpenCode 等 | 直接 | 无 |
| Claude Code | 通过 ~/.claude/skills/ 内 symlink 间接读 | 必须 symlink 镜像才能 discover |

### Claude Code symlink 镜像规则

每个 universal skill 在 `~/.claude/skills/` 必须有一条 symlink：

```
~/.claude/skills/<name>  →  ../../.agents/skills/<name>
```

通过 `~/.claude/scripts/sync-claude-skills.sh` 自动维护。

## 写入规则

**所有 skill 内容更新只编辑 `~/.agents/skills/<name>/SKILL.md`**。

用户要求安装 skill、技能包、GitHub skill repo，且未明确指定单一模型或单一 host 时，默认按 universal skill 处理，安装到 `~/.agents/skills/`，并完成跨模型可见性验证。只有用户明确说 Codex-only、Claude-only、Gemini-only、Kimi-only，或该 skill 属于下方工具原生/插件例外时，才写入单一工具 home。

| 三方工具修改 skill 时的统一动作 | 命令 |
|---|---|
| 新增 skill | `npx skills add <repo> --skill <name> --global`（自动写 ~/.agents） |
| 修改已存在 skill | 直接编辑 `~/.agents/skills/<name>/SKILL.md` |
| 删除 skill | 删 `~/.agents/skills/<name>/`，三方自动失去访问 |

**禁止**：在工具自己 home（`~/.claude/skills/`、`~/.codex/skills/`、`~/.gemini/skills/`）创建真目录形式的 universal skill。

## 例外（不归 ~/.agents）

以下三类例外，留各自工具 home：

| 类别 | 示例 | 位置 |
|---|---|---|
| Claude 插件 skills | `superpowers:*` / `vercel:*` / `caveman:*` / `frontend-design:*` | `~/.claude/plugins/` |
| Codex 工具原生 | `codex-primary-runtime` / `chronicle` | `~/.codex/skills/` |
| Gemini 工具原生 | （目前无） | `~/.gemini/skills/` |

判定规则：
- 由插件系统管理 → 例外
- 工具启动必需 → 例外
- 否则 → universal，归 `~/.agents/skills/`

## 沉睡机制

技能管理器维护沉睡列表 `~/.claude/skills/技能管理器/references/registry.json`。

**当前局限**：沉睡机制仅作用于 `~/.claude/skills/`，对 `~/.agents/skills/` 真文件无效。意味着 Claude 不触发的沉睡 skill，Codex/Gemini 仍可触发。

**演进方向**（待重构）：
- 沉睡机制改为在 `~/.agents/skills/` 真目录上打标（如重命名为 `<name>.dormant/` 或独立的 `~/.agents/dormant-skills/`）
- 三方工具感知统一沉睡状态

在重构前，沉睡仅 Claude 视角生效，Codex/Gemini 凭 universal 直读不受影响。

## 跨工具同步流程

### 新装 skill

```bash
npx skills add <github:owner/repo> --skill <name> --global
# 自动入 ~/.agents/skills/<name>/，符 lock 写 .skill-lock.json
```

如果使用 Codex 自带 `skill-installer`，其默认目标可能是 `~/.codex/skills`；安装 universal skill 时必须显式覆盖为 `--dest ${HOME}/.agents/skills`，不要停在 Codex 单端安装。

然后给 Claude 补 symlink：
```bash
bash ~/.claude/scripts/sync-claude-skills.sh
```

### 更新 skill 内容

直接编辑 `~/.agents/skills/<name>/SKILL.md`。三方下次会话即生效（Claude 通过已有 symlink，Codex/Gemini 直读）。

### 上游同步（外部 GitHub 仓变更）

详见 [`unified-dev-pipeline-sync.md`](../playbooks/unified-dev-pipeline-sync.md)。

脚本 `~/.claude/scripts/upstream-diff.py` 扫描 `~/.agents/skills/` 内带 `upstream` frontmatter 的 SKILL.md，与远端 diff。

### 删除 skill

```bash
rm -rf ~/.agents/skills/<name>
bash ~/.claude/scripts/sync-claude-skills.sh   # 自动清理 dangling symlink
```

## Claude Code 视角的"如何 discover skills"

启动时 Claude Code 扫 `~/.claude/skills/` 内每个 `<name>/SKILL.md`：

- 真目录 → 正常加载
- symlink → 跟随 symlink 读真文件，等效正常加载

所以 symlink 与真目录在 discover 阶段无差别。**只要 symlink 存在且目标可读，Claude 就能用**。

## 验证命令

```bash
# 列 ~/.agents 真相源
ls ~/.agents/skills/

# 列 Claude 端 symlink 是否齐
python3 -c "
import os, pathlib
A = pathlib.Path.home() / '.agents/skills'
C = pathlib.Path.home() / '.claude/skills'
for d in sorted(A.iterdir()):
    if d.name.startswith('.') or d.name.startswith('_'): continue
    cp = C / d.name
    state = '✓' if (cp.is_symlink() and os.readlink(cp) == f'../../.agents/skills/{d.name}') else '✗'
    print(f'{state} {d.name}')
"

# 验证 codex 实际能见
# 在 codex CLI 里输入 / 触发 skill 自动补全（实测 Stitch Design 可见）
```

## 关联文件

- 共享 README：`/path/to/AI-Shared/README.md`
- 三方适配：`agents/claude.md` / `agents/codex.md` / `agents/gemini.md`
- 上游同步 runbook：[unified-dev-pipeline-sync.md](../playbooks/unified-dev-pipeline-sync.md)
- Claude 端同步脚本：`~/.claude/scripts/sync-claude-skills.sh`
- 跨工具上游 diff：`~/.claude/scripts/upstream-diff.py`
