extends Node
## Central configuration for all game balance values

# UI Layout
const HEADER_HEIGHT := 60
const FOOTER_HEIGHT := 80
const GAME_AREA_TOP := 60
const GAME_AREA_BOTTOM := 640  # 720 - 80

# Grid settings
const CELL_SIZE := 64
const GRID_WIDTH := 20  # 1280 / 64 = 20
const GRID_HEIGHT := 9  # (640 - 60) / 64 = ~9

# Player settings
const STARTING_GOLD := 100
const STARTING_LIVES := 20

# Tower settings
const TOWER_CONFIGS := {
	"basic": {
		"name": "Basic Tower",
		"cost": 50,
		"damage": 10,
		"range": 150.0,
		"fire_rate": 1.0,
		"color": Color(0.2, 0.6, 1.0)
	},
	"sniper": {
		"name": "Sniper Tower",
		"cost": 100,
		"damage": 50,
		"range": 300.0,
		"fire_rate": 0.5,
		"color": Color(0.8, 0.2, 0.2)
	},
	"rapid": {
		"name": "Rapid Tower",
		"cost": 75,
		"damage": 5,
		"range": 120.0,
		"fire_rate": 4.0,
		"color": Color(0.2, 0.8, 0.2)
	}
}

# Enemy settings
const ENEMY_CONFIGS := {
	"basic": {
		"name": "Basic Enemy",
		"health": 50,
		"speed": 80.0,
		"gold_reward": 10,
		"color": Color(1.0, 0.4, 0.4),
		"is_boss": false,
		"damage_reduction": 0.0
	},
	"fast": {
		"name": "Fast Enemy",
		"health": 30,
		"speed": 150.0,
		"gold_reward": 15,
		"color": Color(1.0, 1.0, 0.4),
		"is_boss": false,
		"damage_reduction": 0.0
	},
	"tank": {
		"name": "Tank Enemy",
		"health": 200,
		"speed": 40.0,
		"gold_reward": 30,
		"color": Color(0.6, 0.4, 0.8),
		"is_boss": false,
		"damage_reduction": 0.0
	},
	"boss": {
		"name": "BOSS",
		"health": 1000,
		"speed": 25.0,
		"gold_reward": 100,
		"color": Color(0.9, 0.1, 0.9),
		"is_boss": true,
		"damage_reduction": 0.5,
		"size_scale": 2.0
	}
}

# Wave settings
const WAVE_DELAY := 5.0
const SPAWN_INTERVAL := 0.8

# Difficulty settings
const DIFFICULTY_CONFIGS := {
	"easy": {
		"name": "Easy",
		"gold_multiplier": 1.5,
		"damage_multiplier": 1.5,
		"color": Color(0.3, 0.8, 0.3)
	},
	"normal": {
		"name": "Normal",
		"gold_multiplier": 1.0,
		"damage_multiplier": 1.0,
		"color": Color(0.8, 0.8, 0.3)
	},
	"hard": {
		"name": "Hard",
		"gold_multiplier": 0.6,
		"damage_multiplier": 0.6,
		"color": Color(0.8, 0.3, 0.3)
	}
}
const DEFAULT_DIFFICULTY := "normal"
