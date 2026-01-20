# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

chub-manager provides a web-based management interface for chub.ai, helping creators manage large collections of characters and content. Key features:
- Load and browse all your characters
- Client-side filtering by tags (include/exclude) and text search
- Sorting by name, date, popularity, tokens
- Bulk tag operations (add/remove tags to multiple characters)
- Edit character details (name, personality, first message, etc.)

## Commands

```bash
npm start          # Run the Express server (port 3000)
npx coffee         # CoffeeScript REPL
```

## Architecture

```
src/index.coffee   # Express server with API proxy endpoints
public/index.html  # Single-page web UI (vanilla JS)
logs/              # API response logs for debugging (gitignored)
```

The server proxies requests to the chub.ai API, forwarding the user's API key from the `X-Chub-API-Key` request header as `CH-API-KEY`.

## Chub.ai API

- **Base URL:** https://api.chub.ai
- **Docs:** https://api.chub.ai/docs (Swagger UI)
- **OpenAPI:** https://api.chub.ai/openapi.json
- **Auth:** `CH-API-KEY` header (user's `MARS_TOKEN` from localStorage on chub.ai)

Key endpoints:
- `GET /api/users/{username}` - User's projects (use `?full=true` for definitions)
- `GET /api/characters/{creator}/{name}?full=true` - Get character with full definition
- `PUT /api/core/characters/{creator}/{name}` - Update character
- `POST /api/tags/{project_id}/{tagname}` - Add tag
- `DELETE /api/tags/{project_id}/{tagname}` - Remove tag
- `GET /search` - Search (note: doesn't reliably find user's own characters)

## Technology Stack

- CoffeeScript 2.7+
- Express 5
- Node.js (CommonJS)
- Vanilla JS frontend (no build step)
