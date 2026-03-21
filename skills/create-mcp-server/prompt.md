# Create ai-sync MCP Server Artifacts

Add MCP server definitions to `ai-sync` source repos only. Do not write client-specific files.

## Hard Safety Constraints

1. Create MCP server artifacts only at `mcp-servers/<server-id>/artifact.yaml` in an **ai-config** repo.
2. Never create or edit generated/client outputs directly:
   - `.cursor/*`
   - `.codex/*`
   - `.gemini/*`
   - `.claude/*`
   - `CLAUDE.md`
   - `.ai-sync/*`
   - `.mcp.json`
3. Never create server configs in `~/.cursor`, `~/.codex`, `~/.gemini`, `~/.claude`, or the current non-config project.

## Config Resolution

Before creating the artifact, resolve the target ai-sync config repository:

1. **Read the project manifest** (`.ai-sync.yaml` or `.ai-sync.local.yaml` in the project root).
2. **Single source**: use it directly — no prompt needed.
3. **Multiple sources**: ask the user which config repo should receive the artifact:
   "Multiple ai-sync configs found: `<alias-1>`, `<alias-2>`, … Which one should contain this new MCP server?"
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

- Server name (human-readable display name)
- Server description (what the MCP server does)
- Server ID (directory name — prefer kebab-case, e.g. `github`, `aws-documentation`)
- Transport method: `stdio`, `http`, or `sse`
- For `stdio`: `command` and `args`
- For `http`/`sse`: `url`
- Environment variables needed (and whether they hold secrets)
- Runtime requirements (e.g. `npx`, `uvx`, `python`) and minimum version
- Target ai-config repo path (resolved via Config Resolution above)

If any critical input is missing, ask concise follow-up questions.

## ai-sync Artifact Mapping

- Artifact type: `mcp-server`
- Required path: `mcp-servers/<server-id>/artifact.yaml`
- Reference ID shape: `<source-alias>/<server-id>`
- Compatibility note: ai-sync resolves MCP servers by directory name under `mcp-servers/`.

## artifact.yaml Schema

The `artifact.yaml` file is validated by ai-sync against a strict schema. Supported fields:

| Field                | Type                       | Required                  | Notes                                                                                                   |
| -------------------- | -------------------------- | ------------------------- | ------------------------------------------------------------------------------------------------------- |
| `name`               | string                     | **Yes**                   | Server display name                                                                                     |
| `description`        | string                     | **Yes**                   | Human-readable purpose                                                                                  |
| `method`             | `stdio` \| `http` \| `sse` | Yes (default: `stdio`)    | Transport protocol                                                                                      |
| `command`            | string                     | Required for `stdio`      | Executable to launch                                                                                    |
| `args`               | list of strings            | No                        | Command arguments                                                                                       |
| `url`                | string                     | Required for `http`/`sse` | Server endpoint URL                                                                                     |
| `trust`              | boolean                    | No                        | Whether to auto-approve tool calls                                                                      |
| `timeout_seconds`    | number                     | No                        | Must be >= 0                                                                                            |
| `auth`               | map of string to string    | No                        | Authentication headers                                                                                  |
| `oauth`              | object                     | No                        | OAuth config (enabled, clientId, clientSecret, authorizationUrl, tokenUrl, issuer, redirectUri, scopes) |
| `headers`            | map of string to string    | No                        | Extra HTTP headers                                                                                      |
| `auth_provider_type` | string                     | No                        | Authentication provider identifier                                                                      |
| `client_overrides`   | map of client to override  | No                        | Per-client field overrides                                                                              |
| `dependencies`       | object                     | No                        | Artifact-local env declarations under `dependencies.env`; MCP rendered `env` is synthesized from it     |

Do **not** use a `timeout` field (removed; use `timeout_seconds` instead).

### Examples

**stdio server (npx)**:

```yaml
name: GitHub
description: GitHub integration via MCP.
method: stdio
command: npx
args: ["-y", "@modelcontextprotocol/server-github"]
```

**stdio server (uvx) with synthesized env**:

```yaml
name: AWS Documentation
description: AWS documentation lookup.
method: stdio
command: uvx
args: ["awslabs.aws-documentation-mcp-server@latest"]
dependencies:
  env:
    FASTMCP_LOG_LEVEL: "ERROR"
    AWS_REGION: "us-east-1"
```

**http server with secret**:

```yaml
name: Exa
description: Web search and content discovery via Exa.
method: http
url: https://mcp.exa.ai/mcp
dependencies:
  env:
    EXA_API_KEY:
      secret:
        provider: op
        ref: op://<vault>/<item>/<field>
```

