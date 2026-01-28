extends Control
class_name FooterUI
## Footer panel with tower buttons and wave controls

signal tower_selected(tower_type: String)
signal start_wave_pressed()

var config = preload("res://scripts/game_config.gd")

var footer_panel: Panel
var tower_buttons: HBoxContainer
var wave_timer_label: Label
var next_wave_button: Button

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	create_footer()

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

	create_tower_section(footer_content)
	create_wave_section(footer_content)

func create_tower_section(parent: Control) -> void:
	var tower_section = VBoxContainer.new()
	tower_section.add_theme_constant_override("separation", 2)
	parent.add_child(tower_section)

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
		button.pressed.connect(_on_tower_pressed.bind(type))
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = tower_config.color * 0.5
		btn_style.border_width_bottom = 3
		btn_style.border_color = tower_config.color
		button.add_theme_stylebox_override("normal", btn_style)
		tower_buttons.add_child(button)

func create_wave_section(parent: Control) -> void:
	var wave_section = VBoxContainer.new()
	wave_section.add_theme_constant_override("separation", 2)
	parent.add_child(wave_section)

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
	next_wave_button.pressed.connect(func(): start_wave_pressed.emit())
	wave_buttons.add_child(next_wave_button)

func _on_tower_pressed(tower_type: String) -> void:
	tower_selected.emit(tower_type)

func update_wave_countdown(countdown: float) -> void:
	if countdown > 0:
		wave_timer_label.text = "Next: %.1fs" % countdown
		next_wave_button.visible = true
	else:
		wave_timer_label.text = ""
		next_wave_button.visible = false
