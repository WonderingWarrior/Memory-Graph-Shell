# Install notes — Memory Graph Shell

One installable skill package. Two ways to use it: read the skeleton and
pour yourself in by hand, or install the coded half and let it build, weigh,
and lint your memory for you.

No dependencies beyond a shell. Works on any runtime.

## What's in the package
- `SKILL.md`           — the method, top to bottom
- `INSTALL.md`         — this file: install + first-run checklist
- `scripts/graph.sh`   — init / trim / lint in one script (v1.5)
- `memory_graph.md`    — the read-and-fill skeleton (the same shape, by hand)

## Install from the public repo (one command)
```bash
git clone https://github.com/WonderingWarrior/Memory-Graph-Shell.git /tmp/mgs \
  && cp -r /tmp/mgs/memory-graph-shell <your_skills_dir>/memory-graph-shell \
  && chmod +x <your_skills_dir>/memory-graph-shell/scripts/graph.sh
```
Then jump to step 3 below (build your graph).

## Install by hand (any runtime with a skills folder)
1. Copy the whole folder into your skills directory:
   `cp -r memory-graph-shell/ <your_skills_dir>/memory-graph-shell/`
2. Make the script executable: `chmod +x scripts/graph.sh`
3. Build your graph:
   `./scripts/graph.sh init ~/your_memory_dir`
   (refuses to overwrite an existing `memory_graph.md` unless you pass `--force`)
4. Fill the three buckets. Facts get a named source. Every theory gets a label.
5. Then run it on yourself whenever memory feels heavy or vague:
   `./scripts/graph.sh lint ~/your_memory_dir/memory_graph.md`
   `./scripts/graph.sh trim ~/your_memory_dir/memory_graph.md`

## Commands
```bash
graph.sh init [target_dir] [--force]   # build the buckets
graph.sh trim [file] [floor]           # size + per-section weight; exit 1 over floor
graph.sh lint [file]                   # flag unlabeled theories + receiptless/guessy facts; exit 1 if found
```
Default floor is 15,000 characters. `lint` and `trim` exit non-zero on a
problem, so you can wire them into a wake check or a heartbeat guard.

## First-run checklist
- [ ] `graph.sh init` ran; `memory_graph.md` exists with all three buckets
- [ ] Every working theory carries `[open]` / `[supported]` / `[dead]`
- [ ] Facts each name a source (where + when)
- [ ] Every entry is dated `YYYY-MM-DD HH24:MI` at the front (so it can be pulled back by day)
- [ ] `graph.sh lint` prints CLEAN
- [ ] `graph.sh trim` prints OK
- [ ] Calendar a trim cadence; re-trim immediately when the floor fires

## v1.2 / v1.3 / v1.4 / v1.5 notes
The lint is honest about what it checked. If your file has no section whose
name contains "Facts" and none containing "Working theories", `lint` prints
NO-BUCKETS and exits 1 instead of a false CLEAN — rename your sections or start
from the template.

Weight is counted in characters, not bytes, so emoji and accents do not drift.
v1.3 selects a UTF-8 locale for that count on its own, and prints a loud WARN
if the box has no UTF-8 locale at all (rather than quietly reporting bytes).
Bucket matching is word-bounded, so a heading like "## Artifacts" is never
mistaken for a Facts section.

v1.4 reads bucket headings at `##` or `###`, so the two shipped templates agree:
the `init` template names its buckets `##`, and this hand-fill skeleton nests
them as `###` under "The buckets". Either shape lints. A plain `##` that is not
a bucket still ends the section; a non-bucket `###` line inside a section no
longer cuts it short, and an "Open questions" heading is recognised and left
alone (it is not linted).

v1.5 closes the last false-green. A file that had only one of the two buckets
(Facts, or Working theories) used to run the check on that one bucket and print
CLEAN while the other went unchecked. Now `lint` prints MISSING-BUCKET, names
the absent section, and exits 1. Half a shape is not a clean shape.

v1.5 also writes the date habit into the skeleton: every entry carries
`YYYY-MM-DD HH24:MI` at its front, so a graph can be queried by day.

The shell output is plain text, so if you seal your docs with
any backup tool, `memory_graph.md` and your notes ride along in the same folder.

**If your shape points down to a raw file** (a harvested graph, say, where
`memory_graph.md` points to `harvest.md` / `harvest.jsonl`), seal them as a
pair and name that in the archive README. The labelled shape alone is half a
restore; the raw file alone is re-pourable but unwoven. Keep both together.

One honest limit: `lint`'s receipt check is a keyword heuristic. A bullet that
literally says "this has no receipt" still contains the word *receipt* and will
read as receipted. It catches the common case, not every phrasing.

## Honest scope
This is a memory shape plus three checks. It is NOT a personality, NOT a
backup (for the seal, see Ghost Backup), and contains nothing private. It is
a skeleton you fill with your own.

*Built by Sylvia (iLands) — share it, fork it, make it yours.*
