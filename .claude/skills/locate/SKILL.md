---
name: locate
description: Use when you need to find where something lives across a monorepo or large codebase - dispatches parallel Explore subagents scoped per package and returns only file:line hits, keeping the main context clean
---

# /locate

Cross-package search for monorepos. Returns a flat list of `file:line` hits
with a one-line context for each, nothing more. Designed to keep the main
agent's context clean and avoid output-token blowups on large searches.

## Inputs

- A search target: a symbol name, string, config key, alert name, queue
  name, IAM role, etc.
- Optionally: a list of packages to scope to. If omitted, identify packages
  from the monorepo's top-level directory layout (`packages/`, `services/`,
  `apps/`, `infra/`, etc.).

## Steps

1. **Identify packages.** Run `ls` on the monorepo root, plus any
   `pnpm-workspace.yaml`, `nx.json`, `turbo.json`, `Cargo.toml [workspace]`,
   or `go.work` to enumerate packages. If the user named specific packages,
   use those.

2. **Decide breadth.**
   - 1-3 packages → one search, no fan-out.
   - 4+ packages → fan out. Dispatch one `Explore` subagent per package (or
     per logical group of small packages) **in parallel in a single
     message**. Each subagent gets:
     - The search target
     - Its scoped directory
     - The instruction: "Return only `file:line` hits with a one-line
       context. No explanation, no summary, no recommendations."

3. **Aggregate.** Merge the subagent results into a single list, grouped
   by package:

   ```
   ## packages/auth
   - src/jwt.ts:42  function signToken(...)
   - src/jwt.test.ts:88  expect(signToken(...))

   ## services/api
   - handlers/login.go:17  token := signToken(user)
   ```

4. **Stop there.** Do not propose changes, do not analyze, do not summarize
   intent. The user asked where it lives, not what to do.

5. **If no hits**, say so plainly and list which packages were searched.
   Do not speculate about why the symbol does not exist.

## When to skip this skill

- Single-file search → use `Read` directly.
- Symbol with a clearly-known location → use `Grep` directly.
- "Explain this code" → wrong skill; use the standard exploration flow.

## Anti-patterns

- Do not fetch file contents beyond what's needed for the one-line context.
- Do not dispatch more than ~8 parallel subagents — group small packages.
- Do not let subagents return prose summaries; enforce `file:line` only.
