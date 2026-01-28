extends Area2D
class_name Projectile
## Projectile that moves towards a target and deals damage

var target: Node2D
var damage: int
var speed: float = 400.0

func setup(from: Vector2, target_enemy: Node2D, dmg: int) -> void:
	global_position = from
	target = target_enemy
	damage = dmg

func _process(delta: float) -> void:
	if not is_instance_valid(target):
		queue_free()
		return

	var direction = (target.global_position - global_position).normalized()
	rotation = direction.angle()
	position += direction * speed * delta

	# Check if we reached the target
	if global_position.distance_to(target.global_position) < 10:
		hit_target()

func hit_target() -> void:
	if is_instance_valid(target) and target.has_method("take_damage"):
		target.take_damage(damage)

	# Small explosion effect
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.1)
	tween.tween_callback(queue_free)
