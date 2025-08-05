extends Control
class_name BottomArea

@onready var project_selector: Control = $ProjectSelector
@onready var focus_controls: Control = $FocusControls
@onready var project_tabs: HBoxContainer = $ProjectSelector/ProjectTabs
@onready var add_button: Button = $ProjectSelector/AddButton
@onready var delete_button: Button = $ProjectSelector/DeleteButton
@onready var start_button: Button = $ProjectSelector/StartButton
@onready var cancel_button: Button = $FocusControls/CancelButton
@onready var pause_button: Button = $FocusControls/PauseButton
@onready var resume_button: Button = $FocusControls/ResumeButton
@onready var complete_button: Button = $FocusControls/CompleteButton

var projects: Array             = []
var selected_project_index: int = 0
var max_visible_tabs: int       = 5
# Signals for project management
signal project_selected(project_id: String)
signal project_created(project_name: String)
signal project_deleted(project_id: String)
signal focus_started(project_id: String)
signal focus_cancelled()
signal focus_paused()
signal focus_resumed()
signal focus_completed()


func _ready() -> void:
	setup_appearance()
	connect_signals()
	setup_initial_projects()


func setup_appearance() -> void:
	# Set up the control dimensions (40% width, 20% height, 10% from bottom)
	var screen_size = get_viewport_rect().size
	var width       = screen_size.x * 0.4
	var height      = screen_size.y * 0.2
	var x_pos       = (screen_size.x - width) / 2
	var y_pos       = screen_size.y * 0.9 - height

	set_position(Vector2(x_pos, y_pos))
	set_size(Vector2(width, height))

	# Setup backgrounds
	setup_background($ProjectSelector/Background, width, height)
	setup_background($FocusControls/Background, width, height)

	# Setup buttons
	setup_project_buttons()
	setup_focus_buttons()


func setup_background(bg: ColorRect, width: float, height: float) -> void:
	bg.set_size(Vector2(width, height))
	bg.color = Color(0.1, 0.1, 0.1, 0.8)


func setup_project_buttons() -> void:
	var button_size = Vector2(40, 40)
	var spacing     = 10

	# Position buttons around tabs
	var tabs_width = 300  # Approximate width for tabs
	var start_x    = (get_size().x - tabs_width - 2 * button_size.x - 2 * spacing) / 2

	delete_button.position = Vector2(start_x, get_size().y / 2 - 20)
	delete_button.set_size(button_size)
	delete_button.text = "🗑️"
	delete_button.flat = true

	project_tabs.position = Vector2(start_x + button_size.x + spacing, get_size().y / 2 - 15)
	project_tabs.set_size(Vector2(tabs_width, 30))

	add_button.position = Vector2(start_x + button_size.x + spacing + tabs_width + spacing, get_size().y / 2 - 20)
	add_button.set_size(button_size)
	add_button.text = "➕"
	add_button.flat = true

	start_button.position = Vector2(get_size().x / 2 - 60, get_size().y - 40)
	start_button.set_size(Vector2(120, 30))
	start_button.text = "开始驾驶"


func setup_focus_buttons() -> void:
	var button_size = Vector2(60, 40)
	var spacing     = 20
	var total_width = 4 * button_size.x + 3 * spacing
	var start_x     = (get_size().x - total_width) / 2
	var y_pos       = get_size().y / 2 - 20

	cancel_button.position = Vector2(start_x, y_pos)
	cancel_button.set_size(button_size)
	cancel_button.text = "✕"

	pause_button.position = Vector2(start_x + button_size.x + spacing, y_pos)
	pause_button.set_size(button_size)
	pause_button.text = "⏸️"

	resume_button.position = Vector2(start_x + button_size.x + spacing, y_pos)
	resume_button.set_size(button_size)
	resume_button.text = "▶️"
	resume_button.visible = false

	complete_button.position = Vector2(start_x + 2 * (button_size.x + spacing), y_pos)
	complete_button.set_size(button_size)
	complete_button.text = "✓"


