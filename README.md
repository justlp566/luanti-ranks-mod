# Luanti Ranks

A complete Luanti chat-rank system with colored rank names displayed before player names and on player nametags.

## Features

- Colored rank prefixes in chat
- Colored nametags displayed above players
- Default rank assignment on first join
- Persistent rank storage across server restarts
- Owner/Admin-only rank management commands
- Support for `rank_admin` privilege
- Configurable rank names and colors
- Robust error handling and validation

## Ranks

- Normal Player (default)
- Helper
- Moderator
- VIP
- Millionaire
- Billionaire
- Trillionaire
- Admin
- Owner

## Commands

Only players with the **Owner** or **Admin** rank, or those with the `rank_admin` privilege, can use these commands:

- `/rank_list` — List all available ranks and their colors.
- `/rank_set <player> <rank>` — Set a player's rank. Rank name can include spaces or underscores; the mod normalizes the input.
- `/clear_rank <player>` — Reset a player to Normal Player.
- `/promote <player>` — Promote a player to Helper.

## Configuration

Edit `config.lua` to customize rank names, colors, or add new ranks. The mod will automatically read the new configuration on the next server start.

## Installation

1. Copy this folder into your world's `worldmods` directory, or into the server's `mods` directory.
2. Enable the mod in the world configuration.
3. Restart the server.

The mod uses only the standard Luanti Lua API.

## Permissions

Rank management checks work in this order:
1. `rank_admin` privilege
2. `server` privilege (superuser)
3. Player's rank (Owner or Admin)

Any of these grants access to rank commands.
