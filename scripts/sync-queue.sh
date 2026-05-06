#!/bin/bash
set -euo pipefail

ACTION="${1:-audit}"
MODEL="${2:-unknown}"
SHARED_ROOT="${AI_SHARED_ROOT:-/path/to/AI-Shared}"
QUEUE_PATH="${SYNC_QUEUE_PATH:-${SHARED_ROOT}/handoff/sync-queue.md}"
TODAY="$(TZ=Asia/Shanghai date +%F 2>/dev/null || date +%F)"

PENDING_START='<!-- sync-queue:pending:start -->'
PENDING_END='<!-- sync-queue:pending:end -->'
SYNCED_START='<!-- sync-queue:synced:start -->'
SYNCED_END='<!-- sync-queue:synced:end -->'
DEFERRED_START='<!-- sync-queue:deferred:start -->'
DEFERRED_END='<!-- sync-queue:deferred:end -->'

ensure_queue_file() {
  mkdir -p "$(dirname "${QUEUE_PATH}")"
  if [ -f "${QUEUE_PATH}" ]; then
    return 0
  fi

  cat > "${QUEUE_PATH}" <<'MARKDOWN'
# 同步队列

> 用途：记录“本地长期文档发生变化，是否需要同步到 AI-Shared”的待判断事项。
> 用法：先登记短条目，再判断是否回写共享层正式文档。不要把正文写在这里。

## 待判断
<!-- sync-queue:pending:start -->
- 暂无。
<!-- sync-queue:pending:end -->

## 已同步
<!-- sync-queue:synced:start -->
- 暂无。
<!-- sync-queue:synced:end -->

## 已暂缓
<!-- sync-queue:deferred:start -->
- 暂无。
<!-- sync-queue:deferred:end -->
MARKDOWN
}

extract_block() {
  local start="$1"
  local end="$2"
  awk -v start="${start}" -v end="${end}" '
    $0 == start { in_block=1; next }
    $0 == end { in_block=0; next }
    in_block { print }
  ' "${QUEUE_PATH}"
}

replace_block() {
  local start="$1"
  local end="$2"
  local content="$3"
  local tmp content_tmp
  tmp="$(mktemp "${TMPDIR:-/tmp}/sq.XXXXXX")"
  content_tmp="$(mktemp "${TMPDIR:-/tmp}/sq-content.XXXXXX")"
  printf '%s\n' "${content}" > "${content_tmp}"
  awk -v start="${start}" -v end="${end}" -v content_file="${content_tmp}" '
    $0 == start {
      print
      while ((getline line < content_file) > 0) {
        print line
      }
      close(content_file)
      skip=1
      next
    }
    $0 == end {
      skip=0
      print
      next
    }
    !skip { print }
  ' "${QUEUE_PATH}" > "${tmp}"
  rm -f "${content_tmp}"
  mv "${tmp}" "${QUEUE_PATH}"
}

normalize_block_content() {
  local content="$1"
  if [ -z "${content}" ]; then
    printf '%s\n' "- 暂无。"
    return
  fi

  content="$(printf '%s\n' "${content}" | sed '/^- 暂无。$/d')"
  if [ -z "${content}" ]; then
    printf '%s\n' "- 暂无。"
  else
    printf '%s\n' "${content}"
  fi
}

