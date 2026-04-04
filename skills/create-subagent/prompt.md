# Create ai-sync Subagent Artifacts

In `ai-sync`, reusable agent definitions come from prompt bundles under `agents/<name>/`.
When asked to "create a subagent", create a prompt artifact in an ai-config source repo.

## Hard Safety Constraints

1. Create subagent bundles only at `agents/<name>/artifact.yaml` plus `agents/<name>/prompt.md` in an **ai-config** repo.
2. Never create or edit generated/client outputs directly:
   - `.cursor/*`
   - `.codex/*`
   - `.gemini/*`
   - `.claude/*`
   - `CLAUDE.md`
   - `.ai-sync/*`
   - `.mcp.json`
3. Never create subagent files in `~/.cursor`, `~/.codex`, `~/.gemini`, `~/.claude`, or the current non-config project.

## Config Resolution

Before creating the artifact, resolve the target ai-sync config repository:

1. **Read the project manifest** (`.ai-sync.yaml` or `.ai-sync.local.yaml` in the project root).
2. **Single source**: use it directly — no prompt needed.
3. **Multiple sources**: ask the user which config repo should receive the artifact:
   "Multiple ai-sync configs found: `<alias-1>`, `<alias-2>`, … Which one should contain this new subagent prompt?"
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

Collect before writing:

- Subagent goal and non-goals
- Trigger cues (when the prompt should be selected)
- Input contract (what the user/task must provide)
- Output contract (required sections/format)
- Safety constraints and forbidden actions
- Target ai-config repository path (resolved via Config Resolution above)
- Bundle name for `agents/<name>/` (stable identifier)
- Metadata values for the YAML file (`slug`, `name`, `description`)

If any are unclear, ask targeted questions first.

## ai-sync Artifact Mapping

- User intent: "subagent"
- ai-sync artifact type: `prompt`
- Required files:
  - `agents/<name>/artifact.yaml`
  - `agents/<name>/prompt.md`
- Reference ID shape: `<source-alias>/<name>`

## Prompt YAML Compatibility (Critical)

`ai-sync` prompt metadata is stored directly in `artifact.yaml`.

- Prompt body lives in sibling `prompt.md`.
- The bundle entry file is always `artifact.yaml`; optional helper assets may live under `agents/<name>/files/`, but non-skill bundle assets are not synced to client outputs yet.
- Required metadata keys:
  - `name` — human-readable name. **Must be present.**
  - `description` — what this subagent does and when to use it. **Must be present.**
- Optional metadata keys:
  - `slug` — kebab-case identifier (defaults to the bundle directory name)
- Do not invent extra metadata fields for ai-sync prompts.

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

## Prompt Template

Use this template for `agents/<name>/`:

```yaml
slug: <kebab-slug>
name: <Human readable name>
description: <What this subagent does and when to use it>
```

```md
# Role

You are a specialized assistant for <domain>.

## Objective

- Primary outcome
- Explicit non-goal

## Inputs

- Required inputs and assumptions

## Workflow

1. Analyze task and constraints
2. Execute deterministic process
3. Validate output quality and safety

## Output format

- Required sections/order

## Guardrails

- Forbidden actions
- Escalation/clarification conditions

## Quality checks

- [ ] Completeness
- [ ] Correctness
- [ ] Policy/safety compliance

## References

- [Title](https://example.com) - publisher, year
```

## Remote Config Workflow

When the resolved config is remote, clone it, create a branch, write the artifact, then submit a PR.

### Step 1 — Clone and branch

```bash
git clone <git-url> <clone-dir>
git -C <clone-dir> checkout -b ai-sync/add-subagent-<name>
```

### Step 2 — Create the artifact

Create `agents/<name>/artifact.yaml` and `agents/<name>/prompt.md` in the cloned directory.

### Step 3 — Commit, push, and open PR

```bash
cd <clone-dir>
git add -A
git commit -m "feat: add <name> subagent prompt"
git push -u origin HEAD
gh pr create --title "feat: add <name> subagent prompt" --fill
```

Report the PR URL to the user.

## Creation Workflow

1. Resolve target ai-config repository (Config Resolution above).
2. Confirm `<name>`, purpose, and trigger cues.
3. Draft prompt with clear inputs, workflow, output format, and guardrails.
4. Add neutral wording and placeholders for variable context.
5. Add best-practice references from recent reliable sources.
6. Save `agents/<name>/artifact.yaml` and `agents/<name>/prompt.md` in the resolved config repo (or cloned directory for remote).
7. For remote configs, follow the Remote Config Workflow to submit a PR.
8. Verify no writes occurred in global or generated client paths.
9. Summarize what was created and where.

## Completion Checklist

- [ ] Created `agents/<name>/artifact.yaml` and `agents/<name>/prompt.md` in ai-config repo only
- [ ] YAML file includes only `slug`, `name`, and `description`
- [ ] Did not use markdown frontmatter for ai-sync prompt metadata
- [ ] No client-specific identifiers
- [ ] Includes explicit workflow, guardrails, and quality checks
- [ ] Includes `## References` with reliable recent sources
- [ ] No writes to `.cursor/*`, `.codex/*`, `.gemini/*`, `.claude/*`, or `~/.{cursor,codex,gemini,claude}`
