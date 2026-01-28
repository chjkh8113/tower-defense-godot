extends CanvasLayer
class_name GameUI
## Handles all UI elements with proper HUD layout

var game_manager: Node2D
var wave_spawner: Node
var build_grid: Node2D
var audio_manager: Node
var config = preload("res://scripts/game_config.gd")

# UI Elements
var header_panel: Panel
var footer_panel: Panel
var gold_label: Label
var lives_label: Label
var wave_label: Label
var tower_buttons: HBoxContainer
var game_over_panel: Panel
var game_over_label: Label
var next_wave_button: Button
var wave_timer_label: Label
var continue_button: Button
var restart_button: Button
var sfx_button: Button
var music_button: Button

# Boss health bar
var boss_container: Control
var boss_label: Label
var boss_health_bar: ProgressBar
var current_boss: Node = null

# Difficulty buttons
var difficulty_buttons: Dictionary = {}
var difficulty_container: HBoxContainer

func _ready() -> void:
	game_manager = get_node("../GameManager")
	wave_spawner = get_node("../WaveSpawner")
	build_grid = get_node("../BuildGrid")
	audio_manager = get_node("../AudioManager")

	create_header()
	create_footer()
	create_game_over_panel()

	if game_manager:
		game_manager.gold_changed.connect(_on_gold_changed)
		game_manager.lives_changed.connect(_on_lives_changed)
		game_manager.game_over.connect(_on_game_over)
		game_manager.difficulty_changed.connect(_on_difficulty_changed)

	if wave_spawner:
		wave_spawner.wave_started.connect(_on_wave_started)
		wave_spawner.all_waves_completed.connect(_on_all_waves_completed)
		wave_spawner.boss_spawned.connect(_on_boss_spawned)

	update_difficulty_buttons(config.DEFAULT_DIFFICULTY)

func create_header() -> void:
	header_panel = Panel.new()
	header_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header_panel.offset_bottom = config.HEADER_HEIGHT
	var header_style = StyleBoxFlat.new()
	header_style.bg_color = Color(0.15, 0.15, 0.2, 0.95)
	header_style.border_width_bottom = 2
	header_style.border_color = Color(0.3, 0.3, 0.4)
	header_panel.add_theme_stylebox_override("panel", header_style)
	add_child(header_panel)

	# Left side: Game stats
	var stats_container = HBoxContainer.new()
	stats_container.position = Vector2(20, 15)
	stats_container.add_theme_constant_override("separation", 30)
	header_panel.add_child(stats_container)

	gold_label = Label.new()
	gold_label.text = "Gold: %d" % config.STARTING_GOLD
	gold_label.add_theme_font_size_override("font_size", 20)
	gold_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	stats_container.add_child(gold_label)

	lives_label = Label.new()
	lives_label.text = "Lives: %d" % config.STARTING_LIVES
	lives_label.add_theme_font_size_override("font_size", 20)
	lives_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	stats_container.add_child(lives_label)

	wave_label = Label.new()
	wave_label.text = "Wave: 0"
	wave_label.add_theme_font_size_override("font_size", 20)
	wave_label.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
	stats_container.add_child(wave_label)

	# Center-left: Difficulty selector
	var diff_section = VBoxContainer.new()
	diff_section.position = Vector2(420, 5)
	diff_section.add_theme_constant_override("separation", 2)
	header_panel.add_child(diff_section)

	var diff_label = Label.new()
	diff_label.text = "DIFFICULTY"
	diff_label.add_theme_font_size_override("font_size", 10)
	diff_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	diff_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	diff_section.add_child(diff_label)

	difficulty_container = HBoxContainer.new()
	difficulty_container.add_theme_constant_override("separation", 5)
	diff_section.add_child(difficulty_container)

	for diff_key in config.DIFFICULTY_CONFIGS:
		var diff_config = config.DIFFICULTY_CONFIGS[diff_key]
		var btn = Button.new()
		btn.text = diff_config.name
		btn.custom_minimum_size = Vector2(60, 28)
		btn.pressed.connect(_on_difficulty_button_pressed.bind(diff_key))
		difficulty_container.add_child(btn)
		difficulty_buttons[diff_key] = btn

	# Center: Boss health bar
	boss_container = Control.new()
	boss_container.set_anchors_preset(Control.PRESET_CENTER_TOP)
	boss_container.offset_left = -150
	boss_container.offset_right = 150
	boss_container.offset_top = 8
	boss_container.offset_bottom = 52
	boss_container.visible = false
	header_panel.add_child(boss_container)

	boss_label = Label.new()
	boss_label.text = "BOSS"
	boss_label.add_theme_font_size_override("font_size", 12)
	boss_label.add_theme_color_override("font_color", Color(1.0, 0.2, 1.0))
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_label.position = Vector2(0, 0)
	boss_label.size = Vector2(300, 18)
	boss_container.add_child(boss_label)

	boss_health_bar = ProgressBar.new()
	boss_health_bar.position = Vector2(0, 18)
	boss_health_bar.size = Vector2(300, 20)
	boss_health_bar.value = 100
	boss_health_bar.show_percentage = false
	var bar_style = StyleBoxFlat.new()
	bar_style.bg_color = Color(0.9, 0.1, 0.9)
	boss_health_bar.add_theme_stylebox_override("fill", bar_style)
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.1, 0.2)
	boss_health_bar.add_theme_stylebox_override("background", bg_style)
	boss_container.add_child(boss_health_bar)

	# Right side: Audio controls
	var audio_container = HBoxContainer.new()
	audio_container.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	audio_container.position = Vector2(-210, 12)
	audio_container.add_theme_constant_override("separation", 8)
	header_panel.add_child(audio_container)

	sfx_button = Button.new()
	sfx_button.text = "SFX: OFF"
	sfx_button.custom_minimum_size = Vector2(80, 35)
	sfx_button.pressed.connect(_on_sfx_button_pressed)
	audio_container.add_child(sfx_button)

	music_button = Button.new()
	music_button.text = "Music: OFF"
	music_button.custom_minimum_size = Vector2(95, 35)
	music_button.pressed.connect(_on_music_button_pressed)
	audio_container.add_child(music_button)

