extends Control
class_name UIManager

# Business Logic Signals
signal project_selected(project_id: String)
signal project_created(project_name: String)
signal project_deleted(project_id: String)
signal focus_started(project_id: String)
signal focus_paused()
signal focus_resumed()
signal focus_cancelled()
signal focus_completed()
signal stats_requested()
signal shop_requested()
signal settings_requested()

# UI State Management
enum UIState { INITIAL, FOCUS }
enum FocusState { RUNNING, PAUSED }

@onready var top_area: Control = $TopArea
@onready var settings_area: Control = $SettingsArea
@onready var bottom_area: Control = $BottomArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_ui_state: UIState = UIState.INITIAL
var current_focus_state: FocusState = FocusState.RUNNING
var hide_timer: float = 0.0
var is_ui_visible: bool = false
var auto_hide_enabled: bool = true

func _ready() -> void:
	setup_ui_visibility()
	setup_animation_player()
	connect_signals()
	hide_ui_immediately()

func _process(delta: float) -> void:
	if auto_hide_enabled and is_ui_visible:
		hide_timer += delta
		if hide_timer >= 5.0:
			hide_ui_with_animation()
			hide_timer = 0.0

func setup_ui_visibility() -> void:
	# Set initial states
	update_ui_for_state(current_ui_state)
	
func setup_animation_player() -> void:
	if not animation_player:
		animation_player = AnimationPlayer.new()
		add_child(animation_player)
	create_animations()

func create_animations() -> void:
	# Create slide in/out animations
	var slide_in := Animation.new()
	slide_in.length = 0.3
	slide_in.loop_mode = Animation.LOOP_NONE
	
	var slide_out := Animation.new()
	slide_out.length = 0.3
	slide_out.loop_mode = Animation.LOOP_NONE
	
	# Top area animations
	var top_start_pos = Vector2(640, 72)  # 10% from top, centered
	var top_hidden_pos = Vector2(640, -100)
	
	slide_in.track_insert_key(slide_in.add_track(Animation.TYPE_VALUE, 0), 0.0, top_hidden_pos)
	slide_in.track_insert_key(slide_in.add_track(Animation.TYPE_VALUE, 0), 0.3, top_start_pos)
	slide_in.track_set_path(0, "TopArea:position")
	
	slide_out.track_insert_key(slide_out.add_track(Animation.TYPE_VALUE, 0), 0.0, top_start_pos)
	slide_out.track_insert_key(slide_out.add_track(Animation.TYPE_VALUE, 0), 0.3, top_hidden_pos)
	slide_out.track_set_path(0, "TopArea:position")
	
	# Settings area animations
	var settings_start_pos = Vector2(1200, 50)  # Top right
	var settings_hidden_pos = Vector2(1400, 50)
	
	slide_in.track_insert_key(slide_in.add_track(Animation.TYPE_VALUE, 1), 0.0, settings_hidden_pos)
	slide_in.track_insert_key(slide_in.add_track(Animation.TYPE_VALUE, 1), 0.3, settings_start_pos)
	slide_in.track_set_path(1, "SettingsArea:position")
	
	slide_out.track_insert_key(slide_out.add_track(Animation.TYPE_VALUE, 1), 0.0, settings_start_pos)
	slide_out.track_insert_key(slide_out.add_track(Animation.TYPE_VALUE, 1), 0.3, settings_hidden_pos)
	slide_out.track_set_path(1, "SettingsArea:position")
	
	# Bottom area animations
	var bottom_start_pos = Vector2(640, 648)  # 10% from bottom, centered
	var bottom_hidden_pos = Vector2(640, 820)
	
	slide_in.track_insert_key(slide_in.add_track(Animation.TYPE_VALUE, 2), 0.0, bottom_hidden_pos)
	slide_in.track_insert_key(slide_in.add_track(Animation.TYPE_VALUE, 2), 0.3, bottom_start_pos)
	slide_in.track_set_path(2, "BottomArea:position")
	
	slide_out.track_insert_key(slide_out.add_track(Animation.TYPE_VALUE, 2), 0.0, bottom_start_pos)
	slide_out.track_insert_key(slide_out.add_track(Animation.TYPE_VALUE, 2), 0.3, bottom_hidden_pos)
	slide_out.track_set_path(2, "BottomArea:position")
	
	# Add fade animations
	var fade_in := Animation.new()
	fade_in.length = 0.3
	fade_in.loop_mode = Animation.LOOP_NONE
	fade_in.track_insert_key(fade_in.add_track(Animation.TYPE_VALUE, 0), 0.0, 0.0)
	fade_in.track_insert_key(fade_in.add_track(Animation.TYPE_VALUE, 0), 0.3, 1.0)
	fade_in.track_set_path(0, ".:modulate:a")
	
	var fade_out := Animation.new()
	fade_out.length = 0.3
	fade_out.loop_mode = Animation.LOOP_NONE
	fade_out.track_insert_key(fade_out.add_track(Animation.TYPE_VALUE, 0), 0.0, 1.0)
	fade_out.track_insert_key(fade_out.add_track(Animation.TYPE_VALUE, 0), 0.3, 0.0)
	fade_out.track_set_path(0, ".:modulate:a")
	
	animation_player.add_animation("slide_in", slide_in)
	animation_player.add_animation("slide_out", slide_out)
	animation_player.add_animation("fade_in", fade_in)
	animation_player.add_animation("fade_out", fade_out)

func connect_signals() -> void:
	# Connect input events
	if top_area:
		top_area.gui_input.connect(_on_ui_input)
	if settings_area:
		settings_area.gui_input.connect(_on_ui_input)
	if bottom_area:
		bottom_area.gui_input.connect(_on_ui_input)

func _on_ui_input(event: InputEvent) -> void:
	reset_hide_timer()
	show_ui_with_animation()

func reset_hide_timer() -> void:
	hide_timer = 0.0

func show_ui_with_animation() -> void:
	if not is_ui_visible:
		is_ui_visible = true
		animation_player.play("slide_in")
		animation_player.play("fade_in")

func hide_ui_with_animation() -> void:
	if is_ui_visible:
		is_ui_visible = false
		animation_player.play("slide_out")
		animation_player.play("fade_out")

func hide_ui_immediately() -> void:
	is_ui_visible = false
	modulate = Color(1, 1, 1, 0)
	
	# Position off-screen
	if top_area:
		top_area.position = Vector2(640, -100)
	if settings_area:
		settings_area.position = Vector2(1400, 50)
	if bottom_area:
		bottom_area.position = Vector2(640, 820)

func update_ui_for_state(new_state: UIState) -> void:
	current_ui_state = new_state
	
	# Update child components
	if top_area and top_area.has_method("update_for_state"):
		top_area.update_for_state(new_state)
	if bottom_area and bottom_area.has_method("update_for_state"):
		bottom_area.update_for_state(new_state)

func update_focus_timer(time_seconds: int) -> void:
	if top_area and top_area.has_method("update_timer"):
		top_area.update_timer(time_seconds)

func update_projects(projects: Array) -> void:
	if bottom_area and bottom_area.has_method("update_projects"):
		bottom_area.update_projects(projects)

func set_auto_hide_enabled(enabled: bool) -> void:
	auto_hide_enabled = enabled
	if not enabled:
		reset_hide_timer()
