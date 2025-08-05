class_name ProjectSelector
extends Control

## 项目选择器组件
## 实现无限循环轮播选择器，每次最多显示5个项目，选中项目始终位于中间位置

signal project_selected(project: ProjectData)

@onready var projects_container: HBoxContainer = $VBoxContainer/ProjectsContainer

var projects: Array[ProjectData] = []
var current_index: int = 0
var project_buttons: Array[Button] = []

const PROJECT_BUTTON_WIDTH = 120
const PROJECT_BUTTON_HEIGHT = 60
const MAX_VISIBLE_PROJECTS = 5  # 最多显示5个项目
const CENTER_POSITION = 2  # 中心位置索引（0-4中的第2个）

func _ready() -> void:
	# 初始化固定的5个项目按钮位置
	_initialize_project_buttons()

## 设置项目列表
## [br]更新显示的项目列表并刷新显示
func set_projects(project_list: Array[ProjectData]) -> void:
	projects = project_list

	# 确保选中索引有效
	if projects.size() > 0:
		current_index = clamp(current_index, 0, projects.size() - 1)
	else:
		current_index = 0

	# 更新显示的项目
	_update_visible_projects()

## 获取当前选中的项目
func get_current_project() -> ProjectData:
	if current_index >= 0 and current_index < projects.size():
		return projects[current_index]
	return null

## 设置当前选中的项目索引
func set_current_index(index: int) -> void:
	if index >= 0 and index < projects.size():
		current_index = index
		_update_visible_projects()

## 初始化固定的5个项目按钮位置
func _initialize_project_buttons() -> void:
	# 清除现有按钮
	for button in project_buttons:
		button.queue_free()
	project_buttons.clear()

	# 创建固定的5个按钮位置
	for i in range(MAX_VISIBLE_PROJECTS):
		var button = _create_empty_project_button(i)
		projects_container.add_child(button)
		project_buttons.append(button)

## 创建空的项目按钮
func _create_empty_project_button(position_index: int) -> Button:
	var button = Button.new()
	button.text = ""
	button.custom_minimum_size = Vector2(PROJECT_BUTTON_WIDTH, PROJECT_BUTTON_HEIGHT)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.visible = false  # 初始隐藏

	# 连接点击信号，传递位置索引
	button.pressed.connect(_on_position_button_pressed.bind(position_index))

	return button

## 更新可见项目显示
## [br]根据当前选中索引，计算并显示5个位置的项目
func _update_visible_projects() -> void:
	if projects.is_empty():
		# 没有项目时隐藏所有按钮
		for button in project_buttons:
			button.visible = false
		return

	# 计算每个位置应该显示的项目索引
	var visible_count = min(projects.size(), MAX_VISIBLE_PROJECTS)

	for pos in range(MAX_VISIBLE_PROJECTS):
		var button = project_buttons[pos]

		if pos < visible_count:
			# 计算该位置对应的项目索引
			var project_index = _get_project_index_for_position(pos)
			var project = projects[project_index]

			# 更新按钮内容和样式
			button.text = project.name
			button.visible = true

			# 设置选中状态样式
			if pos == CENTER_POSITION:
				# 中心位置（选中状态）
				button.add_theme_stylebox_override("normal", _get_selected_style())
				button.scale = Vector2(1.2, 1.2)
			else:
				# 普通状态
				button.remove_theme_stylebox_override("normal")
				button.scale = Vector2(1.0, 1.0)
		else:
			# 隐藏多余的按钮位置
			button.visible = false

	# 发送选中信号
	if current_index >= 0 and current_index < projects.size():
		project_selected.emit(projects[current_index])

## 根据位置索引计算对应的项目索引
## [br]实现环形循环逻辑
func _get_project_index_for_position(pos_index: int) -> int:
	if projects.is_empty():
		return 0

	# 计算相对于中心位置的偏移
	var offset = pos_index - CENTER_POSITION
	# 应用环形循环
	var project_index = (current_index + offset + projects.size()) % projects.size()
	return project_index

## 更新选中状态（保持兼容性）
func _update_selection() -> void:
	# 新的实现直接调用更新可见项目方法
	_update_visible_projects()

## 获取选中状态的样式
func _get_selected_style() -> StyleBox:
	var style = StyleBoxFlat.new()
	style.bg_color = Color.BLUE
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color.WHITE
	return style

## 切换到下一个项目（支持循环）
func next_project() -> void:
	if projects.size() > 0:
		current_index = (current_index + 1) % projects.size()
		_update_visible_projects()

## 切换到上一个项目（支持循环）
func previous_project() -> void:
	if projects.size() > 0:
		current_index = (current_index - 1 + projects.size()) % projects.size()
		_update_visible_projects()

## 位置按钮点击事件
## [br]根据点击的位置计算目标项目并切换
func _on_position_button_pressed(position_index: int) -> void:
	if projects.is_empty():
		return

	# 计算点击位置对应的项目索引
	var target_project_index = _get_project_index_for_position(position_index)

	# 如果点击的不是中心位置，则切换到该项目
	if position_index != CENTER_POSITION:
		current_index = target_project_index
		_update_visible_projects()
	# 如果点击的是中心位置，重新发送选中信号（可用于确认选择）
	else:
		project_selected.emit(projects[current_index])
