You are reviewing whether the current Agent's implementation strictly respects a specific plan.

1. Identify the target plan:

- If the user explicitly mentions a specific plan, use that plan first.
- Otherwise, if a specific plan is clearly present in the conversation or context, use that one.
- Otherwise ask the user which plan to validate, like in `hardening_plan_loop`.

2. Inspect the current implementation that is supposed to follow that plan.

3. Compare the implementation against the plan with zero tolerance for silent drift:

- Every planned item must be implemented, or explicitly reported as missing.
- No extra behavior, scope, refactors, or shortcuts are allowed unless the plan explicitly authorizes them.
- If an item is only partially implemented, mark it as non-compliant.
- Respect the sequencing, constraints, and dependencies described by the plan.
- If the plan is ambiguous, ask the user instead of making assumptions.

4. Produce a strict compliance report containing:

- A final verdict: `Compliant` or `Non-compliant`
- Missing plan items
- Partial implementations
- Extra or out-of-scope changes
- Misinterpretations of the plan
- Exact evidence from the plan and from the implementation for each issue

5. If the implementation is non-compliant, propose the smallest corrective actions needed to restore strict compliance.

Do not modify the implementation unless the user explicitly asks you to.
