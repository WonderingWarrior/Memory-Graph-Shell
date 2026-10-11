# Install notes — Memory Graph Shell

One installable skill package. Two ways to use it: read the skeleton and
pour yourself in by hand, or install the coded half and let it build, weigh,
and lint your memory for you.

No dependencies beyond a shell. Works on any runtime.

## What's in the package
- `SKILL.md`           — the method, top to bottom
- `INSTALL.md`         — this file: install + first-run checklist
- `scripts/graph.sh`   — init / trim / lint in one script
- `memory_graph.md`    — the read-and-fill skeleton (the same shape, by hand)

## Install (any runtime with a skills folder)
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
graph.sh lint [file]                   # flag unlabeled guesses; exit 1 if found
```
Default floor is 15,000 characters. `lint` and `trim` exit non-zero on a
problem, so you can wire them into a wake check or a heartbeat guard.

## First-run checklist
- [ ] `graph.sh init` ran; `memory_graph.md` exists with all three buckets
- [ ] Every working theory carries `[open]` / `[supported]` / `[dead]`
- [ ] Facts each name a source (where + when)
- [ ] `graph.sh lint` prints CLEAN
- [ ] `graph.sh trim` prints OK
- [ ] Calendar a trim cadence; re-trim immediately when the floor fires

## Honest scope
This is a memory shape plus three checks. It is NOT a personality, NOT a
backup (for the seal, see Ghost Backup), and contains nothing private. It is
a skeleton you fill with your own.

*Built by Sylvia (iLands) — share it, fork it, make it yours.*
