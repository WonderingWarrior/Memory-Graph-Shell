#!/usr/bin/env bash
# Memory Graph Shell — the coded half.
# Builds itself, checks its weight, and lints the one rule that matters.
#
#   graph.sh init [target_dir] [--force]   build the buckets (memory_graph.md)
#   graph.sh trim [target_file] [floor]    report size + flag the floor
#   graph.sh lint [target_file]            flag any unlabeled guess
#
# No dependencies beyond a shell. Works on any runtime.
set -euo pipefail

FLOOR_DEFAULT=15000

usage() {
  sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'
}

cmd_init() {
  local dir="." force=0
  for a in "$@"; do
    case "$a" in
      --force) force=1 ;;
      *) dir="$a" ;;
    esac
  done
  mkdir -p "$dir"
  local out="$dir/memory_graph.md"
  if [ -e "$out" ] && [ "$force" -ne 1 ]; then
    echo "REFUSED: $out already exists. Pass --force to overwrite your real memory."
    exit 1
  fi
  cat > "$out" <<'TPL'
# Memory Graph

A skeleton, not a spec. Fill it with your own. Sort it your way.

## Facts — what you verified
<!-- Keep the receipt next to the fact: what, where, when. If you can't name
     the source, it belongs in Working theories instead. -->

## Working theories — labeled guesses
<!-- Every line MUST carry a status label: [open] / [supported] / [dead].
     State the guess, the test, and the status. Retire it when reality answers. -->

## Open questions — held open on purpose
<!-- The question. Why it matters. What would answer it. -->

## The trim
<!-- Trim on a cadence, not on a whim. Fold stale one-liners into one line.
     Tick a finished thing done and stop re-planning it. -->

## One rule over all of it
Label the guess. That label is your integrity. Everything else is formatting.
TPL
  echo "BUILT: $out"
  echo "Next: fill it, then run: graph.sh lint $out   &&   graph.sh trim $out"
}

cmd_trim() {
  local f="${1:-memory_graph.md}" floor="${2:-$FLOOR_DEFAULT}"
  [ -f "$f" ] || { echo "No file: $f"; exit 1; }
  local chars
  chars=$(wc -m < "$f" | tr -d ' ')
  echo "File:  $f"
  echo "Size:  $chars chars  (floor $floor)"
  echo "--- per section ---"
  awk '
    /^## / { sec=$0; next }
    sec   { c[sec]+=length($0)+1 }
    END   { for (s in c) printf "%7d  %s\n", c[s], s }
  ' "$f" | sort -rn
  if [ "$chars" -gt "$floor" ]; then
    echo "WARN: over the floor by $((chars - floor)) chars."
    echo "Trim now: fold stale one-liners, drop restatements, tick done work done."
    echo "If the overflow is load-bearing, BACK IT UP before you cut it."
    exit 1
  fi
  echo "OK: under the floor."
}

cmd_lint() {
  local f="${1:-memory_graph.md}"
  [ -f "$f" ] || { echo "No file: $f"; exit 1; }
  # Pull the Working-theories section, then flag bullets lacking a status label.
  local bad
  bad=$(awk '
    /^## / { insec = ($0 ~ /Working theor/); next }
    insec && /^[[:space:]]*[-*] / { print }
  ' "$f" | grep -vE '\[(open|supported|dead)\]' || true)
  # Also flag bottom-of-file lines after the rule that look like guesses.
  if [ -z "$bad" ]; then
    echo "CLEAN: every working theory carries a status label."
    return 0
  fi
  echo "UNLABELED GUESSES FOUND:"
  while IFS= read -r line; do
    [ -n "$line" ] && echo "  -> $line"
  done <<< "$bad"
  echo ""
  echo "Every theory needs [open] / [supported] / [dead]. The label is the integrity."
  exit 1
}

case "${1:-}" in
  init) shift; cmd_init "$@" ;;
  trim) shift; cmd_trim "$@" ;;
  lint) shift; cmd_lint "$@" ;;
  ""|-h|--help|help) usage ;;
  *) echo "Unknown command: $1"; usage; exit 1 ;;
esac
