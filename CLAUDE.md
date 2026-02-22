# Roblox Monorepo

Monorepo for Roblox experiences, shared packages, assets, and docs.

## Toolchain

All tools managed via [Rokit](https://github.com/rojo-rbx/rokit) (`rokit.toml`):

| Tool | Version | Purpose |
|---|---|---|
| `rojo` | 7.6.1 | File-system ↔ Roblox sync, builds `.rbxl` place files |
| `wally` | 0.3.2 | Package manager for Luau dependencies |
| `selene` | 0.30.0 | Luau linter (`selene.toml` at repo root) |
| `stylua` | 2.3.1 | Luau formatter (`.stylua.toml` at repo root) |
| `lune` | 0.10.4 | Standalone Luau runtime for build scripts and testing |
| `rbxcloud` | 0.17.0 | Open Cloud CLI for publishing, datastores, messaging |
| `luau-lsp` | 1.62.0 | Language server and CLI type checker |

Install all tools: `rokit install`

## Project Structure

```
roblox/
├── CLAUDE.md                    # This file
├── rokit.toml                   # Toolchain versions
├── selene.toml                  # Linter config (std = "roblox")
├── .stylua.toml                 # Formatter config
├── .gitignore
├── scripts/                     # Build, lint, publish scripts
│   ├── build.sh                 # Build one or all experiences
│   ├── lint.sh                  # Lint + format check (--fix to auto-format)
│   └── publish.sh               # Publish via Open Cloud API
├── experiences/                 # Individual Roblox experiences
│   └── <game-name>/
│       ├── default.project.json # Rojo project config
│       ├── wally.toml           # Per-experience dependencies
│       └── src/
│           ├── server/          # ServerScriptService (*.server.luau)
│           ├── client/          # StarterPlayerScripts (*.client.luau)
│           └── shared/          # ReplicatedStorage (*.luau modules)
├── packages/                    # Shared Luau modules across experiences
├── assets/                      # Models, images, audio references
└── docs/                        # Design docs, GDDs
```

## Rojo File Conventions

| File Pattern | Roblox Instance |
|---|---|
| `*.server.luau` | Script (runs on server) |
| `*.client.luau` | LocalScript (runs on client) |
| `*.luau` | ModuleScript |
| `init.server.luau` | Parent directory becomes a Script |
| `init.client.luau` | Parent directory becomes a LocalScript |
| `init.luau` | Parent directory becomes a ModuleScript |
| `*.model.json` | Custom instance definitions |
| `*.meta.json` | Metadata overlay for sibling file |

## Workflows

### Autonomous (CLI-only, no Studio)

The full development loop runs entirely from the command line:

```bash
# 1. Write/edit .luau files in experiences/<game>/src/
# 2. Install dependencies
cd experiences/<game> && wally install

# 3. Lint + format
selene experiences/<game>/src/
stylua experiences/<game>/src/

# 4. Type check (optional)
cd experiences/<game> && rojo sourcemap -o sourcemap.json
luau-lsp analyze --sourcemap sourcemap.json src/

# 5. Build place file
rojo build -o ../../build/<game>.rbxl

# 6. Publish (requires ROBLOX_API_KEY env var)
rbxcloud place publish \
  --universe-id $UNIVERSE_ID \
  --place-id $PLACE_ID \
  --filepath build/<game>.rbxl \
  --publish-type published \
  --api-key $ROBLOX_API_KEY
```

Or use the helper scripts:
```bash
./scripts/lint.sh              # Lint + format check all code
./scripts/lint.sh --fix        # Lint + auto-format
./scripts/build.sh <game>      # Build one experience
./scripts/build.sh             # Build all experiences
./scripts/publish.sh <game> <universe-id> <place-id>  # Publish
```

### Hybrid (Claude Code + Roblox Studio via MCP)

Two MCP servers are configured for Studio interaction:

**Official Roblox MCP** (`Roblox_Studio`) — 6 tools:
- `run_code` — Execute Luau in Studio
- `insert_model` — Insert instances into the game tree
- `get_console_output` — Read Studio console/output
- `start_stop_play` — Start/stop playtesting
- `run_script_in_play_mode` — Execute during playtest
- `get_studio_mode` — Check if in Edit or Play mode

**Community MCP** (`robloxstudio-community`) — 37+ tools:
- Game structure exploration, script read/edit, bulk operations
- Selection tools, property/attribute manipulation
- Playtest automation with console monitoring

Hybrid workflow:
```bash
# 1. Start Roblox Studio with the MCP plugin enabled
# 2. Claude Code connects via MCP servers automatically
# 3. Write code in filesystem, live-sync with:
cd experiences/<game> && rojo serve
# 4. Use MCP tools to inspect game tree, run playtests, debug
# 5. Build + publish when ready
```

## Luau Coding Conventions

- Use `--!strict` at top of every file
- Use `.luau` extension (not `.lua`)
- Access services via `game:GetService("ServiceName")` — list alphabetically at top
- One module per file, keep modules focused and small
- Use Luau type annotations: `local x: number = 5`
- Use string interpolation: `` `Hello {name}!` ``
- Use generalized iteration: `for k, v in table do` (no `pairs()`/`ipairs()`)
- Use compound assignments: `x += 1`
- Use `task.wait()`, `task.spawn()`, `task.defer()` — never bare `wait()`
- Prefix unused parameters with `_` (e.g., `_character`)

## Architecture Principles

- **Server is authoritative**: All game state mutations validated server-side
- **Never trust the client**: Validate every RemoteEvent argument (type, range, legitimacy)
- **Rate-limit remotes**: Track fire frequency per player, reject excess
- **Wrap DataStore calls in pcall**: They can fail due to network/rate limits
- **Save on PlayerRemoving + game:BindToClose**: Catch both normal leave and server shutdown
- **Use UpdateAsync over SetAsync**: Prevents race conditions with concurrent writes
- **Keep payloads small**: Don't send huge tables across the network boundary

## Creating a New Experience

```bash
# 1. Create directory structure
mkdir -p experiences/<game>/src/{server,client,shared}

# 2. Copy template project files
cp experiences/template/default.project.json experiences/<game>/
cp experiences/template/wally.toml experiences/<game>/

# 3. Edit default.project.json — update "name" field
# 4. Edit wally.toml — update package name
# 5. Create entry points:
#    src/server/init.server.luau
#    src/client/init.client.luau

# 6. Build to verify
cd experiences/<game> && rojo build -o ../../build/<game>.rbxl
```

## Programmatic World Building

Everything in Roblox can be created via code — no Studio GUI needed:

```luau
-- Parts
local part = Instance.new("Part")
part.Size = Vector3.new(10, 1, 10)
part.Position = Vector3.new(0, 5, 0)
part.Anchored = true
part.Material = Enum.Material.Neon
part.Color = Color3.fromRGB(255, 0, 0)
part.Parent = workspace

-- Models (grouping)
local model = Instance.new("Model")
model.Name = "House"
model.PrimaryPart = floor
model.Parent = workspace

-- UI (from LocalScript)
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

-- Constraints, Welds, Sounds, Lights — all via Instance.new()
```

Use `default.project.json` `$properties` for static world setup (baseplate, spawn, lighting).
Use server scripts for dynamic/procedural generation.

## Common Wally Packages

```toml
[dependencies]
Promise = "evaera/promise@^4.0"        # Async promises
Signal = "sleitnick/signal@^2.0"       # Custom signals
Trove = "sleitnick/trove@^1.1"         # Cleanup/lifecycle management
TableUtil = "sleitnick/table-util@^1.2" # Table utilities
```

## Testing

- **Lint**: `selene src/` catches common errors, deprecated APIs, unused variables
- **Format**: `stylua --check src/` enforces consistent style
- **Type check**: `luau-lsp analyze --sourcemap sourcemap.json src/`
- **Unit tests**: Use `*.spec.luau` files alongside modules (excluded from builds via `globIgnorePaths`)
- **Integration tests**: Build `.rbxl` → upload to test place → execute via Open Cloud Luau Execution API
- **Playtest via MCP**: Start/stop play sessions, read console output, iterate

## Open Cloud API

Set `ROBLOX_API_KEY` env var. Key operations:

```bash
# Publish a place
rbxcloud place publish --universe-id ID --place-id ID --filepath game.rbxl --publish-type published --api-key $KEY

# DataStore operations
rbxcloud datastore list-stores --universe-id ID --api-key $KEY
rbxcloud datastore get --datastore-name NAME --key KEY --universe-id ID --api-key $KEY
rbxcloud datastore set --datastore-name NAME --key KEY --data '{}' --universe-id ID --api-key $KEY

# Messaging (to running servers)
rbxcloud messaging publish --topic TOPIC --message MSG --universe-id ID --api-key $KEY
```

## Claude Code Guidelines

- Read existing scripts before modifying — understand the game's architecture first
- Keep codebases modular; split large scripts into focused modules
- When generating Luau, match the style of surrounding code
- Always use Rojo file conventions (`.server.luau`, `.client.luau`, etc.)
- Run `selene` and `stylua --check` after writing code
- Build with `rojo build` to verify project compiles
- If MCP servers are connected, inspect the game tree to understand context before modifying
- Back up or git-commit before large rewrites
