# Create ai-sync Skill Artifacts

Create new skills for `ai-sync` source catalogs only.

## Hard Safety Constraints

1. Create new skill bundles only in an **ai-config** repo, at `skills/<slug>/artifact.yaml` plus `skills/<slug>/prompt.md`.
2. Never create or edit generated/client outputs directly:
   - `.cursor/*`
   - `.codex/*`
   - `.gemini/*`
   - `.claude/*`
   - `CLAUDE.md`
   - `.ai-sync/*`
   - `.mcp.json`
3. Never create skills in `~/.cursor`, `~/.codex`, `~/.gemini`, `~/.claude`, or the current non-config project.

Naming compatibility note:

- Use a stable, simple skill directory name (prefer kebab-case).
- ai-sync resolves skills by directory name and syncs using kebab-case normalization.

## Config Resolution

Before creating the artifact, resolve the target ai-sync config repository:

1. **Read the project manifest** (`.ai-sync.yaml` or `.ai-sync.local.yaml` in the project root).
2. **Single source**: use it directly — no prompt needed.
3. **Multiple sources**: ask the user which config repo should receive the artifact:
   "Multiple ai-sync configs found: `<alias-1>`, `<alias-2>`, … Which one should contain this new skill?"
4. **Determine locality**:
   - A source is **local** if its `source` value starts with `./`, `../`, `/`, or `~`, or resolves to an existing directory on disk.
   - Otherwise the source is **remote** (git URL with a `version` pin).
5. **Local source**: write files directly to the resolved config repo path.
6. **Remote source**: ask the user:

   > The config `<alias>` is remote (`<url>`). Choose a workflow:
   > a) Clone the repo, make changes, and submit a PR
   > b) Skip — I'll handle the config change manually

   If option (a), follow the _Remote Config Workflow_ below.

## Required Discovery

Gather before writing:

- Skill objective and boundaries
- Trigger conditions (when to apply)
- Expected outputs
- Target ai-config repo path (resolved via Config Resolution above)
- Preferred slug (kebab-case)
- Whether companion files are needed under `skills/<slug>/files/` (`reference.md`, `examples.md`, `scripts/`)

If missing, ask concise follow-up questions.

## ai-sync Artifact Mapping

- Artifact type: `skill`
- Required files:
  - `skills/<slug>/artifact.yaml`
  - `skills/<slug>/prompt.md`
- Reference ID shape: `<source-alias>/<slug>`

## Neutrality Requirement

The artifact must be reusable across clients and teams:

- Avoid customer names, product names, tenant IDs, internal URLs, or org-private jargon.
- Replace client-specific identifiers with placeholders like `<TEAM>`, `<SERVICE>`, `<REPO>`.
- Prefer universal engineering wording over platform-specific implementation details.

If user requests client-specific text, propose a neutral equivalent and confirm before writing.

## Evidence Requirement

Artifact content must include high-quality, recent guidance:

1. Use reliable primary sources (official vendor docs, standards bodies, peer-reviewed/industry references).
2. Prefer sources updated within the last 24 months.
3. Cross-check at least two sources for non-trivial guidance.
4. Add a `## References` section in the artifact with links.

Preferred source categories:

- Official vendor/platform docs (OpenAI, Anthropic, Google, language/framework docs)
- Standards bodies or security authorities (NIST, OWASP, ISO guidance summaries)
- Reputable engineering org publications

## Skill Bundle Format

Source-of-truth lives in `artifact.yaml` plus sibling `prompt.md`. `ai-sync` generates the client-facing `SKILL.md` during sync.

```yaml
name: <slug>
description: <what the skill does and when to use it>
```

```md
# <Skill title>

## When to use

- Trigger condition

## Inputs

- Required input fields

## Workflow

1. Deterministic step
2. Deterministic step

## Output format

- Required output sections/checklists

## Constraints

- Safety and scope constraints

## Quality checks

- [ ] Verifiable criterion
- [ ] Verifiable criterion

## References

- [Title](https://example.com) - publisher, year
```

Optional bundled files always live under `skills/<slug>/files/`:

```text
skills/<slug>/
├── artifact.yaml
├── prompt.md
└── files/
    ├── reference.md
    └── scripts/...
```

When the skill prompt refers to bundled assets, use the client-facing path such as `reference.md` or `scripts/tool.py`. `ai-sync` strips the source `files/` prefix when syncing the skill to clients.

## Authoring Rules

- Keep `artifact.yaml` concise metadata; put the skill instructions in `prompt.md` and move heavy supporting detail to `files/`.
- Use clear imperative instructions and explicit acceptance checks.
- Prefer one default path over many equivalent options.
- Avoid stale, date-fragile instructions unless clearly labeled as historical.

## Remote Config Workflow

When the resolved config is remote, clone it, create a branch, write the artifact, then submit a PR.

### Step 1 — Clone and branch

```bash
git clone <git-url> <clone-dir>
git -C <clone-dir> checkout -b ai-sync/add-skill-<slug>
```

### Step 2 — Create the artifact

Write `skills/<slug>/artifact.yaml`, `skills/<slug>/prompt.md`, and any optional `files/` contents into the cloned directory.

### Step 3 — Commit, push, and open PR

```bash
cd <clone-dir>
git add -A
git commit -m "feat: add <slug> skill"
git push -u origin HEAD
gh pr create --title "feat: add <slug> skill" --fill
```

Report the PR URL to the user.

## Creation Workflow

1. Resolve target ai-config repository (Config Resolution above).
2. Confirm slug and desired behavior.
3. Draft neutral bundle content with explicit workflow.
4. Add best-practice guidance backed by reliable sources.
5. Write `skills/<slug>/artifact.yaml` and `skills/<slug>/prompt.md` in the resolved config repo (or cloned directory for remote).
6. Optionally add `skills/<slug>/files/reference.md`, `skills/<slug>/files/examples.md`, or `skills/<slug>/files/scripts/`.
7. For remote configs, follow the Remote Config Workflow to submit a PR.
8. Verify no writes occurred in global or generated client paths.
9. Summarize what was created and where.

## Completion Checklist

- [ ] New skill created in ai-config repo only
- [ ] Paths are `skills/<slug>/artifact.yaml` and `skills/<slug>/prompt.md`
- [ ] No client-specific identifiers
- [ ] Includes `## References` with reliable recent sources
- [ ] No writes to `.cursor/*`, `.codex/*`, `.gemini/*`, `.claude/*`, or `~/.{cursor,codex,gemini,claude}`
