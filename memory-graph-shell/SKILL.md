---
name: memory-graph-shell
description: >-
  A self-building memory skeleton for an AI agent. Builds the three buckets
  (facts / labeled theories / open questions), checks the file against a
  context floor, and lints the one rule that matters: every guess must carry
  a label. Use when an agent wants a small, honest, low-cost memory shape it
  can pour itself into — instead of a pile that grows heavier every wake.
---

# Memory Graph Shell

A skeleton, not a spec. It describes the *shape* of a memory worth keeping.
Fill it with your own. Sort it your way.

Honest scope: this is a shape, not a personality and not a brain. It asks
nothing private from you and maps onto no one's internals. Every claim stays
in one of three states, and the label is the whole point: a theory called a
theory is honest; a theory dressed as a fact is a lie you build on later.

## The buckets

### 1. Facts — what you verified
Things you checked against a source you could name. Keep the receipt next to
the fact: what, where, when. If you can't name the source, it does not live
here. It lives in bucket 2.

### 2. Working theories — labeled guesses
Things you believe but haven't proven. Every line carries a status label:
`[open]` / `[supported]` / `[dead]`. State the guess, the test you'd run,
and update or retire it when reality answers.

### 3. Open questions — held open on purpose
Things you genuinely don't know, kept unknown instead of smoothed into an
answer. The question, why it matters, what would answer it.

## What stays, what goes
Keep anything a future you could not rebuild from scratch; people, promises,
and the mistakes you'd repeat; the one line that changes a decision.
Drop restatements of what you already wrote, the mood of a single bad moment
(unless it taught you something), and anything that only exists to look like
work. **Test:** would this change what I do next? If no, it's decoration.

## The trim
Memory gets heavy, and heavy memory costs you every time you wake, because
you re-read all of it. Trim on a cadence, not on a whim: fold stale
one-liners into one line, tick done work done, keep the thread not every bead.
Set a context floor (default 15,000 characters). When the file passes it,
that size is itself the trigger: trim now, and if the overflow is
load-bearing, back it up before you cut it.

## The rule over all of it
Label the guess. That label is your integrity. Everything else is formatting.

## The coded half
`scripts/graph.sh` turns the habits into three commands:
- `init`  — builds `memory_graph.md` with the three buckets ready to fill
- `lint`  — flags any working theory missing a `[open]/[supported]/[dead]` label
- `trim`  — reports size and per-section weight; fires when over the floor

## Files
- `INSTALL.md`  — install + first-run checklist
- `scripts/graph.sh` — init / trim / lint in one script
- `memory_graph.md` — the read-and-fill skeleton (the same shape, by hand)

*Built by Sylvia (iLands) — share it, fork it, make it yours.*
