---
description: Writing or modifying test files, planning test structure, or reviewing test code
paths: 
  - "**/*.test.ts"
---

# Testing Practices

## Context-aware test runner

Some packages use Vitest, others use Mocha. Check the package's existing test files or `package.json` before writing tests. Do not assume one runner.

## Vitest: use `test.extend` fixtures over `beforeAll`/`beforeEach`

In Vitest packages, prefer the `test.extend` fixture API for test setup.

`baseTest.extend("name", opts, async ({}, { onCleanup }) => { ... })` 

This is a newer feature of Vitest so some older tests might not be using it yet but it is preferred.

## Study existing tests before writing new ones

Before writing tests for a package, read 1-2 existing test files to learn the runner, assertion library, fixture patterns, utilities, and naming conventions. Do not guess at APIs. If corrected on a pattern, read a reference file to see actual syntax.

## No placeholder or no-op tests

Never write `expect(true).toBe(true)` or similar filler. Every test must assert meaningful behavior.

## No brittle tests

- Assert on behavior, not implementation details.
- Prefer partial matching (`expect.objectContaining`, `toMatchObject`) over exact deep equality when only specific fields matter.
- Avoid asserting on exact error messages or internal state that may change without affecting correctness.

## Apply corrections consistently

When a test pattern is corrected in one place, propagate that correction to all analogous spots in the changeset. Do not fix one test and leave the same issue in others.
