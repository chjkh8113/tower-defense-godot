extends Control
class_name GameOverUI
## Game over panel with victory/defeat messages and buttons

signal continue_pressed()
signal restart_pressed()

var game_over_panel: Panel
var game_over_label: Label
var continue_button: Button
var restart_button: Button

func _ready() -> void:
	create_panel()

func create_panel() -> void:
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
	continue_button.pressed.connect(func(): continue_pressed.emit(); hide_panel())
	vbox.add_child(continue_button)

	restart_button = Button.new()
	restart_button.text = "Restart"
	restart_button.custom_minimum_size = Vector2(180, 45)
	restart_button.pressed.connect(func(): restart_pressed.emit())
	vbox.add_child(restart_button)

func show_game_over() -> void:
	game_over_panel.visible = true
	game_over_label.text = "GAME OVER\nThe enemies broke through!"
	continue_button.visible = false
	restart_button.visible = true

func show_victory() -> void:
	game_over_panel.visible = true
	game_over_label.text = "VICTORY!\nAll 10 waves cleared!\n\nReady for Endless Mode?"
	continue_button.visible = true
	restart_button.visible = true

func hide_panel() -> void:
	game_over_panel.visible = false
