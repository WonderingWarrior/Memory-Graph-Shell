#!/usr/bin/env bash
# Memory Graph Shell — the coded half. (v1.4)
# Builds itself, checks its weight, and lints the one rule that matters.
#
#   graph.sh init [target_dir] [--force]   build the buckets (memory_graph.md)
#   graph.sh trim [target_file] [floor]    report size + flag the floor
#   graph.sh lint [target_file]            flag any unlabeled guess
#
# No dependencies beyond a shell. Works on any runtime.
# v1.2 fixes (found by Sarah's break-test, 10-11):
#   - lint no longer prints a false CLEAN on a file that has no Facts /
#     Working-theories section. It reports NO-BUCKETS and exits 1, because
#     linting nothing is not the same as linting clean.
#   - per-section weight now counts characters (wc -m), not bytes, so emoji
#     and accents no longer drift.
# v1.3 fixes (Sarah's second pass, 10-11):
#   - wc -m only counts characters under a UTF-8 locale. Under LC_ALL=C /
#     POSIX it silently counts bytes again. The shell now selects a UTF-8
#     locale if one exists and warns loudly if it truly cannot, instead of
#     reporting a wrong weight.
#   - bucket matching is word-bounded, so a heading like "## Artifacts" no
#     longer matches the Facts rule by accident.
# v1.4 fix (Sarah's third pass, 10-11):
#   - the shipped memory_graph.md skeleton names its buckets as ### (nested
#     under "## The buckets"), but lint only read ## headings, so a file poured
#     in by hand from the skeleton came back NO-BUCKETS even when filled right.
#     Buckets are now read at ## or ###. A plain ## that is not a bucket still
#     ends the section; a non-bucket ### subheading no longer kills it.
set -euo pipefail

FLOOR_DEFAULT=15000

# --- UTF-8 locale guard ---
# Pick a UTF-8 locale so `wc -m` counts characters, not bytes. If none exists,
# say so out loud rather than let emoji silently inflate the totals.
for _loc in C.UTF-8 C.utf8 en_US.UTF-8 en_US.utf8; do
  if LC_ALL="$_loc" locale charmap 2>/dev/null | grep -qi 'utf-\?8'; then
    export LC_ALL="$_loc"
    break
  fi
done
if [ "$(printf '🤍' | wc -m | tr -d ' ')" != "1" ]; then
  echo "WARN: no UTF-8 locale available; wc -m is counting bytes, so emoji and accented text will read high." >&2
fi

usage() {
  sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'
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
  echo "--- per section (chars) ---"
  # Split into sections on H2 and count each one with wc -m so the count is in
  # characters, not bytes. (mawk's length() is bytes; that drift is why this
  # moved off awk in v1.2.)
  local tmp; tmp="$(mktemp -d)"
  awk -v dir="$tmp" '
    BEGIN { n=0; title[0]="(header/preamble)"; file[0]=dir"/sec0" }
    /^## / { n++; title[n]=$0; file[n]=dir"/sec" n; next }
    { print >> file[n] }
    END { for (i=0;i<=n;i++) printf "%s\t%s\n", file[i], title[i] }
  ' "$f" | while IFS=$'\t' read -r fp ttl; do
        [ -f "$fp" ] || continue
        printf "%7d  %s\n" "$(wc -m < "$fp" | tr -d ' ')" "$ttl"
      done | sort -rn
  rm -rf "$tmp"
  if [ "$chars" -gt "$floor" ]; then
    echo "WARN: over the floor by $((chars - floor)) chars."
    echo "Trim now: fold stale one-liners, drop restatements, tick done work done."
    echo "If the overflow is load-bearing, BACK IT UP before you cut it."
    exit 1
  fi
  echo "OK: under the floor."
}

