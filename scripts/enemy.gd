extends PathFollow2D
class_name Enemy
## Enemy that follows a path and can be damaged

signal died(gold_reward: int)
signal reached_end()

var enemy_type: String
var max_health: int
var health: int
var speed: float
var gold_reward: int
var enemy_color: Color
var wave_number: int = 1
var audio_manager: Node
var game_manager: Node = null
var is_boss: bool = false
var damage_reduction: float = 0.0

@onready var body: ColorRect = $Sprite2D/Body
@onready var health_bar: ProgressBar = $HealthBar

func setup(type: String, wave: int = 1, manager: Node = null) -> void:
	enemy_type = type
	wave_number = wave
	game_manager = manager

	var config = preload("res://scripts/game_config.gd")
	var enemy_config = config.ENEMY_CONFIGS[type]

	is_boss = enemy_config.get("is_boss", false)
	damage_reduction = enemy_config.get("damage_reduction", 0.0)

	var health_multiplier = 1.0 + (wave_number - 1) * 0.25
	if is_boss:
		health_multiplier = 1.0 + (wave_number - 1) * 0.5
	max_health = int(enemy_config.health * health_multiplier)
	health = max_health

	var speed_multiplier = 1.0 + (wave_number - 1) * 0.05
	if is_boss:
		speed_multiplier = 1.0
	speed = enemy_config.speed * speed_multiplier

	var gold_multiplier = 1.0 + (wave_number - 1) * 0.1
	gold_reward = int(enemy_config.gold_reward * gold_multiplier)

	enemy_color = enemy_config.color

	if is_boss:
		var size_scale = enemy_config.get("size_scale", 2.0)
		scale = Vector2(size_scale, size_scale)

	progress = 0

func _ready() -> void:
	audio_manager = get_node("/root/Main/AudioManager")
	if not game_manager:
		game_manager = get_node("/root/Main/GameManager")

	if body:
		body.color = enemy_color

	update_health_bar()

func _process(delta: float) -> void:
	progress += speed * delta

	if progress_ratio >= 1.0:
		reached_end.emit()
		queue_free()

func take_damage(amount: int) -> void:
	var difficulty_multiplier = 1.0
	if game_manager and game_manager.has_method("get_damage_multiplier"):
		difficulty_multiplier = game_manager.get_damage_multiplier()

	var actual_damage = int(amount * difficulty_multiplier * (1.0 - damage_reduction))
	if actual_damage < 1:
		actual_damage = 1

	health -= actual_damage
	update_health_bar()

	if audio_manager:
		audio_manager.play_hit()

	if body:
		var original_color = enemy_color
		var tween = create_tween()
		tween.tween_property(body, "color", Color.WHITE, 0.05)
		tween.tween_property(body, "color", original_color, 0.1)

	if health <= 0:
		die()

func update_health_bar() -> void:
	if health_bar:
		health_bar.value = float(health) / float(max_health) * 100

func die() -> void:
	if audio_manager:
		audio_manager.play_death()

	died.emit(gold_reward)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.tween_callback(queue_free)
