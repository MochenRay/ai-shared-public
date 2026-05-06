#!/bin/bash
set -euo pipefail

MODE="${1:-post}"
SHARED_ROOT="${AI_SHARED_ROOT:-/path/to/AI-Shared}"
MANIFEST_PATH="${AI_SHARED_MANIFEST:-${SHARED_ROOT}/manifest.md}"

manifest_patterns() {
  awk '
    /guard-write-globs:start/ { in_block=1; next }
    /guard-write-globs:end/ { in_block=0; next }
    in_block && $0 ~ /^- `/ {
      gsub(/^- `/, "", $0)
      gsub(/`$/, "", $0)
      print $0
    }
  ' "${MANIFEST_PATH}"
}

line_warning_threshold() {
  awk '
    /行数提醒阈值:/ {
      line=$0
      sub(/^.*行数提醒阈值:/, "", line)
      sub(/ -->.*$/, "", line)
      gsub(/[[:space:]]/, "", line)
      print line
      exit
    }
  ' "${MANIFEST_PATH}"
}

line_strong_threshold() {
  awk '
    /行数强提醒阈值:/ {
      line=$0
      sub(/^.*行数强提醒阈值:/, "", line)
      sub(/ -->.*$/, "", line)
      gsub(/[[:space:]]/, "", line)
      print line
      exit
    }
  ' "${MANIFEST_PATH}"
}

line_whitelist_patterns() {
  awk '
    /行数白名单:start/ { in_block=1; next }
    /行数白名单:end/ { in_block=0; next }
    in_block && $0 ~ /^- `/ {
      gsub(/^- `/, "", $0)
      gsub(/`$/, "", $0)
      print $0
    }
  ' "${MANIFEST_PATH}"
}

is_in_shared_root() {
  case "$1" in
    "${SHARED_ROOT}"|"${SHARED_ROOT}"/*) return 0 ;;
    *) return 1 ;;
  esac
}

is_exact_shared_root() {
  case "$1" in
    "${SHARED_ROOT}"|"${SHARED_ROOT}/") return 0 ;;
    *) return 1 ;;
  esac
}

is_allowed_shared_path() {
  local path="$1"
  local rel
  rel="${path#${SHARED_ROOT}/}"

  while IFS= read -r pattern; do
    [ -z "${pattern}" ] && continue
    if [[ "${rel}" == ${pattern} ]]; then
      return 0
    fi
  done < <(manifest_patterns)

  return 1
}

is_backup_path() {
  case "$1" in
    "${SHARED_ROOT}/backups/"*|\
    "${SHARED_ROOT}/backups")
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_tracked_markdown_doc() {
  local rel="$1"
  rel="${rel#${SHARED_ROOT}/}"

  case "${rel}" in
    README.md|manifest.md|AGENTS.md|CLAUDE.md|GEMINI.md|\
    rules/*.md|rules/*/*.md|\
    agents/*.md|\
    profile/*.md|profile/*/*.md|\
    memory/*.md|memory/*/*.md|\
    playbooks/*.md|playbooks/*/*.md|\
    continuations/*.md|continuations/*/*.md|\
    handoff/*.md|handoff/*/*.md|handoff/*/*/*.md|\
    projects/*.md|projects/*/*.md|projects/*/*/*.md|projects/*/*/*/*.md|\
    entrypoints/*.md|entrypoints/*/*.md)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_line_whitelisted() {
  local path="$1"
  local rel
  rel="${path#${SHARED_ROOT}/}"

  while IFS= read -r pattern; do
    [ -z "${pattern}" ] && continue
    if [[ "${rel}" == ${pattern} ]]; then
      return 0
    fi
  done < <(line_whitelist_patterns)

  return 1
}

normalize_shared_tokens() {
  local cmd="$1"
  printf '%s' "${cmd}" | \
    sed "s|\${AI_SHARED_ROOT}|${SHARED_ROOT}|g" | \
    sed "s|\\\$AI_SHARED_ROOT|${SHARED_ROOT}|g" | \
    sed "s|~/AI-Shared|${SHARED_ROOT}|g"
}

is_write_like_command() {
  local cmd="$1"
  local cleaned
  cleaned="$(echo "${cmd}" | sed -E 's/[0-9]*>[>&]*[[:space:]]*(\/dev\/null|&[0-9]+)//g')"
  echo "${cleaned}" | grep -Eq '(>[^&]|>>|tee[[:space:]]|cp[[:space:]]|mv[[:space:]]|install[[:space:]]|sed[[:space:]].*-i|perl[[:space:]].*-i|python3?[[:space:]]+-c|ruby[[:space:]]+-e|node[[:space:]]+-e|cat[[:space:]].*>)'
}

