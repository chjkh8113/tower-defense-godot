extends Node2D
class_name Tower
## Tower that targets and shoots enemies

var tower_type: String
var damage: int
var attack_range: float
var fire_rate: float
var tower_color: Color

var game_manager: Node2D
var audio_manager: Node
var current_target: Node2D = null
var fire_cooldown: float = 0.0

@onready var sprite: Node2D = $Sprite2D
@onready var base: ColorRect = $Sprite2D/Base
@onready var range_indicator: Node2D = $RangeIndicator
@onready var turret: Node2D = $Turret
@onready var turret_base: ColorRect = $Turret/TurretBase

func setup(type: String, manager: Node2D) -> void:
	tower_type = type
	game_manager = manager

	var config = preload("res://scripts/game_config.gd")
	var tower_config = config.TOWER_CONFIGS[type]

	damage = tower_config.damage
	attack_range = tower_config.range
	fire_rate = tower_config.fire_rate
	tower_color = tower_config.color

func _ready() -> void:
	# Find audio manager
	audio_manager = get_node("/root/Main/AudioManager")

	if base:
		base.color = tower_color.darkened(0.2)
	if turret_base:
		turret_base.color = tower_color

	if range_indicator:
		var scale_factor = attack_range / 100.0
		range_indicator.scale = Vector2(scale_factor, scale_factor)
		range_indicator.visible = false

func _process(delta: float) -> void:
	if not game_manager:
		return

	fire_cooldown -= delta

	if not is_instance_valid(current_target) or not is_target_in_range(current_target):
		current_target = find_best_target()

	if is_instance_valid(current_target):
		var direction = current_target.global_position - global_position
		if turret:
			turret.rotation = direction.angle()

		if fire_cooldown <= 0:
			fire()
			fire_cooldown = 1.0 / fire_rate

func find_best_target() -> Node2D:
	var enemies = game_manager.get_enemies()
	var best_target: Node2D = null
	var best_progress: float = -1

	for enemy in enemies:
		if is_target_in_range(enemy):
			if enemy.progress_ratio > best_progress:
				best_progress = enemy.progress_ratio
				best_target = enemy

	return best_target

func is_target_in_range(target: Node2D) -> bool:
	if not is_instance_valid(target):
		return false
	return global_position.distance_to(target.global_position) <= attack_range

func fire() -> void:
	if not is_instance_valid(current_target):
		return

	game_manager.spawn_projectile(global_position, current_target, damage)

	# Play shoot sound
	if audio_manager:
		audio_manager.play_shoot()

	# Recoil effect
	if turret:
		var tween = create_tween()
		tween.tween_property(turret, "scale", Vector2(0.8, 1.1), 0.05)
		tween.tween_property(turret, "scale", Vector2.ONE, 0.1)

func show_range(show: bool) -> void:
	if range_indicator:
		range_indicator.visible = show
