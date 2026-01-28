extends Node2D
class_name MapGenerator
## Generates the game map visually with path and buildable areas

var enemy_path: Path2D
var config = preload("res://scripts/game_config.gd")

var path_cells: Array[Vector2i] = []
var buildable_cells: Array[Vector2i] = []

func _ready() -> void:
	enemy_path = get_node("../EnemyPath")
	generate_map()

func generate_map() -> void:
	if enemy_path and enemy_path.curve:
		calculate_path_cells()
	draw_map()

func calculate_path_cells() -> void:
	path_cells.clear()
	var curve = enemy_path.curve

	var length = curve.get_baked_length()
	var step = config.CELL_SIZE / 2.0

	for d in range(0, int(length), int(step)):
		var point = curve.sample_baked(d)
		var cell = world_to_cell(point)
		if cell.y >= 0 and cell.y < config.GRID_HEIGHT:
			if not path_cells.has(cell):
				path_cells.append(cell)

func world_to_cell(world_pos: Vector2) -> Vector2i:
	var local_y = world_pos.y - config.GAME_AREA_TOP
	return Vector2i(
		int(world_pos.x / config.CELL_SIZE),
		int(local_y / config.CELL_SIZE)
	)

func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(
		cell.x * config.CELL_SIZE + config.CELL_SIZE / 2,
		cell.y * config.CELL_SIZE + config.CELL_SIZE / 2 + config.GAME_AREA_TOP
	)

func draw_map() -> void:
	for x in range(config.GRID_WIDTH):
		for y in range(config.GRID_HEIGHT):
			var cell = Vector2i(x, y)
			var rect = ColorRect.new()
			rect.size = Vector2(config.CELL_SIZE - 2, config.CELL_SIZE - 2)
			rect.position = Vector2(
				x * config.CELL_SIZE + 1,
				y * config.CELL_SIZE + 1 + config.GAME_AREA_TOP
			)

			if path_cells.has(cell):
				rect.color = Color(0.4, 0.3, 0.2, 1.0)
			else:
				rect.color = Color(0.2, 0.35, 0.25, 1.0)
				buildable_cells.append(cell)

			add_child(rect)

	draw_path_line()

func draw_path_line() -> void:
	if not enemy_path or not enemy_path.curve:
		return

	var line = Line2D.new()
	line.width = 8
	line.default_color = Color(0.5, 0.4, 0.3, 0.8)
	line.z_index = 1

	var curve = enemy_path.curve
	var length = curve.get_baked_length()

	for d in range(0, int(length), 10):
		var point = curve.sample_baked(d)
		line.add_point(point)

	line.add_point(curve.sample_baked(length))
	add_child(line)

func is_cell_buildable(cell: Vector2i) -> bool:
	if cell.y < 0 or cell.y >= config.GRID_HEIGHT:
		return false
	if cell.x < 0 or cell.x >= config.GRID_WIDTH:
		return false
	return buildable_cells.has(cell) and not path_cells.has(cell)

func get_cell_center(cell: Vector2i) -> Vector2:
	return cell_to_world(cell)
