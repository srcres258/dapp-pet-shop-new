# AGENTS.md

Guidance for autonomous coding agents working in this repository.

## 1) Repository Topology

- Monorepo with two active surfaces:
  - Solidity smart-contract project (Foundry) at repo root.
  - React + TypeScript frontend (Vite) in `frontend/`.
- Solidity source: `src/`
- Solidity scripts: `script/`
- Frontend app source: `frontend/src/`

## 2) Rule Files (Cursor / Copilot)

Check these before making edits because they can override general guidance.

- `.cursorrules`: **not found**
- `.cursor/rules/`: **not found**
- `.github/copilot-instructions.md`: **not found**

If any appear later, treat them as higher-priority local instructions.

## 3) Tooling and Package Managers

- Solidity: Foundry (`forge`, `cast`, `anvil`)
- Frontend: Vite + React 19 + TypeScript 5
- Frontend package manager: `pnpm` (lockfile at `frontend/pnpm-lock.yaml`)
- Frontend linting: ESLint flat config (`frontend/eslint.config.js`)

## 4) Working Directory Conventions

Run commands from the correct directory:

- Solidity / Foundry commands:
  - `/home/srcres/Coding/Learn/dapp-pet-shop-new`
- Frontend commands:
  - `/home/srcres/Coding/Learn/dapp-pet-shop-new/frontend`

## 5) Canonical Build / Lint / Test Commands

### Solidity (Foundry, repo root)

- Install dependencies: `forge install`
- Build: `forge build`
- Format: `forge fmt`
- Format check (CI-aligned): `forge fmt --check`
- Test all: `forge test`
- Test all (CI-aligned verbosity): `forge test -vvv`
- Build with contract sizes (CI): `forge build --sizes`

### Run a single Solidity test (important)

All of these are canonical Foundry patterns:

- By test function regex:
  - `forge test --match-test "testFunctionName" -vvv`
- By contract regex:
  - `forge test --match-contract "ContractTestName" -vvv`
- By path glob:
  - `forge test --match-path "test/MyFeature.t.sol" -vvv`
- File shortcut (equivalent to match-path):
  - `forge test test/MyFeature.t.sol -vvv`

Additional useful filters:

- Short aliases: `--mt`, `--mc`, `--mp`
- Exclusion filters: `--no-match-test`, `--no-match-contract`, `--no-match-path`

Repo caveat: there are currently no top-level `test/*.t.sol` files. Add tests before relying on single-test filters.

### Frontend (Vite + TypeScript, `frontend/`)

- Install dependencies: `pnpm install`
- Dev server: `pnpm run dev`
- Build (type-check + bundle): `pnpm run build`
  - expands to: `tsc -b && vite build`
- Lint: `pnpm run lint`
  - expands to: `eslint .`
- Preview: `pnpm run preview`

### Frontend single-test status

- No frontend test runner is configured in `frontend/package.json`.
- There is no `test` script and no Vitest/Jest config.
- Do **not** invent frontend test commands; first add a test toolchain.

## 6) CI-Backed Commands (authoritative)

From `.github/workflows/test.yml`:

1. `forge fmt --check`
2. `forge build --sizes`
3. `forge test -vvv`

If you modify Solidity, ensure these pass locally before finishing.

## 7) Solidity Style and Quality Guidelines

Derived from `src/*.sol`, `script/Deploy.s.sol`, and `foundry.toml`.

- Include SPDX and pragma at file top.
  - Example: `// SPDX-License-Identifier: BSD-3-Clause`
  - Example: `pragma solidity ^0.8.24;`
- Prefer named imports with braces.
  - Example: `import {Trade} from "./Trade.sol";`
- Naming conventions:
  - Contracts/events: `PascalCase`
  - Functions/variables: `camelCase`
  - Internal helpers: prefix `_`
- Always set explicit visibility.
- Use NatSpec for contracts and non-trivial functions.
- Validate early using `require(...)` with clear messages.
- Keep revert strings explicit and actionable.
- Prefer `uint256` over `uint` for new code.
- Emit events for externally-triggered state changes.
- Extract repeated logic into internal helpers.
- Run `forge fmt` after Solidity edits.

Foundry lint nuance from `foundry.toml`:

- Excluded lints: `mixed-case-function`, `mixed-case-variable`
- Even so, prefer camelCase unless an interface requires otherwise.

## 8) Frontend TypeScript / React Style Guidelines

Derived from `frontend/eslint.config.js`, `frontend/tsconfig*.json`, and existing app code.

- TypeScript is strict (`strict: true`).
- Avoid `any`; use explicit types/interfaces.
- Keep imports clean and grouped.
- Prefer alias imports from `@/` for app modules.
- Use function components + hooks.
- Never call hooks conditionally.
- Keep side effects in hooks/handlers, not render paths.
- Prefer `type` imports for type-only symbols where practical.
- Avoid unused locals/params (TS flags enforce this).
- Reuse existing UI primitives from `frontend/src/components/ui/`.
- Preserve local file formatting style; avoid unrelated mass reformatting.

## 9) Error Handling Conventions

### Solidity

- Put authorization/state checks first (`require`).
- Make revert reasons precise and user-actionable.
- Check low-level call success:
  - `(bool success,) = target.call(data);`
  - `require(success, "...");`

### Frontend / TypeScript

- Never silently swallow errors.
- Surface failures to UI state when practical.
- Prefer typed error flows over broad untyped catches.

## 10) Directories to Treat as Generated / Vendored

Avoid editing these unless explicitly requested:

- `lib/**`
- `out/**`
- `cache/**`
- `broadcast/**`
- `frontend/dist/**`
- `frontend/node_modules/**`

## 11) Recommended Agent Execution Flow

1. Determine impacted area (Solidity, frontend, or both).
2. Read nearby files and follow established local patterns.
3. Make minimal, surgical edits.
4. Run relevant validation:
   - Solidity: `forge fmt --check`, `forge build --sizes`, `forge test -vvv`
   - Frontend: `pnpm run lint`, `pnpm run build`
5. If tests are missing for touched code, state that explicitly in your summary.
