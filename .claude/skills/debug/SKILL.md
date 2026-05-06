---
name: debug
description: Use when fixing a bug, test failure, crash, regression, or any unexpected behavior - enforces failing-repro-first, ranked hypotheses with evidence, and verification against real data before any fix is attempted
---

# /debug

Strict debugging discipline. Designed to prevent the failure mode where a
plausible-sounding first hypothesis turns into a wrong fix that breaks
something else (and then a second wrong fix on top of it).

This skill is **rigid**, not flexible — follow the steps in order. Do not
skip ahead even if the bug "looks obvious."

## When to use

Any of:
- A test is failing.
- A user reports unexpected behavior.
- A deploy/build broke.
- An alert fired.
- Something used to work and now doesn't.

If the user is asking "why does this code do X" without a failure, that's
exploration, not debugging — use the standard read/explain flow instead.

## Steps

### 1. Capture the symptom precisely

Before forming any hypothesis, write down (in a TodoWrite todo or inline):
- **What was observed** — exact error message, log line, screenshot text,
  or behavior. Quote it; do not paraphrase.
- **What was expected** — the correct behavior the user has in mind.
- **Reproduction** — exact steps, inputs, environment.

If any of these is unknown, ask the user. Do not guess.

### 2. Write a failing reproduction

Before proposing a root cause, produce a deterministic reproduction:
- **Preferred:** a failing test (unit or integration). Add it to the
  existing test suite if there's a natural home; otherwise create a
  scratch test you'll delete after.
- **Acceptable:** a runnable script or one-liner that triggers the
  symptom on demand.
- **Last resort:** a clear set of manual steps with verified output.

Run it. **Confirm it fails for the expected reason** — not for a setup
error, missing dependency, or unrelated noise. If the failure mode does
not match the symptom, the repro is wrong; fix it before continuing.

### 3. Gather evidence before hypothesizing

Pull real data, not surface signals:
- `git log -p -- <affected files>` — recent changes to the area
- `git log --since=<plausible window>` — what was deployed/merged recently
- Application logs around the failure timestamp
- Stack traces in full, not truncated
- Related config or env values

**Do not let filenames or function names suggest a cause.** "It's probably
the cache layer" based on the file being named `cache.py` is exactly the
trap to avoid.

### 4. Rank at least two hypotheses with evidence

Produce a ranked list. For each:
- **Hypothesis** — one sentence.
- **Evidence for** — what in step 3 supports it. Cite specifics
  (`commit abc123`, `line 47 of foo.py`, `log entry at 14:32:01`).
- **Evidence against** — what argues against it. Be honest; if there's
  none, say "no contradicting evidence yet, but unverified."
- **Verification step** — what specific check would confirm or refute.

If you can only produce one hypothesis, you have not gathered enough
evidence. Go back to step 3.

### 5. Verify before fixing

Run the verification step for the top hypothesis. Possible forms:
- Add a print/log statement, re-run the repro, confirm value.
- Read the suspect code path end-to-end (do not skim).
- Check git blame on the specific lines.
- Diff against the last known-good version.

**Do not write a fix until verification passes.** If verification refutes
the hypothesis, move to the next one in the ranking. If all are refuted,
go back to step 3 with the new evidence.

### 6. Fix on a branch, run the failing test

- Create a branch (`git checkout -b debug/<short-name>`) so rollback is
  trivial.
- Apply the minimal fix that addresses the verified root cause. Resist
  scope creep — no surrounding refactors, no "while I'm here" cleanup.
- Run the failing test. Confirm it passes.
- Run the broader affected test suite. Confirm no regressions.
- If anything still fails, the hypothesis was incomplete or wrong.
  Revert (`git reset --hard <branch-base>`) and return to step 4.

### 7. Report compactly

Reply with:
- **Root cause** — one sentence, citing specific evidence.
- **Fix** — file:line of the change.
- **Verification** — which test now passes that didn't before.
- **Risk** — any related code paths that might also be affected.

If the investigation produced significant analysis (e.g., a postmortem
worth keeping), use `/deliver` to write it to `docs/postmortems/` rather
than streaming inline.

## Anti-patterns to refuse

- "Let me try X and see if that fixes it." → No. Verify first, then fix.
- "The fix is probably to add a null check / try-except / fallback." →
  Symptom suppression, not root cause. Stop and re-evaluate.
- "I'll fix this and the related issue I noticed." → Out of scope.
  One bug, one fix.
- "The test passes locally but might be flaky in CI." → Then your repro
  is not deterministic. Go back to step 2.
- "I don't have access to the logs, but based on the error message..." →
  Ask the user for the logs. Do not proceed on guesswork.

## Relationship to superpowers skills

- `superpowers:systematic-debugging` covers the analytical method; this
  skill enforces the discipline of *not* skipping steps.
- `superpowers:test-driven-development` is the right reference for how to
  write the failing test in step 2.
- `superpowers:verification-before-completion` applies at step 6 — confirm
  the fix actually works before reporting done.

If those skills are available and active, defer to them for the
sub-procedures and use this skill as the orchestration scaffold.
