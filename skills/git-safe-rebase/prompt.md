# Git Safe Rebase

## Overview

Perform a guarded rebase of the current branch onto an **agreed integration branch** (for example `origin/main`, `origin/master`, or `origin/develop`). Require a pre-merge conflict scouting step and a written conflict-resolution plan before rebasing. Produce a concise, evidence-backed report with conflicts, hashes, and confidence.

## Base ref

Do not assume a team-specific default branch. At the start, confirm with the user the remote tracking ref to rebase onto; call it `BASE_REF` (example: `export BASE_REF=origin/main`). Use that same ref for fetch/merge/rebase steps below.

## Workflow (follow in order)

1. Preconditions

- Run `git status --short`.
- If not clean, stash everything: `git stash push -u -m "wip: rebase prep"`.
- Record whether a stash was created.

2. Update baseline

- `git fetch --all`
- Verify `BASE_REF` exists: `git rev-parse "${BASE_REF}"`
- If the user keeps a **local** branch that tracks `BASE_REF`, check it out, run `git pull --ff-only`, then `git checkout -` to return to the branch being rebased. If they work only with the remote ref, skip the local pull.
- Record current branch name and pre-rebase HEAD hash.

3. Study current branch

- `git log --oneline --decorate -n 50`
- `git diff "${BASE_REF}"...HEAD --stat`
- Summarize intended features/goals in one or two sentences.

4. Conflict scouting (dummy merge)

- `git merge --no-commit --no-ff "${BASE_REF}"`
- If conflicts appear, do not resolve.
- Write a conflict-resolution plan (temporary file in a temp dir) that lists:
  - Each conflicting file
  - Intended resolution strategy
  - Evidence supporting the plan (diff/log references)
- Review non-conflicting changes for consistency.
- Abort the merge: `git merge --abort`.

5. Rebase using the plan

- `git rebase "${BASE_REF}"`
- Resolve conflicts strictly per the written plan.
- If new conflicts appear not in the plan, update the plan and continue.
- If conflicts represent incompatible concepts/features (not just code), stop and refuse to rebase, explaining why.
- After the rebase completes, delete the temporary plan file.

## Rules

- No guessing. If any ambiguity exists, stop and ask questions.
- Any code involving external libraries must be verified with up-to-date official documentation (vendor or upstream docs; use documentation tools available in the environment when present, otherwise web search).
- Refuse to rebase if conflicts represent incompatible concepts/features.

## Required output

- Summary of resolved conflicts: strategy used, reasoning, and verifiable evidence.
- From and to branch/hash, and number of conflicts resolved.
- Confidence estimate that the rebase did not introduce errors.
- Note whether a stash was created and whether it remains un-applied.

## Output style

Be concise, evidence-backed, and explicit about any assumptions.
