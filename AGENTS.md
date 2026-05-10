# AGENTS.md

Guidance for autonomous coding agents working in this repository.

## 1) Repository Topology

- Monorepo with two surfaces:
  - Solidity smart-contract project (Foundry) at repo root.
  - React + TypeScript frontend (Vite) in `frontend/`.
- Solidity source: `src/` (6 contracts), deploy script: `script/Deploy.s.sol`.
- Frontend app source: `frontend/src/`.
- `copyright/` — non-coding assets (LaTeX/Typst). Do not edit.

## 2) Rule Files

- `.cursorrules`: not found
- `.cursor/rules/`: not found
- `.github/copilot-instructions.md`: not found

If any appear later, treat them as higher-priority local instructions.

## 3) Tooling

- Solidity: Foundry (`forge`, `cast`, `anvil`). Submodules: `forge-std`, `openzeppelin-contracts`, `solidity-stringutils`.
- Frontend: Vite + React 19 + TypeScript ~5.9, package manager `pnpm`.
- Frontend styling: TailwindCSS v4 (via `@tailwindcss/vite` plugin, NO PostCSS config), shadcn/ui (New York style, `components.json` at `frontend/`).
- Frontend web3: wagmi v3 + viem ~2.44 + RainbowKit v2 + React Query v5 + MetaMask SDK.
- Frontend IPFS: Pinata SDK (env var `VITE_PINATA_JWT` required).

## 4) Env Vars Required

- **Solidity deploy**: `.env` with `PRIVATE_KEY=<hex>` (used by `script/Deploy.s.sol` via `vm.envUint`).
- **Frontend**: `VITE_WALLETCONNECT_PROJECT_ID` (RainbowKit), `VITE_PINATA_JWT` (Pinata/IPFS).

## 5) Working Directory Conventions

- Solidity/Foundry commands → repo root `/home/srcres/Coding/Learn/dapp-pet-shop-new`
- Frontend commands → `frontend/`

## 6) Canonical Commands

### Solidity (Foundry)

| Command | Directory |
|---|---|
| `forge build` | repo root |
| `forge build --sizes` | repo root |
| `forge test -vvv` | repo root |
| `forge fmt` | repo root |
| `forge fmt --check` | repo root |
| `forge test --match-test "testXxx" -vvv` | repo root |
| `forge test --match-contract "ContractTest" -vvv` | repo root |
| `forge test --match-path "test/File.t.sol" -vvv` | repo root |

Short aliases: `--mt`, `--mc`, `--mp`. Exclusion: `--no-match-test`, `--no-match-contract`, `--no-match-path`.

**⚠️ CRITICAL: There are ZERO Solidity test files in this project.** `forge test` returns "No tests found". If you add new Solidity code, you MUST also write tests. CI runs `forge test -vvv` which would silently pass with no tests.

### Frontend (pnpm)

| Command | Directory |
|---|---|
| `pnpm install` | `frontend/` |
| `pnpm run dev` | `frontend/` |
| `pnpm run build` | `frontend/` |
| `pnpm run lint` | `frontend/` |
| `pnpm run preview` | `frontend/` |

- `pnpm run build` expands to `tsc -b && vite build` (type-check first, then bundle).
- No frontend test runner is configured. Do not invent test commands.

## 7) CI-Backed Commands (from `.github/workflows/test.yml`)

CI sets `FOUNDRY_PROFILE=ci` but no `[profile.ci]` exists in `foundry.toml` → falls back to `default`.

```
forge fmt --check
forge build --sizes
forge test -vvv
```

Ensure these pass locally before finishing Solidity work.

## 8) Local Dev Caveats

### Chain switching
`frontend/src/lib/chains.ts` defines TWO chains: `ephemeryChain` (testnet, id=39438155) and `anvilChain` (local, id=31337).  
`frontend/src/lib/wagmi.tsx` only registers `ephemeryChain`. To develop against local Anvil, you MUST manually edit `wagmi.tsx` to add `anvilChain` to the `chains` array.

### ABI sync workflow
Deployed contract ABIs are stored in `frontend/src/abis/*.json` and imported in `frontend/src/constants.ts`. After deploying new contracts, copy fresh ABIs from `out/` to `frontend/src/abis/` and update `constants.ts` with new addresses.

### Foundry CI profile
`foundry.toml` has no `[profile.ci]` section. CI runs with `FOUNDRY_PROFILE=ci` which defaults to `[profile.default]`. No issue currently, but if you add CI-specific settings, create the profile.

## 9) Solidity Style

Derived from `foundry.toml` and existing contracts in `src/`.

- SPDX + pragma at file top: `// SPDX-License-Identifier: BSD-3-Clause` / `pragma solidity ^0.8.24;`
- Named imports with braces: `import {Trade} from "./Trade.sol";`
- Naming: contracts/events `PascalCase`, functions/variables `camelCase`, internal helpers prefix `_`.
- Always explicit visibility.
- Use NatSpec (`@title`, `@author`, `@notice`, `@dev`) for contracts and non-trivial functions.
- Prefer `uint256` for storage/parameters; `uint` used in existing code for local loop counters (Viewer.sol).
- `require(...)` early with clear revert messages.
- Emit events for externally-triggered state changes.
- Check low-level call success: `(bool success,) = target.call{...}(""); require(success, "...");`
- Run `forge fmt` after every edit.
- Foundry lints excluded: `mixed-case-function`, `mixed-case-variable`. Still use camelCase unless an interface forces otherwise.

## 10) Frontend TypeScript / React Style

- Strict mode (`tsconfig.app.json`: `strict: true`, `noUnusedLocals`, `noUnusedParameters`).
- Avoid `any`. Use explicit types and interfaces.
- Alias imports from `@/` → `frontend/src/` (configured in both `tsconfig.json` and `vite.config.ts`).
- Prefer `type` imports for type-only symbols.
- Function components + hooks. Never call hooks conditionally.
- Side effects in hooks/handlers, not render paths.
- UI primitives in `frontend/src/components/ui/` (shadcn): `button.tsx`, `checkbox.tsx`, `input.tsx`, `label.tsx`, `table.tsx`. Reuse these.
- `cn()` utility from `@/lib/utils` for className merging (clsx + tailwind-merge).
- Never silently swallow errors. Surface failures to UI state.
- Do not mass-reformat unrelated files.

## 11) Error Handling

### Solidity
- Authorization/state checks first via `require`.
- Revert reasons must be precise and user-actionable.

### Frontend
- Never empty catch blocks. Always handle or surface errors.
- Prefer typed error flows over broad untyped catches.

## 12) Vendored / Generated Directories (DO NOT EDIT)

`lib/**`, `out/**`, `cache/**`, `broadcast/**`, `frontend/dist/**`, `frontend/node_modules/**`

## 13) Agent Execution Summary

1. Determine impacted area (Solidity, frontend, or both).
2. Read nearby files; follow existing conventions.
3. Make minimal, surgical edits.
4. Run `forge fmt` after every `.sol` edit.
5. Solidity validation: `forge fmt --check && forge build --sizes && forge test -vvv`
6. Frontend validation: `pnpm run lint && pnpm run build` (from `frontend/`)
7. If adding new Solidity code without tests, state that clearly in your summary.
