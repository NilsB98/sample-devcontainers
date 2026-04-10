# Google Stitch MCP Setup

## Adding Google Stitch MCP to Claude Code

```bash
claude mcp add stitch https://stitch.googleapis.com/mcp -t http -H "X-Goog-Api-Key: <YOUR_API_KEY>"
```

**Key syntax note**: Positional args (`name` and `url`) must come **before** the flags (`-t`, `-H`). Putting flags before the name causes a "missing required argument" error.

- **Endpoint**: `https://stitch.googleapis.com/mcp`
- **Transport**: HTTP
- **Auth**: Via `X-Goog-Api-Key` header
- **Stored in**: `~/.claude.json` (local scope by default)
