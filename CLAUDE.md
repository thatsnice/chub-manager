# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

chub-manager provides a web-based management interface for chub.ai, helping creators manage large collections of characters and content.

## Commands

```bash
npm start          # Run the Express server (port 3000)
npx coffee         # CoffeeScript REPL
```

## Architecture

```
src/index.coffee   # Express server with API proxy endpoints
public/index.html  # Single-page web UI
```

The server acts as a proxy to the chub.ai API, forwarding the user's `CH-API-KEY` from the `X-Chub-API-Key` request header.

## Chub.ai API

- **Base URL:** https://api.chub.ai
- **Docs:** https://api.chub.ai/docs (Swagger UI)
- **Auth:** `CH-API-KEY` header

Key endpoints:
- `GET /search` - Search characters
- `GET /api/users/{username}` - User's projects
- `GET /api/characters/{creator}/{name}` - Get character
- `PUT /api/core/characters/{creator}/{name}` - Update character

## Technology Stack

- CoffeeScript 2.7+
- Express 5
- Node.js (CommonJS)