func create_footer() -> void:
	footer_panel = Panel.new()
	footer_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	footer_panel.offset_top = -config.FOOTER_HEIGHT
	var footer_style = StyleBoxFlat.new()
	footer_style.bg_color = Color(0.15, 0.15, 0.2, 0.95)
	footer_style.border_width_top = 2
	footer_style.border_color = Color(0.3, 0.3, 0.4)
	footer_panel.add_theme_stylebox_override("panel", footer_style)
	add_child(footer_panel)

	var footer_content = HBoxContainer.new()
	footer_content.set_anchors_preset(Control.PRESET_FULL_RECT)
	footer_content.offset_left = 20
	footer_content.offset_right = -20
	footer_content.offset_top = 10
	footer_content.offset_bottom = -10
	footer_content.alignment = BoxContainer.ALIGNMENT_CENTER
	footer_content.add_theme_constant_override("separation", 30)
	footer_panel.add_child(footer_content)

	var tower_section = VBoxContainer.new()
	tower_section.add_theme_constant_override("separation", 2)
	footer_content.add_child(tower_section)

	var tower_label = Label.new()
	tower_label.text = "BUILD TOWERS"
	tower_label.add_theme_font_size_override("font_size", 12)
	tower_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	tower_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tower_section.add_child(tower_label)

	tower_buttons = HBoxContainer.new()
	tower_buttons.add_theme_constant_override("separation", 8)
	tower_section.add_child(tower_buttons)

	for type in config.TOWER_CONFIGS:
		var tower_config = config.TOWER_CONFIGS[type]
		var button = Button.new()
		button.text = "%s\n$%d" % [tower_config.name, tower_config.cost]
		button.custom_minimum_size = Vector2(100, 50)
		button.pressed.connect(_on_tower_button_pressed.bind(type))
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = tower_config.color * 0.5
		btn_style.border_width_bottom = 3
		btn_style.border_color = tower_config.color
		button.add_theme_stylebox_override("normal", btn_style)
		tower_buttons.add_child(button)

	var wave_section = VBoxContainer.new()
	wave_section.add_theme_constant_override("separation", 2)
	footer_content.add_child(wave_section)

	var wave_control_label = Label.new()
	wave_control_label.text = "WAVE CONTROL"
	wave_control_label.add_theme_font_size_override("font_size", 12)
	wave_control_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	wave_control_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wave_section.add_child(wave_control_label)

	var wave_buttons = HBoxContainer.new()
	wave_buttons.add_theme_constant_override("separation", 10)
	wave_section.add_child(wave_buttons)

	wave_timer_label = Label.new()
	wave_timer_label.custom_minimum_size = Vector2(120, 40)
	wave_timer_label.add_theme_font_size_override("font_size", 16)
	wave_timer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	wave_buttons.add_child(wave_timer_label)

	next_wave_button = Button.new()
	next_wave_button.text = "Start Wave"
	next_wave_button.custom_minimum_size = Vector2(100, 40)
	next_wave_button.pressed.connect(_on_next_wave_pressed)
	wave_buttons.add_child(next_wave_button)