is_local_sync_candidate() {
  local path="$1"

  case "${path}" in
    */MEMORY.md)
      return 1
      ;;
    ${HOME}/.claude/CLAUDE.md|\
    ${HOME}/.codex/AGENTS.md|\
    ${HOME}/.gemini/GEMINI.md|\
    ${HOME}/.claude/rules/*.md|\
    ${HOME}/.codex/rules/*.md|\
    ${HOME}/.gemini/rules/*.md|\
    ${HOME}/.claude/projects/*/memory/*.md|\
    ${HOME}/.codex/projects/*/memory/*.md|\
    ${HOME}/.gemini/memory/*.md|\
    ${HOME}/.gemini/projects/*/memory/*.md)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

derive_target() {
  local path="$1"
  local base
  base="$(basename "${path}")"

  case "${path}" in
    ${HOME}/.claude/CLAUDE.md)
      echo "entrypoints/homes/claude-CLAUDE.md"
      ;;
    ${HOME}/.codex/AGENTS.md)
      echo "entrypoints/homes/codex-AGENTS.md"
      ;;
    ${HOME}/.gemini/GEMINI.md)
      echo "entrypoints/homes/gemini-GEMINI.md"
      ;;
    ${HOME}/.claude/rules/*.md|${HOME}/.codex/rules/*.md|${HOME}/.gemini/rules/*.md)
      echo "rules/${base}"
      ;;
    *)
      echo "待判断"
      ;;
  esac
}

derive_summary() {
  local path="$1"

  case "${path}" in
    ${HOME}/.claude/CLAUDE.md|${HOME}/.codex/AGENTS.md|${HOME}/.gemini/GEMINI.md)
      echo "本地入口投影发生修改，需判断是否同步来源文件"
      ;;
    ${HOME}/.claude/rules/*.md|${HOME}/.codex/rules/*.md|${HOME}/.gemini/rules/*.md)
      echo "本地规则发生修改，需判断是否回写共享层正式规则"
      ;;
    *)
      echo "本地长期文档发生修改，需判断是否回写共享层"
      ;;
  esac
}

pending_contains_path() {
  local path="$1"
  extract_block "${PENDING_START}" "${PENDING_END}" | grep -Fq "| 本地=${path} |"
}

prepend_pending_entry() {
  local entry="$1"
  local current updated
  current="$(extract_block "${PENDING_START}" "${PENDING_END}" | sed '/^- 暂无。$/d')"
  if [ -n "${current}" ]; then
    updated="${entry}"$'\n'"${current}"
  else
    updated="${entry}"
  fi
  updated="$(normalize_block_content "${updated}")"
  replace_block "${PENDING_START}" "${PENDING_END}" "${updated}"
}

add_candidate() {
  local model="$1"
  local path="$2"
  local target="$3"
  local summary="$4"
  local entry

  if ! is_local_sync_candidate "${path}"; then
    return 0
  fi

  if pending_contains_path "${path}"; then
    return 0
  fi

  entry="- [ ] ${TODAY} | 来源=${model} | 本地=${path} | 同步目标=${target} | 摘要=${summary}"
  prepend_pending_entry "${entry}"
  echo "同步队列：已登记候选项 -> ${path}"
}

queue_from_hook() {
  local input tool_name file_path
  ensure_queue_file
  input="$(cat)"
  if [ -z "${input}" ]; then
    exit 0
  fi

  tool_name="$(printf '%s' "${input}" | jq -r '.tool_name // empty' 2>/dev/null || true)"
  file_path="$(printf '%s' "${input}" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)"

  case "${tool_name}" in
    Edit|Write)
      if [ -n "${file_path}" ]; then
        add_candidate "${MODEL}" "${file_path}" "$(derive_target "${file_path}")" "$(derive_summary "${file_path}")"
      fi
      ;;
    *)
      exit 0
      ;;
  esac
}

manual_add() {
  local model="${2:-unknown}"
  local path="${3:-}"
  local target="${4:-待判断}"
  local summary="${5:-本地长期文档发生修改，需判断是否回写共享层}"

  if [ -z "${path}" ]; then
    echo "用法：sync-queue.sh add <model> <local-path> [shared-target] [summary]" >&2
    exit 1
  fi

  ensure_queue_file
  add_candidate "${model}" "${path}" "${target}" "${summary}"
}

audit_queue() {
  ensure_queue_file

  local pending synced deferred
  pending="$(extract_block "${PENDING_START}" "${PENDING_END}" | grep -c '^- \[ \]' || true)"
  synced="$(extract_block "${SYNCED_START}" "${SYNCED_END}" | grep -c '^- ' || true)"
  deferred="$(extract_block "${DEFERRED_START}" "${DEFERRED_END}" | grep -c '^- ' || true)"

  if extract_block "${SYNCED_START}" "${SYNCED_END}" | grep -qx -- '- 暂无。'; then
    synced=0
  fi
  if extract_block "${DEFERRED_START}" "${DEFERRED_END}" | grep -qx -- '- 暂无。'; then
    deferred=0
  fi

  echo "同步队列概览"
  echo "待判断：${pending}"
  echo "已同步：${synced}"
  echo "已暂缓：${deferred}"

  if [ "${pending}" -gt 0 ]; then
    echo
    echo "待判断条目："
    extract_block "${PENDING_START}" "${PENDING_END}" | sed '/^- 暂无。$/d'
  fi
}

case "${ACTION}" in
  audit)
    audit_queue
    ;;
  queue-from-hook)
    queue_from_hook
    ;;
  add)
    manual_add "$@"
    ;;
  *)
    echo "用法：sync-queue.sh [audit|queue-from-hook <model>|add <model> <local-path> [shared-target] [summary]]" >&2
    exit 1
    ;;
esac
