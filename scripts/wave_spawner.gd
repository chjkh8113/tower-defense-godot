extends Node
class_name WaveSpawner
## Handles spawning waves of enemies

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal all_waves_completed()

var enemy_path: Path2D
var game_manager: Node2D

var current_wave: int = 0
var enemies_to_spawn: Array = []
var spawn_timer: float = 0.0
var wave_in_progress: bool = false
var between_waves: bool = true
var between_wave_timer: float = 0.0
var endless_mode: bool = false
var victory_shown: bool = false

# Wave definitions - enemy count increases each wave
var waves := [
	["basic", "basic", "basic", "basic", "basic"],
	["basic", "basic", "basic", "basic", "basic", "basic", "basic"],
	["basic", "fast", "basic", "fast", "basic", "fast"],
	["basic", "basic", "fast", "fast", "basic", "basic", "fast", "fast"],
	["basic", "basic", "tank", "basic", "basic", "tank", "basic"],
	["fast", "fast", "fast", "fast", "fast", "fast", "fast", "fast", "fast", "fast"],
	["tank", "basic", "basic", "tank", "basic", "basic", "tank", "tank"],
	["fast", "basic", "tank", "fast", "basic", "tank", "fast", "basic", "tank", "fast"],
	["fast", "fast", "fast", "fast", "basic", "basic", "basic", "basic", "tank", "tank", "tank", "tank"],
	["tank", "tank", "tank", "tank", "fast", "fast", "fast", "fast", "basic", "basic", "basic", "basic", "tank", "tank", "tank"],
]

func _ready() -> void:
	enemy_path = get_node("../EnemyPath")
	game_manager = get_node("../GameManager")

	var config = preload("res://scripts/game_config.gd")
	between_wave_timer = config.WAVE_DELAY

func _process(delta: float) -> void:
	if not game_manager or game_manager.is_game_over:
		return

	if victory_shown and not endless_mode:
		return

	if between_waves:
		between_wave_timer -= delta
		if between_wave_timer <= 0:
			start_next_wave()
		return

	if wave_in_progress:
		spawn_timer -= delta
		if spawn_timer <= 0 and enemies_to_spawn.size() > 0:
			spawn_next_enemy()

		if enemies_to_spawn.size() == 0 and game_manager.get_enemies().size() == 0:
			wave_completed.emit(current_wave)
			wave_in_progress = false
			between_waves = true
			var config = preload("res://scripts/game_config.gd")
			between_wave_timer = config.WAVE_DELAY

			if current_wave >= waves.size() and not victory_shown:
				victory_shown = true
				all_waves_completed.emit()

func start_next_wave() -> void:
	if current_wave >= waves.size():
		enemies_to_spawn = generate_endless_wave(current_wave)
	else:
		enemies_to_spawn = waves[current_wave].duplicate()

	current_wave += 1

	# Add boss every 2 waves (wave 2, 4, 6, 8, 10, ...)
	if current_wave % 2 == 0:
		enemies_to_spawn.append("boss")

	wave_in_progress = true
	between_waves = false
	wave_started.emit(current_wave)

	if endless_mode:
		print("Endless Wave ", current_wave, " started! Enemies: ", enemies_to_spawn.size())
	else:
		print("Wave ", current_wave, " started! Enemies: ", enemies_to_spawn.size())

func spawn_next_enemy() -> void:
	if enemies_to_spawn.size() == 0:
		return

	var enemy_type = enemies_to_spawn.pop_front()
	var enemy = game_manager.spawn_enemy(enemy_type, enemy_path, current_wave)

	if enemy and enemy_type == "boss":

	var config = preload("res://scripts/game_config.gd")
	var spawn_speed = config.SPAWN_INTERVAL
	if enemy_type == "boss":
		spawn_speed = 2.0
	else:
		spawn_speed = config.SPAWN_INTERVAL * max(0.5, 1.0 - current_wave * 0.05)
	spawn_timer = spawn_speed

func generate_endless_wave(wave_num: int) -> Array:
	var wave = []
	var count = 10 + wave_num * 3
	var types = ["basic", "fast", "tank"]

	for i in count:
		var type_index = randi() % types.size()
		if randf() < 0.15 * (wave_num - 9):
			type_index = 2
		wave.append(types[type_index])

	# Endless mode also gets boss every 2 waves
	# Boss is added in start_next_wave()

	return wave

func get_wave_countdown() -> float:
	if between_waves:
		return between_wave_timer
	return 0.0

func skip_wave_countdown() -> void:
	if between_waves:
		between_wave_timer = 0.0
	if victory_shown:
		endless_mode = true
		print("Endless mode activated!")
