extends RefCounted
class_name HeaderUI
## Header panel with stats, difficulty selector, and audio controls

signal difficulty_selected(difficulty: String)
signal sfx_toggled()
signal music_toggled()

var config = preload("res://scripts/game_config.gd")

var parent_node: Node
var header_panel: Panel
var gold_label: Label
var lives_label: Label
var wave_label: Label
var sfx_button: Button
var music_button: Button
var difficulty_buttons: Dictionary = {}

func setup(parent: Node) -> void:
	parent_node = parent
	create_header()

func create_header() -> void:
	header_panel = Panel.new()
	header_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header_panel.offset_bottom = config.HEADER_HEIGHT
	var header_style = StyleBoxFlat.new()
	header_style.bg_color = Color(0.15, 0.15, 0.2, 0.95)
	header_style.border_width_bottom = 2
	header_style.border_color = Color(0.3, 0.3, 0.4)
	header_panel.add_theme_stylebox_override("panel", header_style)
	parent_node.add_child(header_panel)

	create_stats()
	create_difficulty_selector()
	create_audio_controls()

func create_stats() -> void:
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

func create_difficulty_selector() -> void:
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

	var difficulty_container = HBoxContainer.new()
	difficulty_container.add_theme_constant_override("separation", 5)
	diff_section.add_child(difficulty_container)

	for diff_key in config.DIFFICULTY_CONFIGS:
		var diff_config = config.DIFFICULTY_CONFIGS[diff_key]
		var btn = Button.new()
		btn.text = diff_config.name
		btn.custom_minimum_size = Vector2(60, 28)
		btn.pressed.connect(_on_difficulty_pressed.bind(diff_key))
		difficulty_container.add_child(btn)
		difficulty_buttons[diff_key] = btn

	update_difficulty_buttons(config.DEFAULT_DIFFICULTY)

func create_audio_controls() -> void:
	var audio_container = HBoxContainer.new()
	audio_container.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	audio_container.position = Vector2(-210, 12)
	audio_container.add_theme_constant_override("separation", 8)
	header_panel.add_child(audio_container)

	sfx_button = Button.new()
	sfx_button.text = "SFX: OFF"
	sfx_button.custom_minimum_size = Vector2(80, 35)
	sfx_button.pressed.connect(func(): sfx_toggled.emit())
	audio_container.add_child(sfx_button)

	music_button = Button.new()
	music_button.text = "Music: OFF"
	music_button.custom_minimum_size = Vector2(95, 35)
	music_button.pressed.connect(func(): music_toggled.emit())
	audio_container.add_child(music_button)

func _on_difficulty_pressed(difficulty: String) -> void:
	difficulty_selected.emit(difficulty)
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

func update_gold(amount: int) -> void:
	if gold_label:
		gold_label.text = "Gold: %d" % amount

func update_lives(amount: int) -> void:
	if lives_label:
		lives_label.text = "Lives: %d" % amount

func update_wave(wave_number: int) -> void:
	if wave_label:
		wave_label.text = "Wave: %d" % wave_number

func update_sfx_button(muted: bool) -> void:
	if sfx_button:
		sfx_button.text = "SFX: OFF" if muted else "SFX: ON"

func update_music_button(muted: bool) -> void:
	if music_button:
		music_button.text = "Music: OFF" if muted else "Music: ON"
