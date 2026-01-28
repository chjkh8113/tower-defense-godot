extends Node2D
class_name BuildGrid
## Grid for placing towers

signal tower_placed(position: Vector2, tower_type: String)

var game_manager: Node2D
var map_generator: Node2D
var config = preload("res://scripts/game_config.gd")

var selected_tower_type: String = "basic"
var ghost_tower: ColorRect
var occupied_cells: Dictionary = {}

func _ready() -> void:
	game_manager = get_node("../GameManager")
	map_generator = get_node("../MapGenerator")

	ghost_tower = ColorRect.new()
	ghost_tower.size = Vector2(48, 48)
	ghost_tower.color = Color(1, 1, 1, 0.5)
	ghost_tower.visible = true
	ghost_tower.z_index = 10
	add_child(ghost_tower)

	var tower_config = config.TOWER_CONFIGS[selected_tower_type]
	ghost_tower.color = tower_config.color
	ghost_tower.color.a = 0.5

func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()

	# Hide ghost tower if outside game area
	if not is_in_game_area(mouse_pos):
		ghost_tower.visible = false
		return

	ghost_tower.visible = true
	var cell = world_to_cell(mouse_pos)
	var cell_center = cell_to_world(cell)

	ghost_tower.position = cell_center - ghost_tower.size / 2

	var can_build = is_cell_buildable(cell)
	if can_build:
		var tower_config = config.TOWER_CONFIGS[selected_tower_type]
		ghost_tower.color = tower_config.color
		ghost_tower.color.a = 0.5
	else:
		ghost_tower.color = Color(1, 0, 0, 0.5)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_pos = get_global_mouse_position()
			# Only allow placement in game area (between header and footer)
			if is_in_game_area(mouse_pos):
				try_place_tower()

func is_in_game_area(pos: Vector2) -> bool:
	return pos.y >= config.GAME_AREA_TOP and pos.y < config.GAME_AREA_BOTTOM

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

func try_place_tower() -> void:
	if not game_manager:
		print("No game manager!")
		return

	var mouse_pos = get_global_mouse_position()
	var cell = world_to_cell(mouse_pos)

	if not is_cell_buildable(cell):
		print("Cell not buildable: ", cell)
		return

	var cell_center = cell_to_world(cell)

	if game_manager.spawn_tower(selected_tower_type, cell_center):
		occupied_cells[cell] = true
		tower_placed.emit(cell_center, selected_tower_type)
		print("Tower placed at: ", cell_center)
	else:
		print("Not enough gold!")

func is_cell_buildable(cell: Vector2i) -> bool:
	# Check bounds
	if cell.x < 0 or cell.x >= config.GRID_WIDTH:
		return false
	if cell.y < 0 or cell.y >= config.GRID_HEIGHT:
		return false

	if occupied_cells.has(cell):
		return false

	if map_generator:
		return map_generator.is_cell_buildable(cell)

	return true

func select_tower_type(type: String) -> void:
	selected_tower_type = type
	if config.TOWER_CONFIGS.has(type):
		var tower_config = config.TOWER_CONFIGS[type]
		ghost_tower.color = tower_config.color
		ghost_tower.color.a = 0.5
		print("Selected tower: ", type)