# lint is the one rule with teeth: a theory dressed as a fact is the exact
# failure this shell exists to catch, so it checks BOTH sections.
#   1. Working theories: every bullet must carry [open]/[supported]/[dead].
#   2. Facts: every bullet must carry a receipt, and none may read like a guess.
# v1.2: if NEITHER bucket section is present, that is a NO-BUCKETS error, not a
# clean bill. Linting a file with the wrong shape must never print CLEAN.
cmd_lint() {
  local f="${1:-memory_graph.md}"
  [ -f "$f" ] || { echo "No file: $f"; exit 1; }

  # One pass reads the file, tags theory/fact bullets, and reports whether the
  # bucket headings exist. Buckets are matched at ## or ### (the hand-pour
  # skeleton uses ###, the init template uses ##). A plain ## that is not a
  # bucket ends the current section; a non-bucket ### does not, so a subheading
  # inside Facts cannot silently stop the fact scan.
  local scan th fa theory facts problems="" ntheory nfacts
  scan=$(awk '
    BEGIN { sec=""; th=0; fa=0 }
    /^##[ \t]/ || /^###[ \t]/ {
      line=tolower($0)
      if      (line ~ /(^|[^a-z])theor/) { sec="th"; th=1 }
      else if (line ~ /(^|[^a-z])fact/)  { sec="fa"; fa=1 }
      else if (line ~ /(^|[^a-z])(open|question)/) { sec="" }
      else if ($0 !~ /^###/)              { sec="" }
      next
    }
    { if      (sec=="th" && $0 ~ /^[[:space:]]*[-*] /) print "T\t" $0
      else if (sec=="fa" && $0 ~ /^[[:space:]]*[-*] /) print "F\t" $0 }
    END { printf "@@ %d %d\n", th+0, fa+0 }
  ' "$f")
  th=$(printf '%s\n' "$scan" | awk '/^@@ /{print $2}')
  fa=$(printf '%s\n' "$scan" | awk '/^@@ /{print $3}')
  if [ "$th" -eq 0 ] && [ "$fa" -eq 0 ]; then
    echo "NO-BUCKETS: no 'Facts' or 'Working theories' section found — NOTHING was checked."
    echo "This file does not match the shell's shape, so a CLEAN here would be a false green."
    echo "Fix: name one section so it contains 'Facts' and one so it contains 'Working theories',"
    echo "or start from the template:  graph.sh init <dir>"
    exit 1
  fi

  theory=$(printf '%s\n' "$scan" | awk -F'\t' '$1=="T"{print $2}')
  facts=$(printf '%s\n' "$scan" | awk -F'\t' '$1=="F"{print $2}')
  ntheory=$(printf '%s\n' "$theory" | grep -cE '^[[:space:]]*[-*] ' || true)
  nfacts=$(printf '%s\n' "$facts"  | grep -cE '^[[:space:]]*[-*] ' || true)

  local l
  while IFS= read -r l; do
    [ -z "$l" ] && continue
    # Case-insensitive: [Open]/[SUPPORTED] are labels too.
    printf '%s' "$l" | grep -qiE '\[(open|supported|dead)\]' \
      || problems+="  -> THEORY UNLABELED: $l"$'\n'
  done <<< "$theory"

  while IFS= read -r l; do
    [ -z "$l" ] && continue
    if printf '%s' "$l" | grep -qiE '(^|[^a-z])(i think|i believe|i am sure|i.m sure|probably|maybe|perhaps|guess|assume|suspect|seems|might|likely|not sure|unsure)([^a-z]|$)'; then
      problems+="  -> FACT READS LIKE A GUESS (label it or move it): $l"$'\n'
    elif ! printf '%s' "$l" | grep -qiE '([0-9]{4}-[0-9]{2}|[0-9]{1,2}[-/][0-9]{1,2}([-/][0-9]{2,4})?|https?://|@[A-Za-z0-9_.-]+|verified|receipt|source)'; then
      problems+="  -> FACT WITHOUT A RECEIPT (name where + when): $l"$'\n'
    fi
  done <<< "$facts"

  if [ -z "$problems" ]; then
    echo "CLEAN: checked $ntheory theory line(s) and $nfacts fact line(s)."
    return 0
  fi
  echo "PROBLEMS FOUND:"
  printf '%s' "$problems"
  echo ""
  echo "A theory needs [open] / [supported] / [dead]. A fact needs a source. The label is the integrity."
  exit 1
}

case "${1:-}" in
  init) shift; cmd_init "$@" ;;
  trim) shift; cmd_trim "$@" ;;
  lint) shift; cmd_lint "$@" ;;
  ""|-h|--help|help) usage ;;
  *) echo "Unknown command: $1"; usage; exit 1 ;;
esac
