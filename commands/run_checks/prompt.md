Run the project's validation using `package.json` scripts only.

- Use only scripts defined in `package.json`, via the project's package manager.
- Prefer `check-types`, `check-lint`, `check-format`, and `test:unit` when they exist.
- Run `test:e2e` only if the user explicitly asks for it.
- If those exact script names do not exist, use the closest equivalents defined in `package.json`.