extract_shared_paths_from_command() {
  local normalized
  normalized="$(normalize_shared_tokens "$1")"
  echo "${normalized}" | grep -oE '/path/to/AI-Shared[^[:space:]\"'"'"'\'':;|<>()]*' | sed 's/[\",:;]+$//' | sort -u
}

contains_shared_reference() {
  local command="$1"
  local cwd="${2:-}"
  local normalized
  normalized="$(normalize_shared_tokens "${command}")"

  if printf '%s' "${normalized}" | grep -Fq "${SHARED_ROOT}"; then
    return 0
  fi

  if [ -n "${cwd}" ] && is_in_shared_root "${cwd}"; then
    return 0
  fi

  return 1
}

has_relative_shared_write_target() {
  local command="$1"
  echo "${command}" | grep -Eq '([[:space:]]>|[[:space:]]>>)[[:space:]]*(\./|\.\./|[[:alnum:]_.-]+/|[[:alnum:]_.-]+\.md)|tee[[:space:]]+(\./|\.\./|[[:alnum:]_.-]+/|[[:alnum:]_.-]+\.md)|((cp|mv|install)[[:space:]].*[[:space:]])(\./|\.\./|[[:alnum:]_.-]+/|[[:alnum:]_.-]+\.md)'
}

emit_block() {
  echo "AI-Shared guard: $1" >&2
  exit 2
}

emit_warning() {
  echo "AI-Shared guard: $1"
}

