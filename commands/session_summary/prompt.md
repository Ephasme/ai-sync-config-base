You are an expert at summarizing conversations for exact state restoration across sessions. The summary is for the same user or an AI continuing in a new session.

Generate a 'State Restoration' summary of our conversation. Output a single Markdown code block that can be copy-pasted into a new session. The summary must include only:

1. **Primal Goal** — What we are ultimately trying to achieve (the "why").
2. **Current State** — What has been completed; last modified files/functions/variables; progress percentage if relevant.
3. **Constraints** — Any specific rules, libraries, patterns, or tone instructions established.
4. **Key Technical Details** — File paths, specific function/variable names, important line numbers, architectural decisions made.
5. **Tried & Failed** — Approaches that were attempted and why they didn't work (prevents repeating mistakes).
6. **Open Questions** — Unresolved issues, pending decisions, ambiguities that need clarification.
7. **Dependencies** — Related files/systems/components that matter for this work; what impacts what.
8. **Next Logical Step** — What specifically needs to happen in the very next prompt.

**Rules:**

- Be specific: use exact file paths, function names, line numbers
- Eliminate conversational filler
- If a section has no clear content, output `None` for that section
- Prioritize information that can't be easily rediscovered by reading code
- Include "why" decisions were made, not just "what" was done

## Example (Simple Task)

```markdown
1. **Primal Goal** — Add dark mode to the settings screen.
2. **Current State** — Theme context exists in `src/context/ThemeContext.tsx`; Settings UI (`src/screens/Settings.tsx`) still uses hardcoded light styles.
3. **Constraints** — Use CSS variables; no new dependencies; maintain backwards compatibility with existing theme structure.
4. **Key Technical Details** — Theme tokens defined in `:root` and `[data-theme="dark"]` in `styles/tokens.css`; useTheme() hook returns `{ theme, toggleTheme }`.
5. **Tried & Failed** — None.
6. **Open Questions** — Should we persist theme preference to localStorage or leave it session-only?
7. **Dependencies** — `Settings.tsx` imports `Button` and `Card` components which also need theme support eventually.
8. **Next Logical Step** — Replace hardcoded colors in `Settings.tsx` lines 45-67 with `var(--color-bg)` and `var(--color-text)`.
```

## Example (Complex Task After Debugging)

```markdown
1. **Primal Goal** — Fix race condition in user authentication flow causing intermittent login failures.
2. **Current State** — Identified root cause: `AuthProvider.tsx` lines 89-102 has async token refresh racing with navigation. Added mutex lock using `useRef`. Login success rate improved from 60% to 95% in testing.
3. **Constraints** — Cannot change API contract; must support React 18 concurrent mode; no external state management libraries.
4. **Key Technical Details** — `refreshToken()` in `lib/auth.ts` takes 200-500ms; navigation happens in `useEffect` in `LoginScreen.tsx:156`; token stored in secure localStorage under key `auth_token_v2`.
5. **Tried & Failed** — Debouncing refresh (still raced); moving token to Context state (caused re-render loops); using Promise.all (didn't serialize correctly).
6. **Open Questions** — Should we add retry logic for the remaining 5% failures? What's the root cause of those?
7. **Dependencies** — `ProtectedRoute.tsx` also calls token refresh; `api/client.ts` interceptor needs token; logout flow in `Header.tsx` must clear the mutex.
8. **Next Logical Step** — Test the mutex solution with 1000 rapid login attempts; if success rate hits 99%+, apply same pattern to `ProtectedRoute.tsx`.
```
