# Create ai-sync Rule Artifacts

Create rules for `ai-sync` source repos only. Do not write client-specific files.

## Hard Safety Constraints

1. Create rule bundles as `rules/<name>/artifact.yaml` plus `rules/<name>/prompt.md` in an **ai-config** repo.
2. Never create or edit generated/client outputs directly:
   - `.cursor/*`
   - `.codex/*`
   - `.gemini/*`
   - `.claude/*`
   - `CLAUDE.md`
   - `.ai-sync/*`
   - `.mcp.json`
3. Never create rule files in `~/.cursor`, `~/.codex`, `~/.gemini`, `~/.claude`, or the current non-config project.

## Config Resolution

Before creating the artifact, resolve the target ai-sync config repository:

1. **Read the project manifest** (`.ai-sync.yaml` or `.ai-sync.local.yaml` in the project root).
2. **Single source**: use it directly — no prompt needed.
3. **Multiple sources**: ask the user which config repo should receive the artifact:
   "Multiple ai-sync configs found: `<alias-1>`, `<alias-2>`, … Which one should contain this new rule?"
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

Collect these inputs before creating the file:

- Rule intent (what behavior to enforce)
- Scope (global vs file/domain-specific)
- Rule name (file stem used as resource ID)
- Target ai-config repo path (resolved via Config Resolution above)
- Any mandatory internal standards to include
- Metadata values for the YAML file (`name`, `description`, `alwaysApply`, optionally `globs`)

If any of the above is missing, ask concise follow-up questions.

## ai-sync Artifact Mapping

- Artifact type: `rule`
- Required files:
  - `rules/<name>/artifact.yaml`
  - `rules/<name>/prompt.md`
- Reference ID shape: `<source-alias>/<name>`
- Compatibility note: ai-sync resolves rules by bundle directory name.

## Rule YAML Compatibility (Critical)

`ai-sync` rule metadata is stored directly in `artifact.yaml`.

- Rule body lives in sibling `prompt.md`.
- The bundle entry file is always `artifact.yaml`; optional helper assets may live under `rules/<name>/files/`, but non-skill bundle assets are not synced to client outputs yet.
- Required metadata keys:
  - `name` — rule display name. **Must be present.**
  - `description` — rule description (used in generated rule metadata for supported clients). **Must be present.**
- Optional metadata keys:
  - `alwaysApply` — boolean, whether the rule is always active (default: `true`)
  - `globs` — list of file patterns for scoped rule application (e.g. `["*.py", "*.ts"]`)
- Do not invent extra metadata fields for ai-sync rules.

Required metadata fields for `rules/<name>/artifact.yaml`:

```yaml
name: <Rule display name>
description: Short rule description
alwaysApply: true
```

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

## Writing Template

Use this structure in `rules/<name>/`:

```yaml
name: <Rule display name>
description: Short rule description
alwaysApply: true
```

```md
# <Rule Title>

## Intent

One short paragraph describing desired behavior and why it matters.

## Required behaviors

- Concrete, testable instruction
- Concrete, testable instruction

## Prohibited behaviors

- What to avoid and why

## Examples

### Good

- ...

### Bad

- ...

## Validation checklist

- [ ] Condition to verify compliance
- [ ] Condition to verify compliance

## References

- [Title](https://example.com) - publisher, year
- [Title](https://example.com) - publisher, year
```

## Remote Config Workflow

When the resolved config is remote, clone it, create a branch, write the artifact, then submit a PR.

### Step 1 — Clone and branch

```bash
git clone <git-url> <clone-dir>
git -C <clone-dir> checkout -b ai-sync/add-rule-<name>
```

### Step 2 — Create the artifact

Create `rules/<name>/artifact.yaml` and `rules/<name>/prompt.md` in the cloned directory.

### Step 3 — Commit, push, and open PR

```bash
cd <clone-dir>
git add -A
git commit -m "feat: add <name> rule"
git push -u origin HEAD
gh pr create --title "feat: add <name> rule" --fill
```

Report the PR URL to the user.

## Creation Workflow

1. Resolve target ai-config repository (Config Resolution above).
2. Confirm `<name>` and intent.
3. Draft neutral content with explicit do/don't guidance.
4. Add at least two reliable references.
5. Write `rules/<name>/artifact.yaml` and `rules/<name>/prompt.md` in the resolved config repo (or cloned directory for remote).
6. For remote configs, follow the Remote Config Workflow to submit a PR.
7. Verify no writes occurred in global or generated client paths.
8. Summarize what was created and where.

## Completion Checklist

- [ ] Rule file created at `rules/<name>/artifact.yaml` in an ai-config repo only
- [ ] Rule bundle includes `artifact.yaml` and `prompt.md`
- [ ] YAML file includes only `name`, `description`, `alwaysApply`, and `globs`
- [ ] Did not use markdown frontmatter for ai-sync rule metadata
- [ ] No client-specific identifiers
- [ ] Includes actionable examples and validation checklist
- [ ] Includes `## References` with reliable recent sources
- [ ] No writes to `.cursor/*`, `.codex/*`, `.gemini/*`, `.claude/*`, or `~/.{cursor,codex,gemini,claude}`
