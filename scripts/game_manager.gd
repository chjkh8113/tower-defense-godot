extends Node2D
class_name GameManager
## Main game controller - handles state, gold, lives, waves

signal gold_changed(new_amount: int)
signal lives_changed(new_amount: int)
signal wave_started(wave_number: int)
signal game_over(won: bool)
signal difficulty_changed(difficulty: String)

@onready var enemy_container: Node2D = $EnemyContainer
@onready var tower_container: Node2D = $TowerContainer
@onready var projectile_container: Node2D = $ProjectileContainer

var config = preload("res://scripts/game_config.gd")

var gold: int = 0
var lives: int = 0
var current_wave: int = 0
var is_game_over: bool = false
var current_difficulty: String = "normal"

var enemy_scene: PackedScene
var tower_scene: PackedScene
var projectile_scene: PackedScene

func _ready() -> void:
	enemy_scene = preload("res://scenes/enemy.tscn")
	tower_scene = preload("res://scenes/tower.tscn")
	projectile_scene = preload("res://scenes/projectile.tscn")
	current_difficulty = config.DEFAULT_DIFFICULTY
	start_game()

func start_game() -> void:
	gold = config.STARTING_GOLD
	lives = config.STARTING_LIVES
	current_wave = 0
	is_game_over = false
	gold_changed.emit(gold)
	lives_changed.emit(lives)

func set_difficulty(difficulty: String) -> void:
	if config.DIFFICULTY_CONFIGS.has(difficulty):
		current_difficulty = difficulty
		difficulty_changed.emit(difficulty)

func get_difficulty_config() -> Dictionary:
	return config.DIFFICULTY_CONFIGS[current_difficulty]

func get_gold_multiplier() -> float:
	return get_difficulty_config().gold_multiplier

func get_damage_multiplier() -> float:
	return get_difficulty_config().damage_multiplier

func add_gold(amount: int) -> void:
	var adjusted_amount = int(amount * get_gold_multiplier())
	gold += adjusted_amount
	gold_changed.emit(gold)

func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		gold_changed.emit(gold)
		return true
	return false

func lose_life(amount: int = 1) -> void:
	if is_game_over:
		return
	lives -= amount
	lives_changed.emit(lives)
	if lives <= 0:
		lives = 0
		is_game_over = true
		game_over.emit(false)

func spawn_enemy(enemy_type: String, path: Path2D, wave: int) -> Node:
	var enemy = enemy_scene.instantiate()
	enemy.setup(enemy_type, wave, self)
	enemy.died.connect(_on_enemy_died)
	enemy.reached_end.connect(_on_enemy_reached_end)
	path.add_child(enemy)
	return enemy

func spawn_tower(tower_type: String, pos: Vector2) -> bool:
	var tower_config = config.TOWER_CONFIGS[tower_type]

	if not spend_gold(tower_config.cost):
		return false

	var tower = tower_scene.instantiate()
	tower.setup(tower_type, self)
	tower.position = pos
	tower_container.add_child(tower)
	return true

func spawn_projectile(from: Vector2, target: Node2D, damage: int) -> void:
	var projectile = projectile_scene.instantiate()
	projectile.setup(from, target, damage)
	projectile_container.add_child(projectile)

func _on_enemy_died(gold_reward: int) -> void:
	add_gold(gold_reward)

func _on_enemy_reached_end() -> void:
	lose_life()

func get_enemies() -> Array[Node]:
	var path = get_node("../EnemyPath")
	if path:
		return path.get_children()
	return []
