---
name: quality-check
description: Run before marking coding tasks complete - validates code quality via IDE diagnostics, code review rules, and tests with fast-feedback short-circuiting
---

# Quality Check

## Overview

**Purpose**: Gate before declaring work complete. Catches obvious technical issues (type errors, linting, code review violations, test failures) before claiming a feature/task is done.

**Key Principle**: Fast feedback via sequential validation - stop at first failure to surface issues quickly.

## When to Use This Skill

**DO use quality-check:**
- Before marking a **complete feature/task** as done
- Validates the entire body of work, not individual steps
- User can explicitly call for on-demand validation

**DON'T use quality-check:**
- After completing individual todos in a larger workflow (too frequent)
- About to request code review (code reviewer catches these issues)
- In middle of implementation (expect errors while building)
- Making trivial changes (typo fixes, comments only)

**Mental model**: Final gate before declaring "this feature is complete", not step-by-step validation.

**Example:**
- ✅ Implemented user authentication feature (10 todos) → run quality-check
- ❌ Completed todo 3 of 10 (added login form) → don't run yet

## Validation Workflow

Run three checks **in order of speed**, short-circuiting on first failure:

### 1. IDE Diagnostics Check (fastest ~1s)

Check if IDE MCP server is available and query diagnostics:

```
try {
  diagnostics = mcp__ide__getDiagnostics()
  if (diagnostics has errors) {
    Report diagnostics and STOP
  }
} catch {
  IDE MCP unavailable, note this and continue
}
```

**Output on failure:**
```
❌ IDE Diagnostics (3 issues):
  apps/web/src/foo.ts:42 - error TS2345: Type mismatch
  apps/web/src/bar.ts:15 - warning: unused variable
```

### 2. Code Review Rules Check (medium ~5-10s)

Launch subagent to validate against CODE_REVIEW.md rules:

```
Task tool with prompt:
"Run the ci-code-review workflow from .ai-rules against current changes.
Report any violations found."
```

**Subagent handles:**
- Git change analysis
- CODE_REVIEW.md discovery (hierarchical)
- Rule validation

**Output on failure:**
```
❌ Code Review Rules (2 violations):
  packages/common/baz.ts violated rule from packages/CODE_REVIEW.md:
    "Never use relative imports" - Found: import { x } from '../utils'
```

If violations found: Report and STOP

### 3. Test Execution Check (slowest ~30s+)

Identify and run modified test files:

```bash
# Get modified test files
git diff --name-only HEAD | grep -E '\.(test|spec)\.(ts|tsx)$|servicetest\.ts$'

# Run all in single batch
just unit-test <path1> <path2> <path3>
```

**Output:**
```
✅ Tests: All passing (3 files, 47 tests)

OR

❌ Tests (1 failure):
  apps/web/src/foo.test.ts - FooComponent should render
    Expected: true, Received: false
```

## Output Format

**Success (all checks pass):**
```
✅ Quality Check: PASSED

IDE Diagnostics: No issues found
Code Review Rules: No violations
Tests: All passing (X files, Y tests)
```

**Failure (issues found):**
Report first failure encountered and stop. Show specific file locations, line numbers, and error messages.

## Edge Cases

**No changes detected:**
```bash
git diff --name-only HEAD  # returns empty
```
Report: "No changes detected, nothing to validate"

**No test files modified:**
Skip test execution entirely, report: "Tests: No test files modified, skipping"

**Subagent failures:**
If ci-code-review subagent crashes: Report error, ask if user wants to continue to test phase

**IDE MCP unavailable:**
Note that IDE diagnostics were skipped, continue with other checks

## Implementation Details

**Git commands:**
```bash
# Check for any changes
git diff --name-only HEAD

# Get full diff for code review analysis
git diff HEAD

# Find test files in changes
git diff --name-only HEAD | grep -E '\.(test|spec)\.(ts|tsx)$|servicetest\.ts$'
```

**Test file patterns:**
- `*.test.ts`, `*.test.tsx`
- `servicetest.ts`

**MCP check:**
Try to call `mcp__ide__getDiagnostics()`. If it throws/fails, IDE MCP is unavailable.

**Code review delegation:**
Use Task tool to launch subagent with explicit prompt to run ci-code-review workflow from `.ai-rules/`.

## Key Behaviors

- **Short-circuit**: Stop at first failure for fast feedback
- **Report only**: Never auto-fix issues, just surface them clearly
- **Delegate complexity**: Use subagent for code review rule logic
- **Graceful degradation**: Partial validation better than no validation
- **Sequential execution**: Run checks one at a time in speed order
