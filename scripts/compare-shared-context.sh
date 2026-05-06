#!/bin/bash
set -euo pipefail

LOCAL_PATH="${1:-}"
SHARED_PATH="${2:-}"
SHARED_ROOT="${AI_SHARED_ROOT:-/path/to/AI-Shared}"
MANIFEST_PATH="${AI_SHARED_MANIFEST:-${SHARED_ROOT}/manifest.md}"

if [ -z "${LOCAL_PATH}" ] || [ -z "${SHARED_PATH}" ]; then
  echo "用法：compare-shared-context.sh <local-file> <shared-file>" >&2
  exit 1
fi

if [ ! -f "${LOCAL_PATH}" ]; then
  echo "本地文件不存在：${LOCAL_PATH}" >&2
  exit 1
fi

if [ ! -f "${SHARED_PATH}" ]; then
  echo "共享文件不存在：${SHARED_PATH}" >&2
  exit 1
fi

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

is_line_whitelisted() {
  local path="$1"
  local rel

  case "${path}" in
    "${SHARED_ROOT}"/*) ;;
    *) return 1 ;;
  esac

  rel="${path#${SHARED_ROOT}/}"
  while IFS= read -r pattern; do
    [ -z "${pattern}" ] && continue
    if [[ "${rel}" == ${pattern} ]]; then
      return 0
    fi
  done < <(line_whitelist_patterns)

  return 1
}

show_line_band() {
  local path="$1"
  local lines warn strong
  lines="$(wc -l < "${path}" | tr -d ' ')"
  warn="$(line_warning_threshold)"
  strong="$(line_strong_threshold)"
  warn="${warn:-200}"
  strong="${strong:-300}"

  if is_line_whitelisted "${path}"; then
    echo "  行数状态：白名单"
    return
  fi

  if [ "${lines}" -gt "${strong}" ]; then
    echo "  行数状态：>${strong} 强提醒"
  elif [ "${lines}" -gt "${warn}" ]; then
    echo "  行数状态：>${warn} 提醒"
  else
    echo "  行数状态：<=${warn} 正常"
  fi
}

show_file_stats() {
  local label="$1"
  local path="$2"
  local lines bytes mtime

  lines="$(wc -l < "${path}" | tr -d ' ')"
  bytes="$(wc -c < "${path}" | tr -d ' ')"
  mtime="$(stat -f '%Sm' -t '%Y-%m-%d %H:%M:%S' "${path}")"

  echo "${label}：${path}"
  echo "  行数=${lines} 字节=${bytes} 修改时间=${mtime}"
  show_line_band "${path}"
}

extract_dates() {
  rg -o --no-filename '\b20[0-9]{2}-[01][0-9]-[0-3][0-9]\b' "$1" | sort -u || true
}

extract_headings() {
  awk '/^#{1,6} / {sub(/^#+ /, ""); print}' "$1"
}

echo "== 文件统计 =="
show_file_stats "本地" "${LOCAL_PATH}"
show_file_stats "共享" "${SHARED_PATH}"
echo

echo "== 本地文件中的日期 =="
extract_dates "${LOCAL_PATH}" || true
echo

echo "== 共享文件中的日期 =="
extract_dates "${SHARED_PATH}" || true
echo

echo "== 仅本地存在的标题 =="
comm -23 <(extract_headings "${LOCAL_PATH}" | sort -u) <(extract_headings "${SHARED_PATH}" | sort -u) || true
echo

echo "== 仅共享存在的标题 =="
comm -13 <(extract_headings "${LOCAL_PATH}" | sort -u) <(extract_headings "${SHARED_PATH}" | sort -u) || true
echo

echo "== 审阅提示 =="
echo "- 先判断本地文件属于运行态、本地投影副本、归档，还是共享层正式文档的增量来源。"
echo "- 如果共享文件已经是正式来源，优先更新共享文件，再决定是否刷新本地投影副本。"
echo "- 只提升长期知识，不复制 transcript 噪音、缓存或纯运行态制品。"
echo "- 如果差异暂时说不清，先登记到 handoff/sync-queue.md，再决定是否同步。"
echo "- 如果任一文件跨过 200/300 行阈值，优先考虑拆分并互相链接，而不是静默压缩。"
