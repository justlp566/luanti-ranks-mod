# Luanti Ranks

A Luanti chat-ranks mod with colored rank names displayed before player names.

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

Only players with the **Owner** or **Admin** rank can use management commands:

- `/rank_list` — List all available ranks.
- `/rank_set <player> <rank>` — Set a player's rank. Use the rank name exactly as shown by `/rank_list`; spaces can be replaced with underscores.
- `/clear_rank <player>` — Reset a player to Normal Player.
- `/promote <player>` — Promote a player to Helper.

The rank data is saved using Luanti mod storage and survives server restarts. Rank prefixes are colorized in chat to match each rank.

## Installation

1. Copy this folder into your world's `worldmods` directory, or into the server's `mods` directory.
2. Enable the mod in the world configuration.
3. Restart the server.

The mod uses only the standard Luanti Lua API.
