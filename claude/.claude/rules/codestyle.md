---
description: Writing or modifying TypeScript/JavaScript code
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

# Code Style

## Prefer iterators over indexing

Use `for..of` and iterator-based patterns instead of index-based loops.

## Curly braces on all if statements

Single-line `if` statements must use curly braces and newlines. No braceless one-liners.

## Inline fields directly

Don't wrap inputs in a `props` sub-object. Inline the fields directly on the type/interface.

## Co-locate types with their module

Don't dump types into a catch-all `types.ts`. Put types specific to a service in the service file, types specific to an entity in the entity file, etc.

## Use canonical error types

Use domain-appropriate errors (e.g. `ResourceNotFound` from canonical-errors) instead of bare `Error`.

## Prefer object arguments to argument lists

For functions with more than 2-3 arguments, prefer a single object argument with named fields for clarity and extensibility.

```ts
// Bad
function createUser(name: string, email: string, age: number) { ... }
// Good
interface CreateUserInput {
  name: string;
  email: string;
  age: number;
}
function createUser(input: CreateUserInput) { ... }
```

## Consistent argument order

Related methods should have a consistent argument order. If `create(domainId, input)` takes domainId first, `update(domainId, id, input)` should too.

## YAGNI

Only add features, filters, fields, or API surface that is grounded in actual need. Don't speculatively add capabilities.

## Prefer flattened function styles

Prefer flattened function styles. Return early rather than adding unnecessary branching.