**stdio server via mcp-remote proxy**:

```yaml
name: Notion
description: Notion workspace integration via mcp-remote proxy.
method: stdio
command: npx
args: ["-y", "mcp-remote", "https://mcp.notion.com/mcp"]
```

## Related Config Files

When adding a server, check whether these companion files need updating in the same config repo:

### `dependencies` in `artifact.yaml`

If the server's `command` is a runtime tool (e.g. `npx`, `uvx`, `python`), declare it under `dependencies.binaries`:

```yaml
dependencies:
  binaries:
    - name: npx
      version:
        require: ~10.0.0
```

- If the same binary is declared in another selected artifact with an identical version constraint, it is deduplicated automatically.
- Conflicting version constraints for the same binary name across selected artifacts raise a collision error.
- Version prefix must be `~` (compatible within minor) or `^` (compatible within major), followed by `X.Y.Z`.

Declare env dependencies under `dependencies.env` in the same block:

```yaml
dependencies:
  env:
    PUBLIC_REGION: us-east-1
    AWS_PROFILE:
      local: {}
    EXA_API_KEY:
      secret:
        provider: op
        ref: op://<vault>/<item>/<field>
  binaries:
    - name: npx
      version:
        require: ~10.0.0
```

- Use `dependencies.env` for all dependency declarations (literal / local / secret).
- For MCP servers, prefer `dependencies.env` only; `ai-sync` synthesizes rendered subprocess `env` from it. Optional `inject_as` sets the subprocess env var name while the mapping key stays unique (avoids merge conflicts when two servers need the same tool env name, for example two Stripe keys both exposed as `STRIPE_SECRET_KEY`).
- Avoid top-level `env` on MCP `artifact.yaml` unless you need `${VAR_NAME}` interpolation in extra fields; prefer `inject_as` for secret-to-subprocess renaming.
- Keep `${VAR_NAME}` placeholders in other runtime-bearing fields (`headers`, `auth`, `oauth`, `url`, `args`) when runtime interpolation is needed.

## Neutrality Requirement

The artifact must be reusable across clients and teams:

- Avoid customer names, product names, tenant IDs, internal URLs, or org-private jargon.
- Replace client-specific identifiers with placeholders like `<TEAM>`, `<SERVICE>`, `<REPO>`.
- Prefer universal engineering wording over platform-specific implementation details.

If user requests client-specific text, propose a neutral equivalent and confirm before writing.

## Remote Config Workflow

When the resolved config is remote, clone it, create a branch, write the artifacts, then submit a PR.

### Step 1 — Clone and branch

```bash
git clone <git-url> <clone-dir>
git -C <clone-dir> checkout -b ai-sync/add-mcp-server-<server-id>
```

### Step 2 — Create the artifacts

In the cloned directory:

1. Create `mcp-servers/<server-id>/artifact.yaml`.
2. Add `dependencies.binaries` in `artifact.yaml` if the server uses a runtime tool.
3. Add `dependencies.env` in `artifact.yaml` for env/secret requirements.

### Step 3 — Commit, push, and open PR

```bash
cd <clone-dir>
git add -A
git commit -m "feat: add <server-id> MCP server"
git push -u origin HEAD
gh pr create --title "feat: add <server-id> MCP server" --fill
```

Report the PR URL to the user.

## Creation Workflow

1. Resolve target ai-config repository (Config Resolution above).
2. Confirm `<server-id>`, transport method, and required configuration.
3. Create directory `mcp-servers/<server-id>/` in the resolved config repo (or cloned directory for remote).
4. Write `artifact.yaml` following the schema above.
5. Declare binary dependencies in `artifact.yaml` under `dependencies.binaries` if the server uses a runtime tool.
6. Declare all required env vars/secrets in `artifact.yaml` under `dependencies.env`.
7. For remote configs, follow the Remote Config Workflow to submit a PR.
8. Verify no writes occurred in global or generated client paths.
9. Summarize what was created and where.

## Completion Checklist

- [ ] `mcp-servers/<server-id>/artifact.yaml` created in an ai-config repo
- [ ] `artifact.yaml` passes the ai-sync schema (valid `method`, required fields present)
- [ ] Secrets use `op://` references in `artifact.yaml` `dependencies.env` — no plaintext credentials
- [ ] `dependencies.binaries` declared in `artifact.yaml` if a runtime tool is needed
- [ ] No client-specific identifiers
- [ ] No writes to `.cursor/*`, `.codex/*`, `.gemini/*`, `.claude/*`, or `~/.{cursor,codex,gemini,claude}`
