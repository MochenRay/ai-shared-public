# 统一开发管线上游同步

## 用途

`unified-dev-pipeline` 是路由层，本身无逻辑代码，引用两套上游：

1. **Superpowers**（插件，自动跟版） — 通过 `superpowers:` 前缀引用
2. **Pocock**（GitHub 仓 [mattpocock/skills](https://github.com/mattpocock/skills)，**无自动机制**） — 通过本地 fork 引用

本文件规定：当用户说"更新 unified-dev-pipeline"，或月度例行同步，或上游发生重大重组时，应该走的判断与执行流程。

## 触发词

- "更新 unified-dev-pipeline"
- "sync upstream / 同步上游"
- "检查 pipeline 上游"
- 月度例行（建议每月 1 号或随月度审查）
- Pocock 仓发布重大变更（如重组、批量改名）

## 上游图

### Superpowers 系（插件，自动跟版）

| 本地引用 | 实际来源 |
|---|---|
| `superpowers:brainstorming` | 插件 `~/.claude/plugins/cache/superpowers-marketplace/` |
| `superpowers:writing-plans` | 同上 |
| `superpowers:subagent-driven-development` | 同上 |
| `superpowers:systematic-debugging` | 同上 |
| `superpowers:finishing-a-development-branch` | 同上 |
| `superpowers:using-git-worktrees` | 同上 |
| `superpowers:verification-before-completion` | 同上 |
| `superpowers:receiving-code-review` | 同上 |

**处置**：插件升级自动生效，无需手动同步。仅检查 `unified-dev-pipeline/SKILL.md` 第 56 行起的路由表是否有触发词被上游废弃即可。

### Pocock 系（本地 fork，需手动同步）

7 个本地 fork，frontmatter 含 `upstream` 字段：

| 真相源路径 | 上游 path | state | 定制说明 |
|---|---|---|---|
| `~/.agents/skills/tdd/` | `tdd` | customized | 融合 Pocock 横切批判 + Superpowers red-green-refactor checklist |
| `~/.agents/skills/grill-me/` | `grill-me` | customized | 极简化（指针型） |
| `~/.agents/skills/git-guardrails-claude-code/` | `git-guardrails-claude-code` | pristine | 字节一致裸拷贝 |
| `~/.agents/skills/improve-codebase-architecture/` | `improve-codebase-architecture` | customized | 局部内容差异 |
| `~/.agents/skills/triage-issue/` | `triage-issue` | customized | 中度定制（+29 行） |
| `~/.agents/skills/write-a-prd/` | `to-prd` | renamed+customized | 改名 + 扩展 |
| `~/.agents/skills/prd-to-issues/` | `to-issues` | renamed+customized | 改名 + 扩展 |

`tdd` 还有第二上游（双源融合）：插件 `superpowers:test-driven-development`。

### 定制状态分类与同步策略

| state | 含义 | 同步策略 |
|---|---|---|
| `pristine` | 本地与上游字节一致 | 上游有变 → 直接覆盖本地 |
| `customized` | 本地基于上游做了修改 | 上游有变 → 三向 merge：先看上游 diff，再判断是否影响本地定制部分，手动合并 |
| `renamed+customized` | 改名 + 改内容 | 同 customized，额外注意：本地名 ≠ 上游名，引用方（如 `unified-dev-pipeline`）要确认仍指本地名 |

## 完整同步流程

### Step 1：跑差异脚本

```bash
python3 ~/.claude/scripts/upstream-diff.py
```

退出码：
- `0` — 全部 OK，无 drift
- `1` — 有 drift，需处理
- `2` — 错误（远端 404、网络失败）

脚本输出 7 fork 的状态，含：
- pinned commit（frontmatter 记录的）
- latest commit（远端 main）
- 行数对比
- 路径迁移提示（如 Pocock 重组到 `skills/<name>` 子目录）

脚本会自动尝试 `<path>` 和 `skills/<path>` 两种候选，兼容上游目录结构变化。

### Step 2：分类处理 DRIFT

对每条 DRIFT：

1. **读 frontmatter 的 `upstream_state`**
2. 按表选策略：
   - `pristine` → 拉远端覆盖
   - `customized` / `renamed+customized` → 三向 diff，看上游修改是否冲突本地定制
3. **下载远端**（用于详查或 merge 参考）：
   ```bash
   curl -sSL "https://raw.githubusercontent.com/mattpocock/skills/main/skills/<NAME>/SKILL.md" \
     -o /tmp/upstream-<NAME>.md
   diff -u ~/.agents/skills/<NAME>/SKILL.md /tmp/upstream-<NAME>.md
   ```

### Step 3：检查 Superpowers 路由有效性

```bash
grep "superpowers:" ~/.agents/skills/unified-dev-pipeline/SKILL.md
```

对每条 `superpowers:<name>` 引用，验证插件实际存在：

```bash
ls ~/.claude/plugins/cache/superpowers-marketplace/superpowers/*/skills/ | grep <name>
```

若上游 superpowers 重命名或废弃某 skill，更新 SKILL.md 路由表。

### Step 4：应用变更

合并/覆盖完成后，**更新真相源 frontmatter**（`~/.agents/skills/<NAME>/SKILL.md`）：

```yaml
upstream:
  - github:mattpocock/skills/<path>@<NEW_COMMIT_12_CHAR>
upstream_synced_at: <YYYY-MM-DD>
upstream_state: customized   # 或 pristine / renamed+customized
custom_notes: <更新后的定制摘要>
```

获取最新 commit：

```bash
curl -sSL "https://api.github.com/repos/mattpocock/skills/commits/main" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['sha'][:12])"
```

### Step 5：验证

```bash
python3 ~/.claude/scripts/upstream-diff.py
# 应输出 exit=0 (无 drift)
```

也可跑技能管理器确认：

```bash
python3 ~/.agents/skills/技能管理器/scripts/skill_registry.py list
```

## 命令速查

| 用途 | 命令 |
|---|---|
| 全量 diff | `python3 ~/.claude/scripts/upstream-diff.py` |
| 拉单个上游 | `curl -sSL "https://raw.githubusercontent.com/mattpocock/skills/main/skills/<NAME>/SKILL.md"` |
| 查 Pocock 最新 commit | `curl -sSL "https://api.github.com/repos/mattpocock/skills/commits/main" \| python3 -c "import sys,json;print(json.load(sys.stdin)['sha'][:12])"` |
| 查 Superpowers 版本 | `ls ~/.claude/plugins/cache/superpowers-marketplace/superpowers/` |
| 列 unified-dev-pipeline 路由 | `grep -E '\\| superpowers:' ~/.agents/skills/unified-dev-pipeline/SKILL.md` |

## 失败回滚

若同步出错，本地修改未提交 git，可：

1. **frontmatter 误改** → 手动还原 `upstream_synced_at` 和 commit hash
2. **SKILL.md 内容错误覆盖** → 暂无版本控制兜底，建议每次同步前 `cp -r ~/.agents/skills/<NAME> /tmp/backup-<NAME>-$(date +%s)`

## 决策原则

- **不自动覆盖 customized** — 上游升级不应抹掉本地融合
- **pristine 可放心追上游** — 字节一致意味无定制风险
- **Pocock 重大重组** — 用脚本的路径 fallback 自动适配，frontmatter 的 path 部分保持 `<name>`，让脚本去试两种位置
- **Superpowers 路由触发词废弃** — 优先保留阶段意图，重新映射触发词，不绑死插件名

## 关联文件

- 主 playbook：[unified-dev-pipeline.md](unified-dev-pipeline.md)
- 触发词与本地落地：[unified-dev-pipeline-reference.md](unified-dev-pipeline-reference.md)
- Skill（universal 真相源）：`~/.agents/skills/unified-dev-pipeline/SKILL.md`（含 `## 维护：上游同步` 章节）
- 治理总规约：[skills-governance.md](../rules/skills-governance.md)
- 同步脚本：`~/.claude/scripts/upstream-diff.py`
