---
name: review
description: Use when reviewing a branch, PR, or set of changes - performs a structured code review by first learning repo conventions from git history, then dispatching a reviewer subagent, then returning a triage table the user can act on
---

# /review

Structured, pragmatic code review. Optimized for "tell me what actually
matters before I edit" rather than sprawling rewrites.

## Inputs

The user may provide a PR number, a base branch, or nothing. If nothing,
default to comparing the current branch against `origin/main` (or `master`
if `main` does not exist).

## Steps

1. **Learn conventions first.** Before judging anything, run:
   - `git log --oneline -50` on the affected directory
   - `git log --pretty=format:'%s' -20` to learn commit-message style
   - Skim 2-3 recent merged PRs in the area if `gh` is available
   Note conventions that the diff should be measured against (naming,
   error handling style, test layout, comment density).

2. **Get the diff.**
   - If a PR was given: `gh pr diff <num>`
   - Otherwise: `git diff origin/main...HEAD` (or the user's base)

3. **Dispatch a reviewer subagent.** Use the `feature-dev:code-reviewer`
   agent if available, otherwise `general-purpose`. Pass it:
   - The diff
   - The conventions you learned in step 1
   - The instruction: "Report only high-priority issues. Use confidence-based
     filtering. Group findings as must-fix / should-fix / nit. Include
     `file:line` for every finding."

4. **Return a triage table.** Format:

   ```
   | Severity   | File:Line          | Issue                          |
   |------------|--------------------|---------------------------------|
   | must-fix   | foo/bar.py:42      | Race condition on shared state |
   | should-fix | foo/baz.py:17      | Missing test for error path    |
   | nit        | foo/qux.py:88      | Inconsistent naming            |
   ```

5. **Ask before editing.** Do NOT start applying fixes. Ask:
   "Which items should I fix? (e.g. 'all must-fix', 'items 1, 3, 5',
   'skip the nits')"

6. **If the review is long**, write it to `docs/reviews/<branch>-<date>.md`
   and reply with only the path + the table summary, per the global
   response-style rule.

## Anti-patterns

- Do not start fixing without the triage step.
- Do not invent issues to fill the table — empty severity rows are fine.
- Do not measure against README examples; measure against actual recent
  commits.
- Do not include "consider refactoring X" suggestions unless they are
  blocking. Scope creep on reviews wastes time.