func connect_signals() -> void:
	# Project management signals
	add_button.pressed.connect(_on_add_project_pressed)
	delete_button.pressed.connect(_on_delete_project_pressed)
	start_button.pressed.connect(_on_start_focus_pressed)

	# Focus control signals
	cancel_button.pressed.connect(_on_cancel_focus_pressed)
	pause_button.pressed.connect(_on_pause_focus_pressed)
	resume_button.pressed.connect(_on_resume_focus_pressed)
	complete_button.pressed.connect(_on_complete_focus_pressed)


func setup_initial_projects() -> void:
	# Add some sample projects
	projects = [
		{"id": "1", "name": "毕业设计"},
		{"id": "2", "name": "健身计划"},
		{"id": "3", "name": "阅读之旅"}
	]
	update_project_tabs()


func update_project_tabs() -> void:
	# Clear existing tabs
	for child in project_tabs.get_children():
		child.queue_free()

	# Create visible tabs
	var start_index: int = max(0, selected_project_index - max_visible_tabs / 2)
	var end_index: int   = min(projects.size(), start_index + max_visible_tabs)

	for i in range(start_index, end_index):
		var project    = projects[i]
		var tab_button = Button.new()
		tab_button.text = project.name
		tab_button.flat = true
		tab_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		tab_button.pressed.connect(_on_project_tab_pressed.bind(i))

		# Style selected tab
		if i == selected_project_index:
			tab_button.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
			tab_button.add_theme_font_size_override("font_size", 16)
		else:
			tab_button.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
			tab_button.add_theme_font_size_override("font_size", 12)

		project_tabs.add_child(tab_button)


func update_for_state(new_state: int) -> void:
	match new_state:
		0: # INITIAL
			project_selector.visible = true
			focus_controls.visible = false
		1: # FOCUS
			project_selector.visible = false
			focus_controls.visible = true


func set_focus_paused(paused: bool) -> void:
	pause_button.visible = !paused
	resume_button.visible = paused


func _on_project_tab_pressed(index: int) -> void:
	if index < projects.size():
		selected_project_index = index
		update_project_tabs()

		var project = projects[index]
		project_selected.emit(project.id)


func _on_add_project_pressed() -> void:
	# In a real implementation, this would show a modal
	# For now, we'll emit the signal to parent
	var parent_ui = get_parent()
	if parent_ui and parent_ui.has_method("show_create_project_modal"):
		parent_ui.show_create_project_modal()


func _on_delete_project_pressed() -> void:
	if projects.size() > 0 and selected_project_index < projects.size():
		var project = projects[selected_project_index]
		# In a real implementation, this would show a confirmation modal
		var parent_ui = get_parent()
		if parent_ui and parent_ui.has_method("show_delete_project_modal"):
			parent_ui.show_delete_project_modal(project.id, project.name)


func _on_start_focus_pressed() -> void:
	print("开始专注会话")
	if projects.size() > 0 and selected_project_index < projects.size():
		var project = projects[selected_project_index]
		focus_started.emit(project.id)


func _on_cancel_focus_pressed() -> void:
	# Show confirmation modal
	var parent_ui = get_parent()
	if parent_ui and parent_ui.has_method("show_cancel_focus_modal"):
		parent_ui.show_cancel_focus_modal()
	else:
		focus_cancelled.emit()


func _on_pause_focus_pressed() -> void:
	set_focus_paused(true)
	focus_paused.emit()


func _on_resume_focus_pressed() -> void:
	set_focus_paused(false)
	focus_resumed.emit()


func _on_complete_focus_pressed() -> void:
	# Show confirmation modal
	var parent_ui = get_parent()
	if parent_ui and parent_ui.has_method("show_complete_focus_modal"):
		parent_ui.show_complete_focus_modal()
	else:
		focus_completed.emit()


func add_project(project_name: String) -> void:
	var new_project = {
						  "id": str(projects.size() + 1),
						  "name": project_name
					  }
	projects.append(new_project)
	selected_project_index = projects.size() - 1
	update_project_tabs()


func delete_project(project_id: String) -> void:
	for i in range(projects.size()):
		if projects[i].id == project_id:
			projects.remove_at(i)
			if selected_project_index >= projects.size():
				selected_project_index = max(0, projects.size() - 1)
			update_project_tabs()
			break


func update_projects(new_projects: Array) -> void:
	projects = new_projects
	selected_project_index = clamp(selected_project_index, 0, max(0, projects.size() - 1))
	update_project_tabs()
