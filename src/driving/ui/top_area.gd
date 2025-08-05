extends Control
class_name TopArea

@onready var timer_label: Label = $TimerLabel
@onready var background: ColorRect = $Background

func _ready() -> void:
	setup_appearance()
	hide_timer()

func setup_appearance() -> void:
	# Set up the control dimensions (40% width, 20% height, 10% from top)
	var screen_size = get_viewport_rect().size
	var width = screen_size.x * 0.4
	var height = screen_size.y * 0.2
	var x_pos = (screen_size.x - width) / 2
	var y_pos = screen_size.y * 0.1
	
	set_position(Vector2(x_pos, y_pos))
	set_size(Vector2(width, height))
	
	# Setup background
	background.set_size(Vector2(width, height))
	background.color = Color(0.1, 0.1, 0.1, 0.8)  # Semi-transparent dark
	background.position = Vector2.ZERO
	
	# Setup timer label
	timer_label.set_size(Vector2(width, height))
	timer_label.position = Vector2.ZERO
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	timer_label.theme = create_timer_theme()

func create_timer_theme() -> Theme:
	var theme = Theme.new()
	
	# Create font
	var font = load("res://resource/fonts/ka1.ttf")
	if font:
		var font_size = 48
		var font_settings = FontVariation.new()
		font_settings.base_font = font
#		font_settings.set_spacing(Font.SPACING_TOP, -2)
#		font_settings.set_spacing(Font.SPACING_BOTTOM, -2)
		
		# Apply to label
		theme.set_font_size("font_size", "Label", font_size)
		theme.set_font("font", "Label", font_settings)
		theme.set_color("font_color", "Label", Color(1, 1, 1))
	
	return theme

func update_for_state(new_state: int) -> void:
	match new_state:
		0:  # INITIAL
			hide_timer()
		1:  # FOCUS
			show_timer()

func show_timer() -> void:
	visible = true
	timer_label.visible = true

func hide_timer() -> void:
	visible = false
	timer_label.visible = false

func update_timer(time_seconds: int) -> void:
	var hours = time_seconds / 3600
	var minutes = (time_seconds % 3600) / 60
	var seconds = time_seconds % 60
	
	var time_string = "%.2d:%.2d:%.2d" % [hours, minutes, seconds]
	timer_label.text = time_string
