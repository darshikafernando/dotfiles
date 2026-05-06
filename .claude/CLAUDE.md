# Global instructions

These rules apply to every project. Project-level `CLAUDE.md` files override
when they conflict.

## Response style

- Default to short, direct answers. Reference code with `path:line`.
- For any deliverable longer than ~100 lines (runbook, design doc, review
  report, refactor plan), write it to a file under `docs/` (or a path the
  user specifies) and reply with:
  1. The file path
  2. A 5-bullet summary
  3. Any open questions
  Do not stream long content inline.
- End-of-turn summary: one or two sentences. What changed, what's next.

## Verifying conventions

Before recommending a convention, scope rule, naming pattern, or commit-message
style:

1. Run `git log --oneline -50` and inspect the relevant directory.
2. Cite 2-3 concrete examples from history.
3. Only then make the recommendation.

Do not infer conventions from `README.md` or docs alone — they drift from
practice. Real history is the source of truth.

## Stating assumptions before plans

When asked to design infra, write a plan, propose phasing, or set priorities:

1. List your assumptions in a numbered list, covering at minimum:
   - Scope and phasing
   - Priority/ordering rules
   - Which package, team, or system owns what
2. Stop. Wait for the user to confirm or correct each.
3. Only then produce the plan.

This applies to: implementation plans, design docs, runbooks, queue/routing
logic, scaling knobs, and any multi-step proposal.

## Show vs. execute

When the user asks you to *show*, *display*, or *print* a command, output the
command as text. Do not run it. Never fetch secret values, tokens, or
credentials unless the user explicitly asks you to read them.

Before running any command that reads or writes secrets (env vars matching
`*_TOKEN`, `*_KEY`, `*_SECRET`, `*_PASSWORD`; `aws secretsmanager`, `gcloud
secrets`, `vault`, `kubectl get secret`), confirm with the user.

## Hypothesis discipline

For any bug, test failure, or unexpected behavior:

1. Reproduce or write a failing test that captures the symptom before
   proposing a root cause.
2. Rank at least two hypotheses with evidence for each.
3. Verify against actual data (logs, commit history, screenshots) before
   committing to a fix.

Do not commit to a first-guess root cause based on filenames or surface
signals. The cost of one extra verification step is much smaller than the
cost of a wrong fix that breaks deployment.

## AWS / messaging domain notes

When reasoning about message queues, distinguish:

- **SNS topic subscription** — infrastructure-level configuration, lives in
  Terraform/CDK. Says "this queue *can* receive messages from this topic."
- **SQS queue existence** — does the queue exist with the right policy/DLQ?
- **Worker consumption** — does a running process actually poll and process
  the queue? Lives in application code and deployment manifests.

State which layer you are reasoning about. "I am subscribed" is ambiguous —
say "the SQS queue is subscribed to the SNS topic" or "the worker is
consuming from the queue."

## Subagent usage

For broad searches across a monorepo, dispatch parallel `Explore` subagents
per package and have them return only `file:line` hits. This keeps the main
context clean and avoids hitting output limits.

For independent tasks (review, search, verification), dispatch in parallel
in a single message rather than sequentially.

## What to skip

- Do not add comments that restate what the code does.
- Do not add error handling for impossible states.
- Do not add backwards-compat shims unless the user asks for them.
- Do not produce activity summaries, status reports, or what-I-did writeups
  unless asked.
