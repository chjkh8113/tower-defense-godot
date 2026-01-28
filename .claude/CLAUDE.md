# Tower Defense Project Guidelines

## Code Quality Rules

- **No god files** - Keep all files under 300 lines of code
- If a file exceeds 300 lines, break it down into smaller, focused modules
- Each file should have a single responsibility

## Project Structure

- `scripts/` - GDScript game logic
- `scenes/` - Godot scene files (.tscn)
- `game_config.gd` - Central configuration for all game balance values

## Architecture

- Use signals for communication between nodes
- Keep game balance values in `game_config.gd`
- UI is created dynamically in `game_ui.gd`
