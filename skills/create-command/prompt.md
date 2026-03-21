# Create ai-sync Command Artifacts

Create commands for `ai-sync` source repos only. Do not write client-specific files.

## Hard Safety Constraints

1. Create command bundles only at `commands/<name>/artifact.yaml` plus `commands/<name>/prompt.md` in an **ai-config** repo.
2. Never create or edit generated/client outputs directly:
   - `.cursor/*`
   - `.codex/*`
   - `.gemini/*`
   - `.claude/*`
   - `CLAUDE.md`
   - `.ai-sync/*`
   - `.mcp.json`
3. Never create command files in `~/.cursor`, `~/.codex`, `~/.gemini`, `~/.claude`, or the current non-config project.

## Config Resolution

Before creating the artifact, resolve the target ai-sync config repository:

1. **Read the project manifest** (`.ai-sync.yaml` or `.ai-sync.local.yaml` in the project root).
2. **Single source**: use it directly — no prompt needed.
3. **Multiple sources**: ask the user which config repo should receive the artifact:
   "Multiple ai-sync configs found: `<alias-1>`, `<alias-2>`, … Which one should contain this new command?"
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

- Command intent (what agent behavior to trigger)
- Target audience (what kind of agent session uses this)
- Command name or relative path (used as the bundle id — prefer `snake_case`, and preserve nested namespaces when requested)
- Target ai-config repo path (resolved via Config Resolution above)

If any of the above is missing, ask concise follow-up questions.

## ai-sync Artifact Mapping

- Artifact type: `command`
- Required files:
  - `commands/<relative-path>/artifact.yaml`
  - `commands/<relative-path>/prompt.md`
- Reference ID shape: `<source-alias>/<relative-path>`
- Compatibility note: ai-sync resolves commands by relative path under `commands/`, using the bundle directory path without any file extension.

## Neutrality Requirement

The artifact must be reusable across clients and teams:

- Avoid customer names, product names, tenant IDs, internal URLs, or org-private jargon.
- Replace client-specific identifiers with placeholders like `<TEAM>`, `<SERVICE>`, `<REPO>`.
- Prefer universal engineering wording over platform-specific implementation details.

If user requests client-specific text, propose a neutral equivalent and confirm before writing.

## Writing Guidelines

Commands are bundle directories whose `artifact.yaml` stores metadata and whose `prompt.md` stores the markdown instructions. They range from short directives to elaborate workflows. If a command needs bundled helper files, place them under `files/`, but do not rely on those files being synced to client outputs yet. Follow these principles:

- Start with a clear imperative statement of what the agent should do.
- Include explicit constraints and forbidden behaviors when relevant.
- Define expected output format and structure if the command produces a report or artifact.
- Include authoritative sources or tool references when the command operates in a specific domain.
- Keep the command self-contained — an agent should be able to execute it without additional context.

### Command Template

Use this structure in `commands/<relative-path>/`:

```yaml
name: <Command display name>
description: <What this command does>
```

```md
<Clear imperative instruction — what the agent must do.>

<Context, constraints, and scope:>

- Constraint or required behavior
- Constraint or required behavior

<Expected output format or acceptance criteria, if applicable.>
```

Adapt the level of detail to the command's complexity: a simple directive can be 3–5 lines; a domain-specific workflow may include sections for authoritative sources, available tools, and known pitfalls.

## Remote Config Workflow

When the resolved config is remote, clone it, create a branch, write the artifact, then submit a PR.

### Step 1 — Clone and branch

```bash
git clone <git-url> <clone-dir>
git -C <clone-dir> checkout -b ai-sync/add-command-<name>
```

### Step 2 — Create the artifact

Create `commands/<relative-path>/artifact.yaml` and `commands/<relative-path>/prompt.md` in the cloned directory.

### Step 3 — Commit, push, and open PR

```bash
cd <clone-dir>
git add -A
git commit -m "feat: add <name> command"
git push -u origin HEAD
gh pr create --title "feat: add <name> command" --fill
```

Report the PR URL to the user.

## Creation Workflow

1. Resolve target ai-config repository (Config Resolution above).
2. Confirm `<name>` and intent with the user.
3. Draft command content with clear instructions and constraints.
4. Write `commands/<relative-path>/artifact.yaml` and `commands/<relative-path>/prompt.md` in the resolved config repo (or cloned directory for remote).
5. For remote configs, follow the Remote Config Workflow to submit a PR.
6. Verify no writes occurred in global or generated client paths.
7. Summarize what was created and where.

## Completion Checklist

- [ ] File created under `commands/` in an ai-config repo
- [ ] Both `artifact.yaml` and `prompt.md` created for the command bundle
- [ ] No client-specific identifiers
- [ ] Command is self-contained and actionable
- [ ] No writes to `.cursor/*`, `.codex/*`, `.gemini/*`, `.claude/*`, or `~/.{cursor,codex,gemini,claude}`
