# AWS Read-Only Access

## When to use

- You need to inspect AWS resources without changing state.
- You need to verify the active caller identity, region, or profile.
- You need to diagnose `AccessDenied` on a command that should be read-only.

## Inputs

- A configured read-only AWS CLI profile or active temporary session (`AWS_PROFILE` and `AWS_REGION` are declared in this skill’s `artifact.yaml` for `ai-sync`).
- Clear user approval before any action outside read-only inspection.

## Prerequisites

- `source .env.ai-sync` (or equivalent) so `AWS_PROFILE` and `AWS_REGION` are set, unless the user already exports them for the session.

## Workflow

1. Confirm the current AWS context before running service commands:

```bash
source .env.ai-sync
aws sts get-caller-identity
aws configure get region
```

2. Use only non-mutating AWS CLI operations such as `list`, `describe`, `get`, and `head`.

3. If a command fails with `AccessDenied`, verify the profile, region, and account context first. Report the missing permission or context mismatch instead of attempting a broader role.

4. If the task requires creating, updating, deleting, tagging, deploying, or changing policies, stop and ask the user for a separate approved access path. Do not perform escalation under this skill.

## Output format

- Active profile and region used
- Caller identity summary
- Read-only commands executed
- Any `AccessDenied` findings or missing context

## Constraints

- Never use an admin or write-capable profile by default.
- Never create, modify, delete, deploy, tag, or change permissions under this skill.
- Never request or handle MFA codes, long-term access keys, or personal account credentials.
- Prefer temporary credentials and least privilege. If credentials are missing or expired, ask the user to refresh the read-only session through their normal access flow.
- Keep examples generic and use placeholders instead of account-specific values.

## Quality checks

- [ ] No account IDs, usernames, personal profile names, MFA device ARNs, or organization-specific references remain.
- [ ] All example commands are read-only.
- [ ] The skill includes no privilege-escalation workflow.

## References

- [Security best practices in IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html) - AWS, 2026
- [Use temporary credentials with AWS resources](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_use-resources.html) - AWS, 2026
- [Prepare for least-privilege permissions](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started-reduce-permissions.html) - AWS, 2026