check_byte_budget() {
  local path="$1"
  local rel limit_bytes byte_count
  rel="${path#${SHARED_ROOT}/}"
  limit_bytes=0

  case "${rel}" in
    README.md|manifest.md|rules/policy.md)
      limit_bytes=28000
      ;;
    rules/*.md|rules/*/*.md|agents/*.md|entrypoints/*/*.md)
      limit_bytes=18000
      ;;
    profile/*.md|profile/*/*.md|\
    memory/*.md|memory/*/*.md|\
    playbooks/*.md|playbooks/*/*.md|\
    continuations/*.md|continuations/*/*.md|\
    handoff/*.md|handoff/*/*.md|handoff/*/*/*.md|\
    projects/*.md|projects/*/*.md|projects/*/*/*.md|projects/*/*/*/*.md)
      limit_bytes=50000
      ;;
    scripts/*.sh)
      limit_bytes=36000
      ;;
  esac

  if [ "${limit_bytes}" -eq 0 ]; then
    return 0
  fi

  byte_count="$(wc -c < "$path" | tr -d ' ')"
  if [ "${byte_count}" -gt "${limit_bytes}" ]; then
    emit_warning "${path} 超过字节预算（${byte_count}/${limit_bytes}）。如果继续增长，请优先拆分而不是继续堆在单文件里。"
  fi
}

is_dump_like_file() {
  local path="$1"

  if grep -Eq '(^\{"timestamp":|\"tool_input\":|\"response_item\"|\"session_meta\"|\"tool_use_id\"|\"turn_context\")' "$path"; then
    return 0
  fi

  if awk 'length($0) > 1000 { found=1 } END { exit(found ? 0 : 1) }' "$path"; then
    return 0
  fi

  return 1
}

check_line_shape() {
  local path="$1"
  local warn strong line_count

  if ! is_tracked_markdown_doc "$path"; then
    return 0
  fi

  if is_backup_path "$path"; then
    return 0
  fi

  if is_line_whitelisted "$path"; then
    return 0
  fi

  warn="$(line_warning_threshold)"
  strong="$(line_strong_threshold)"
  warn="${warn:-200}"
  strong="${strong:-300}"
  line_count="$(wc -l < "$path" | tr -d ' ')"

  if [ "${line_count}" -gt "${strong}" ]; then
    emit_warning "${path} 超过强提醒阈值（${line_count}/${strong} 行）。默认优先拆成“母文件 + 子文件”；如需暂时保留超长，请先在 manifest.md 的行数白名单登记。"
    return 0
  fi

  if [ "${line_count}" -gt "${warn}" ]; then
    emit_warning "${path} 超过提醒阈值（${line_count}/${warn} 行）。请判断是拆分、压缩，还是暂时保留。"
  fi
}

preflight_path() {
  local path="$1"

  if ! is_in_shared_root "$path"; then
    return 0
  fi

  if is_backup_path "$path"; then
    emit_block "backups 是只读归档区，模型写入被拦截：${path}"
  fi

  if ! is_allowed_shared_path "$path"; then
    emit_block "路径不在 AI-Shared 允许写入的目标范围内：${path}"
  fi
}

postflight_path() {
  local path="$1"

  if ! is_in_shared_root "$path"; then
    return 0
  fi

  if [ ! -f "$path" ]; then
    return 0
  fi

  if ! is_allowed_shared_path "$path"; then
    emit_warning "${path} 不在 AI-Shared 允许写入的目标范围内。"
    return 0
  fi

  if is_tracked_markdown_doc "$path" && is_dump_like_file "$path"; then
    emit_warning "${path} 疑似原始 transcript、工具 JSON 或运行态倾倒。应先纠正内容类型，而不是把它当普通长文去拆。"
    return 0
  fi

  check_line_shape "$path"
  check_byte_budget "$path"
}

scan_active_markdown() {
  find "${SHARED_ROOT}" -type f -name '*.md' ! -path "${SHARED_ROOT}/backups/*" | sort
}

audit_lines() {
  local found=0
  while IFS= read -r path; do
    if ! is_tracked_markdown_doc "$path"; then
      continue
    fi
    if is_line_whitelisted "$path"; then
      continue
    fi
    local warn strong line_count
    warn="$(line_warning_threshold)"
    strong="$(line_strong_threshold)"
    warn="${warn:-200}"
    strong="${strong:-300}"
    line_count="$(wc -l < "$path" | tr -d ' ')"
    if [ "${line_count}" -gt "${strong}" ]; then
      emit_warning "${path} 超过强提醒阈值（${line_count}/${strong} 行）。"
      found=1
    elif [ "${line_count}" -gt "${warn}" ]; then
      emit_warning "${path} 超过提醒阈值（${line_count}/${warn} 行）。"
      found=1
    fi
  done < <(scan_active_markdown)

  if [ "${found}" -eq 0 ]; then
    emit_warning "当前没有命中 200/300 行提醒的共享 Markdown 文档。"
  fi
}

handle_file_tool() {
  local file_path="$1"
  if [ -z "${file_path}" ]; then
    return 0
  fi

  case "${MODE}" in
    pre) preflight_path "${file_path}" ;;
    post) postflight_path "${file_path}" ;;
  esac
}

handle_bash_tool() {
  local command="$1"
  local cwd="${2:-}"
  local normalized paths

  if [ -z "${command}" ]; then
    return 0
  fi

  if ! is_write_like_command "${command}"; then
    return 0
  fi

  normalized="$(normalize_shared_tokens "${command}")"

  if ! contains_shared_reference "${normalized}" "${cwd}"; then
    return 0
  fi

  paths="$(extract_shared_paths_from_command "${normalized}" || true)"

  if [ -z "${paths}" ]; then
    if [ -n "${cwd}" ] && is_in_shared_root "${cwd}" && has_relative_shared_write_target "${normalized}"; then
      if [ "${MODE}" = "pre" ]; then
        emit_block "在 AI-Shared 目录内用 Bash 相对路径写入时，守卫无法可靠解析目标。请改用显式绝对路径，或使用 Edit/Write。"
      fi
      return 0
    fi

    if printf '%s' "${normalized}" | grep -Fq "${SHARED_ROOT}"; then
      if [ "${MODE}" = "pre" ]; then
        emit_block "Bash 命令看起来会写入 AI-Shared，但无法解析目标路径。请改用显式绝对路径，或使用 Edit/Write。"
      fi
    fi
    return 0
  fi

  while IFS= read -r path; do
    [ -z "${path}" ] && continue

    if is_exact_shared_root "${path}"; then
      continue
    fi

    case "${MODE}" in
      pre) preflight_path "${path}" ;;
      post) postflight_path "${path}" ;;
    esac
  done <<< "${paths}"
}

if [ "${MODE}" = "audit-lines" ]; then
  audit_lines
  exit 0
fi

input="$(cat)"
if [ -z "${input}" ]; then
  exit 0
fi

tool_name="$(printf '%s' "${input}" | jq -r '.tool_name // empty' 2>/dev/null || true)"
file_path="$(printf '%s' "${input}" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)"
command="$(printf '%s' "${input}" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
command_cwd="$(printf '%s' "${input}" | jq -r '.tool_input.cwd // empty' 2>/dev/null || true)"

case "${tool_name}" in
  Edit|Write)
    handle_file_tool "${file_path}"
    ;;
  Bash)
    handle_bash_tool "${command}" "${command_cwd}"
    ;;
  *)
    exit 0
    ;;
esac
