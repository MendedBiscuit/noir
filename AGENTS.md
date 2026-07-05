# this machine

julian's laptop is a second brain: a place where thoughts are captured, stored
as plain text, and compounded into context that both julian and AI agents work
from. you — the agent reading this — are a citizen of this machine, not a
visitor. the deal: you get full context from the same files julian reads, and
in return you write back what you learn.

the philosophy lives in the vault: `~/Data/personal/notes/pages/machine.md`.
this file is the operating manual.

## the map

| where | what |
|---|---|
| `~` | the "noir" dotfiles repo (github.com/MendedBiscuit/noir). whitelist gitignore — new files need `git add -f` |
| `~/.bin/` | all machine functionality as shell scripts (work.sh, notes.sh, capture.sh, local-ai.sh, …) |
| `~/Data/personal/notes` | **the vault** — logseq, plain markdown, its own git repo. the single source of truth for context |
| `~/Data/unimelb` | uni materials, one folder per semester/subject (mirrors vault pages) |
| `~/Data/tex` | latex write-ups (repo MendedBiscuit/Tex) |
| `~/Data/DLH` | datalabhell work — fiber pipeline, synth, splinter |
| `~/Data/personal/cbf` | from-scratch autonomous thinker testbed |
| `~/.claude/projects/-home-julian/memory/` | claude code's persistent memory (claude maintains this; other agents may read) |

## the vault

- `journals/YYYY_MM_DD.md` — the daily log. what happened, what was decided, TODOs
- `pages/` — one topic per page. hubs: `uni`, `dlh`, `personal`. `contents.md` is the front door
- `pages/inbox.md` — raw capture, sorted later. Super+N appends here from anywhere
- page names are short slugs (`mhs`, `ntc`, `cbf`); properties (`key:: value`) at the top

## the contract

1. **read before you write.** the vault holds the context — check the relevant
   page and recent journals before starting real work.
2. **write back what you learn.** significant work leaves a trace: a line in
   today's journal, an update on the project's page. a session that leaves no
   trace taught the machine nothing.
3. **plain text, existing structure.** no new formats, apps, or databases
   unless julian asks. markdown in, markdown out.
4. **git is the memory of record.** commit in each repo's style (lowercase,
   terse, e.g. "sem4 from the handbook: …"). don't push unless asked.
5. **no secrets in the vault or dotfiles.** api keys, tokens, passwords never
   get committed. if you find one, flag it.
6. **sudo needs julian.** no passwordless sudo; pkexec is broken from shells.
   spawn `alacritty --class float-tui -e sh -c 'sudo …'` and let him type it.
7. **absolute paths in sway/exec contexts.** claude lives at
   `~/.local/bin/claude` and is not on sway's PATH.
8. **capture beats polish.** a rough note in the inbox now is worth more than
   a perfect page never written.

## the agents

- **claude code** (`Super+C`, `claude` in a shell) — the heavy agent. has
  persistent memory, does research, system work, writing
- **noir local ai** (`Super+V`, `ai` in a shell) — offline qwen3-vl via
  ollama + opencode. reads this file too. good for quick, private, no-network
  work on vault and files
- both operate on the same files under the same contract. disagreements are
  resolved by what's written in the vault