func create_game_over_panel() -> void:
	game_over_panel = Panel.new()
	game_over_panel.set_anchors_preset(Control.PRESET_CENTER)
	game_over_panel.offset_left = -180
	game_over_panel.offset_top = -120
	game_over_panel.offset_right = 180
	game_over_panel.offset_bottom = 120
	game_over_panel.visible = false
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.15, 0.98)
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color(0.4, 0.4, 0.5)
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_left = 10
	panel_style.corner_radius_bottom_right = 10
	game_over_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(game_over_panel)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 20
	vbox.offset_right = -20
	vbox.offset_top = 20
	vbox.offset_bottom = -20
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 15)
	game_over_panel.add_child(vbox)

	game_over_label = Label.new()
	game_over_label.text = "GAME OVER"
	game_over_label.add_theme_font_size_override("font_size", 28)
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(game_over_label)

	continue_button = Button.new()
	continue_button.text = "Continue to Endless"
	continue_button.custom_minimum_size = Vector2(180, 45)
	continue_button.pressed.connect(_on_continue_pressed)
	vbox.add_child(continue_button)

	restart_button = Button.new()
	restart_button.text = "Restart"
	restart_button.custom_minimum_size = Vector2(180, 45)
	restart_button.pressed.connect(_on_restart_pressed)
	vbox.add_child(restart_button)

func _on_difficulty_button_pressed(difficulty: String) -> void:
	if game_manager:
		game_manager.set_difficulty(difficulty)
	update_difficulty_buttons(difficulty)

func update_difficulty_buttons(selected: String) -> void:
	for diff_key in difficulty_buttons:
		var btn = difficulty_buttons[diff_key]
		var diff_config = config.DIFFICULTY_CONFIGS[diff_key]
		var style = StyleBoxFlat.new()

		if diff_key == selected:
			style.bg_color = diff_config.color
			style.border_width_bottom = 3
			style.border_color = diff_config.color * 1.3
		else:
			style.bg_color = diff_config.color * 0.3
			style.border_width_bottom = 0

		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)

func _on_difficulty_changed(difficulty: String) -> void:
	update_difficulty_buttons(difficulty)

func _on_boss_spawned(boss: Node) -> void:
	current_boss = boss
	boss_container.visible = true
	boss_health_bar.value = 100

	if boss.has_signal("boss_health_changed"):
		boss.boss_health_changed.connect(_on_boss_health_changed)
	if boss.has_signal("died"):
		boss.died.connect(_on_boss_died)
	if boss.has_signal("reached_end"):
		boss.reached_end.connect(_on_boss_escaped)

func _on_boss_health_changed(current: int, maximum: int) -> void:
	boss_health_bar.value = float(current) / float(maximum) * 100
	boss_label.text = "BOSS - %d / %d" % [current, maximum]

func _on_boss_died(_gold: int) -> void:
	boss_container.visible = false
	current_boss = null

func _on_boss_escaped() -> void:
	boss_container.visible = false
	current_boss = null

func _on_sfx_button_pressed() -> void:
	if audio_manager:
		audio_manager.toggle_sfx_mute()
		sfx_button.text = "SFX: OFF" if audio_manager.sfx_muted else "SFX: ON"

func _on_music_button_pressed() -> void:
	if audio_manager:
		audio_manager.toggle_music_mute()
		music_button.text = "Music: OFF" if audio_manager.music_muted else "Music: ON"

func _process(_delta: float) -> void:
	if wave_spawner:
		var countdown = wave_spawner.get_wave_countdown()
		if countdown > 0:
			wave_timer_label.text = "Next: %.1fs" % countdown
			next_wave_button.visible = true
		else:
			wave_timer_label.text = ""
			next_wave_button.visible = false

func _on_tower_button_pressed(tower_type: String) -> void:
	if build_grid:
		build_grid.select_tower_type(tower_type)

func _on_gold_changed(amount: int) -> void:
	gold_label.text = "Gold: %d" % amount

func _on_lives_changed(amount: int) -> void:
	lives_label.text = "Lives: %d" % amount

func _on_wave_started(wave_number: int) -> void:
	wave_label.text = "Wave: %d" % wave_number

func _on_game_over(_won: bool) -> void:
	game_over_panel.visible = true
	game_over_label.text = "GAME OVER\nThe enemies broke through!"
	continue_button.visible = false
	restart_button.visible = true

func _on_all_waves_completed() -> void:
	game_over_panel.visible = true
	game_over_label.text = "VICTORY!\nAll 10 waves cleared!\n\nReady for Endless Mode?"
	continue_button.visible = true
	restart_button.visible = true

func _on_continue_pressed() -> void:
	game_over_panel.visible = false
	if wave_spawner:
		wave_spawner.skip_wave_countdown()

func _on_next_wave_pressed() -> void:
	if wave_spawner:
		wave_spawner.skip_wave_countdown()

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
