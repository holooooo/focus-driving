extends Control
class_name SettingsArea

@onready var stats_button: Button = $StatsButton
@onready var shop_button: Button = $ShopButton
@onready var settings_button: Button = $SettingsButton
@onready var background: ColorRect = $Background

func _ready() -> void:
	setup_appearance()
	connect_buttons()

func setup_appearance() -> void:
	# Position in top right corner
	var screen_size = get_viewport_rect().size
	var button_size = Vector2(50, 50)
	var spacing = 10
	var x_start = screen_size.x - 200  # Leave space for 3 buttons
	var y_pos = 50
	
	set_position(Vector2(x_start, y_pos))
	set_size(Vector2(150, 50))  # 3 buttons + spacing
	
	# Setup background
	background.set_size(Vector2(150, 50))
	background.color = Color(0.1, 0.1, 0.1, 0.5)  # Semi-transparent
	background.position = Vector2.ZERO
	
	# Setup buttons
	setup_button(stats_button, "📊", Vector2(0, 0), button_size)
	setup_button(shop_button, "🏪", Vector2(button_size.x + spacing, 0), button_size)
	setup_button(settings_button, "⚙️", Vector2(2 * (button_size.x + spacing), 0), button_size)

func setup_button(button: Button, text: String, position: Vector2, size: Vector2) -> void:
	button.position = position
	button.set_size(size)
	button.text = text
	button.flat = true
	button.theme = create_button_theme()
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func create_button_theme() -> Theme:
	var theme = Theme.new()
	var font = load("res://resource/fonts/ka1.ttf")
	
	if font:
		var font_variation = FontVariation.new()
		font_variation.base_font = font
#		font_variation.set_spacing(Font.SPACING_TOP, -2)
#		font_variation.set_spacing(Font.SPACING_BOTTOM, -2)
		
		theme.set_font_size("font_size", "Button", 20)
		theme.set_font("font", "Button", font_variation)
		theme.set_color("font_color", "Button", Color(1, 1, 1))
		theme.set_color("font_hover_color", "Button", Color(0.8, 0.8, 1))
		theme.set_color("font_pressed_color", "Button", Color(0.6, 0.6, 0.8))
	
	return theme

func connect_buttons() -> void:
	stats_button.pressed.connect(_on_stats_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	settings_button.pressed.connect(_on_settings_pressed)

func _on_stats_pressed() -> void:
	if get_parent() and get_parent().has_signal("stats_requested"):
		get_parent().stats_requested.emit()

func _on_shop_pressed() -> void:
	if get_parent() and get_parent().has_signal("shop_requested"):
		get_parent().shop_requested.emit()

func _on_settings_pressed() -> void:
	if get_parent() and get_parent().has_signal("settings_requested"):
		get_parent().settings_requested.emit()

func update_for_state(new_state: int) -> void:
	# Settings buttons are always visible regardless of state
	visible = true
