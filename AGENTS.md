# AGENTS.md

Guidance for autonomous coding agents working in this repository.

## Repository Overview

- Monorepo with two primary parts:
  - Solidity smart contracts (Foundry) at repo root.
  - React + TypeScript frontend (Vite) in `frontend/`.
- Solidity source dir: `src/`
- Solidity scripts: `script/`
- Frontend source dir: `frontend/src/`

## Rule Files (Cursor / Copilot)

- `.cursorrules`: **not found**
- `.cursor/rules/`: **not found**
- `.github/copilot-instructions.md`: **not found**

If these files are added later, treat them as higher-priority local instructions.

## Tooling and Package Managers

- Solidity toolchain: Foundry (`forge`, `anvil`, `cast`)
- Frontend package manager: `pnpm` (`frontend/pnpm-lock.yaml` exists)
- Frontend stack: React 19 + TypeScript + Vite
- Frontend linting: ESLint flat config (`frontend/eslint.config.js`)

## Working Directory Conventions

- Solidity commands from repo root:
  - `/home/srcres/Coding/Learn/dapp-pet-shop-new`
- Frontend commands from:
  - `/home/srcres/Coding/Learn/dapp-pet-shop-new/frontend`

## Canonical Commands

### Solidity (Foundry)

- Install deps: `forge install`
- Build:
  - `forge build`
  - CI uses `forge build --sizes`
- Format:
  - `forge fmt`
  - CI check: `forge fmt --check`
- Test all:
  - `forge test`
  - CI uses `forge test -vvv`
  - Note: there are currently no top-level `test/*.t.sol` files in this repo.
    Add tests before relying on single-test filters.

### Run a single Solidity test (important)

- By test function name:
  - `forge test --match-test "testFunctionName" -vvv`
- By contract name:
  - `forge test --match-contract "ContractTestName" -vvv`
- By test file path glob:
  - `forge test --match-path "test/MyFeature.t.sol" -vvv`
- Path shortcut:
  - `forge test test/MyFeature.t.sol -vvv`

### Frontend (Vite + TypeScript)

- Install deps: `pnpm install`
- Dev server: `pnpm run dev`
- Build (includes TS build):
  - `pnpm run build`
  - expands to `tsc -b && vite build`
- Lint: `pnpm run lint`
- Preview build: `pnpm run preview`

### Frontend single-test status

- No frontend test runner is configured in `frontend/package.json`.
- There is no `test` script and no Vitest/Jest config.
- Do **not** invent test commands; add a test toolchain first if tests are needed.

## CI-Backed Checks

From `.github/workflows/test.yml`:

1. `forge fmt --check`
2. `forge build --sizes`
3. `forge test -vvv`

When editing Solidity, make these pass locally before finishing.

## Solidity Code Style Guidelines

Derived from `src/*.sol`, `script/Deploy.s.sol`, and `foundry.toml`.

- Always include SPDX and pragma at top.
  - Example: `// SPDX-License-Identifier: BSD-3-Clause`
  - Example: `pragma solidity ^0.8.24;`
- Use named imports with braces.
  - Example: `import {Trade} from "./Trade.sol";`
- Naming:
  - Contracts: `PascalCase`
  - Functions/variables: `camelCase`
  - Internal helpers: prefix with `_`
  - Events: `PascalCase`
- Prefer explicit visibility (`external/public/internal/private`).
- Use NatSpec for contracts and non-trivial functions (`@title`, `@notice`, etc.).
- Validate early using `require(..., "clear message")`.
- Keep revert strings explicit and user-actionable.
- Prefer `uint256` over `uint` in new code.
- Extract repeated logic into internal helper functions.
- Emit events for state-changing external actions.
- Run `forge fmt` after Solidity edits.

### Foundry lint nuance

- `foundry.toml` excludes:
  - `mixed-case-function`
  - `mixed-case-variable`
- Still prefer camelCase unless matching required external interfaces.

## Frontend Code Style Guidelines

Derived from `frontend/eslint.config.js`, `frontend/tsconfig*.json`, and `frontend/src/**/*`.

- Assume strict TypeScript (`strict: true`).
- Prefer alias imports from `@/` for app code.
- Prefer named imports and tidy import grouping.
- Use function components and hooks.
- Never call hooks conditionally.
- Use `type` imports for pure types when useful.
- Avoid `any`; use explicit types.
- Avoid unused variables (lint + TS enforce this).
- Keep side effects in event handlers/hooks, not during render.
- Reuse UI primitives from `frontend/src/components/ui/`.
- Preserve local file style (quotes/semicolon style is not fully uniform).
  - Do not mass-reformat unrelated files.

## Error Handling Guidelines

### Solidity

- Check permission/state guards first with `require`.
- Revert messages should explain exactly what failed.
- Validate low-level call success (`(bool success,) = ...; require(success, ...)`).

### Frontend/TypeScript

- Do not swallow errors silently.
- Surface error state to UI when practical.
- Prefer typed error handling to broad untyped handling.

## Files/Dirs to Treat Carefully

Avoid editing generated or vendored artifacts unless explicitly requested:

- `lib/**`
- `out/**`
- `cache/**`
- `broadcast/**`
- `frontend/dist/**`
- `frontend/node_modules/**`

## Suggested Agent Workflow

1. Identify impacted area (Solidity, frontend, or both).
2. Follow nearby patterns before introducing new ones.
3. Make minimal, surgical changes.
4. Run relevant checks:
   - Solidity: `forge fmt --check && forge build --sizes && forge test -vvv`
   - Frontend: `pnpm run lint && pnpm run build`
5. If tests are missing for the changed area, explicitly state that in your summary.
