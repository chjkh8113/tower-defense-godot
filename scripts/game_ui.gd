extends CanvasLayer
class_name GameUI
## Main UI coordinator - connects UI modules to game systems

var game_manager: Node2D
var wave_spawner: Node
var build_grid: Node2D
var audio_manager: Node

var header_ui: HeaderUI
var footer_ui: FooterUI
var game_over_ui: GameOverUI

func _ready() -> void:
	game_manager = get_node("../GameManager")
	wave_spawner = get_node("../WaveSpawner")
	build_grid = get_node("../BuildGrid")
	audio_manager = get_node("../AudioManager")

	create_ui_modules()
	connect_signals()

func create_ui_modules() -> void:
	header_ui = HeaderUI.new()
	header_ui.setup(self)

	footer_ui = FooterUI.new()
	footer_ui.setup(self)

	game_over_ui = GameOverUI.new()
	game_over_ui.setup(self)

func connect_signals() -> void:
	# Header UI signals
	header_ui.difficulty_selected.connect(_on_difficulty_selected)
	header_ui.sfx_toggled.connect(_on_sfx_toggled)
	header_ui.music_toggled.connect(_on_music_toggled)

	# Footer UI signals
	footer_ui.tower_selected.connect(_on_tower_selected)
	footer_ui.start_wave_pressed.connect(_on_start_wave_pressed)

	# Game over UI signals
	game_over_ui.continue_pressed.connect(_on_continue_pressed)
	game_over_ui.restart_pressed.connect(_on_restart_pressed)

	# Game manager signals
	if game_manager:
		game_manager.gold_changed.connect(_on_gold_changed)
		game_manager.lives_changed.connect(_on_lives_changed)
		game_manager.game_over.connect(_on_game_over)
		game_manager.difficulty_changed.connect(_on_difficulty_changed)

	# Wave spawner signals
	if wave_spawner:
		wave_spawner.wave_started.connect(_on_wave_started)
		wave_spawner.all_waves_completed.connect(_on_all_waves_completed)
		wave_spawner.boss_spawned.connect(_on_boss_spawned)

func _process(_delta: float) -> void:
	if wave_spawner:
		footer_ui.update_wave_countdown(wave_spawner.get_wave_countdown())

# Header UI handlers
func _on_difficulty_selected(difficulty: String) -> void:
	if game_manager:
		game_manager.set_difficulty(difficulty)

func _on_sfx_toggled() -> void:
	if audio_manager:
		audio_manager.toggle_sfx_mute()
		header_ui.update_sfx_button(audio_manager.sfx_muted)

func _on_music_toggled() -> void:
	if audio_manager:
		audio_manager.toggle_music_mute()
		header_ui.update_music_button(audio_manager.music_muted)

# Footer UI handlers
func _on_tower_selected(tower_type: String) -> void:
	if build_grid:
		build_grid.select_tower_type(tower_type)

func _on_start_wave_pressed() -> void:
	if wave_spawner:
		wave_spawner.skip_wave_countdown()

# Game over UI handlers
func _on_continue_pressed() -> void:
	if wave_spawner:
		wave_spawner.skip_wave_countdown()

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

# Game manager handlers
func _on_gold_changed(amount: int) -> void:
	header_ui.update_gold(amount)

func _on_lives_changed(amount: int) -> void:
	header_ui.update_lives(amount)

func _on_game_over(_won: bool) -> void:
	game_over_ui.show_game_over()

func _on_difficulty_changed(difficulty: String) -> void:
	header_ui.update_difficulty_buttons(difficulty)

# Wave spawner handlers
func _on_wave_started(wave_number: int) -> void:
	header_ui.update_wave(wave_number)

func _on_all_waves_completed() -> void:
	game_over_ui.show_victory()

func _on_boss_spawned(boss: Node) -> void:
	header_ui.show_boss(boss)
