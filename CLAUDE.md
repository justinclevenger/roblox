# Roblox Monorepo

Holding monorepo for Roblox assets, scripts, and knowledge.

## Stack

- **Rojo** — file-based Roblox development; all game code lives as `.lua`/`.luau` files on disk
- **Wally** — package manager for Luau dependencies (`wally.toml`)
- **Roblox Open Cloud API** — publish places and update scripts without Studio UI
- **MCP Server** — Claude Code ↔ Roblox Studio bridge for live game tree inspection

## Project Structure

```
roblox/
├── CLAUDE.md
├── experiences/          # Individual Roblox experiences (games)
│   └── <game-name>/
│       ├── default.project.json   # Rojo project config
│       ├── wally.toml             # Wally dependencies
│       └── src/
│           ├── client/            # StarterPlayerScripts (*.client.lua)
│           ├── server/            # ServerScriptService (*.server.lua)
│           └── shared/            # ReplicatedStorage (modules)
├── packages/             # Shared Luau modules used across experiences
├── assets/               # Models, images, audio references
└── docs/                 # Design docs, game design documents
```

## Rojo File Conventions

| File Pattern | Roblox Instance |
|---|---|
| `*.server.lua` | Script |
| `*.client.lua` | LocalScript |
| `*.lua` / `*.luau` | ModuleScript |
| `init.server.lua` | Parent directory becomes a Script |
| `init.client.lua` | Parent directory becomes a LocalScript |
| `init.lua` | Parent directory becomes a ModuleScript |

## Development Workflow

### Setup
```bash
# Install tooling
cargo install rojo           # or use aftman/foreman
cargo install wally-cli

# Claude Code MCP (macOS)
claude mcp add --transport stdio Roblox_Studio -- \
  '/Applications/RobloxStudioMCP.app/Contents/MacOS/rbx-studio-mcp' --stdio
```

### Day-to-day
1. Write/edit Luau scripts in `experiences/<game>/src/`
2. `rojo serve` in the experience directory — live-syncs to Studio for playtesting
3. `wally install` to pull dependencies into `Packages/`
4. `rojo build -o build.rbxlx` to compile a place file

### Publishing (no Studio UI)
```bash
# Option A: Rojo CLI
rojo build -o game.rbxlx
rojo upload --asset_id <PLACE_ID> --cookie "<ROBLOSECURITY>"

# Option B: Open Cloud API
curl -X POST \
  "https://apis.roblox.com/universes/v1/{universeId}/places/{placeId}/versions" \
  -H "x-api-key: <API_KEY>" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @game.rbxlx
```

### Open Cloud Engine API (Beta)
- Read/update Script, LocalScript, ModuleScript source in running experiences via REST
- Execute Luau remotely against a running place
- Useful for hot-patching live games without republishing

## Coding Conventions

- Access services via `game:GetService("ServiceName")` — never direct property access
- Services listed alphabetically at top of file
- One module per file; keep modules focused and small
- `shared/` for anything needed by both client and server
- Use strict Luau typing where possible (`--!strict`)
- Prefer signals/events over polling

## Claude Code Guidelines

- Read existing scripts before modifying — understand the game's architecture first
- Keep codebases modular; split large scripts into focused modules
- When generating Luau, match the style of surrounding code
- Always use Rojo file conventions (`.server.lua`, `.client.lua`, etc.)
- Back up or git-commit before large rewrites
- If the MCP server is connected, inspect the game tree to understand context
- Test changes via `rojo serve` + Studio before publishing
