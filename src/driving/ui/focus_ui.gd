class_name FocusUI
extends Control

## 专注软件主界面UI控制器
## 负责整个UI的状态管理和组件协调

signal ui_state_changed(is_visible: bool)
enum UIState {
	IDLE, # 初始状态
	FOCUSING    # 专注状态
}
# UI组件引用
@onready var top_area: Control = $TopArea
@onready var focus_timer: FocusTimer = $TopArea/FocusTimer
@onready var settings_area: Control = $SettingsArea
@onready var stats_button: Button = $SettingsArea/HBoxContainer/StatsButton
@onready var shop_button: Button = $SettingsArea/HBoxContainer/ShopButton
@onready var settings_button: Button = $SettingsArea/HBoxContainer/SettingsButton
@onready var bottom_area: Control = $BottomArea
@onready var project_selector: ProjectSelector = $BottomArea/InitialState/VBoxContainer/ProjectSelector
@onready var add_button: Button = $BottomArea/InitialState/VBoxContainer/ButtonsContainer/AddButton
@onready var start_button: Button = $BottomArea/InitialState/VBoxContainer/ButtonsContainer/StartButton
@onready var initial_state: Control = $BottomArea/InitialState
@onready var focus_state: Control = $BottomArea/FocusState
@onready var cancel_button: LongPressButton = $BottomArea/FocusState/HBoxContainer/CancelButton
@onready var pause_button: Button = $BottomArea/FocusState/HBoxContainer/PauseButton
@onready var resume_button: Button = $BottomArea/FocusState/HBoxContainer/ResumeButton
@onready var complete_button: LongPressButton = $BottomArea/FocusState/HBoxContainer/CompleteButton
# 弹窗组件
@onready var input_modal: InputModal = $InputModal
@onready var confirm_modal: ConfirmModal = $ConfirmModal

# 业务逻辑组件
var database_manager: DatabaseManager
var focus_manager: FocusManager
var current_state: UIState = UIState.IDLE
# UI状态
var is_ui_visible: bool = true
var auto_hide_timer: Timer
const AUTO_HIDE_DELAY: float = 5.0
# 保存各区域的原始位置，用于动画
var top_area_original_position: Vector2
var settings_area_original_position: Vector2
var bottom_area_original_position: Vector2


func _ready() -> void:
	# 初始化业务逻辑组件
	database_manager = DatabaseManager.new()
	focus_manager = FocusManager.new()
	add_child(focus_manager.timer)  # 将计时器添加到场景树

	# 设置自动隐藏计时器
	auto_hide_timer = Timer.new()
	auto_hide_timer.wait_time = AUTO_HIDE_DELAY
	auto_hide_timer.one_shot = true
	auto_hide_timer.timeout.connect(_on_auto_hide_timeout)
	add_child(auto_hide_timer)

	# 保存各区域的原始位置
	_save_original_positions()

	# 连接UI信号
	_connect_ui_signals()

	# 连接业务逻辑信号
	_connect_focus_manager_signals()

	# 初始化UI状态
	_initialize_ui()

	# 加载项目数据
	_load_projects()


## 保存各区域的原始位置
## [br]在初始化阶段保存各个UI区域的原始位置，用于动画计算
func _save_original_positions() -> void:
	top_area_original_position = top_area.position
	settings_area_original_position = settings_area.position
	bottom_area_original_position = bottom_area.position


## 连接UI组件信���
func _connect_ui_signals() -> void:
	# 设置区按钮
	stats_button.pressed.connect(_on_stats_button_pressed)
	shop_button.pressed.connect(_on_shop_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)

	# 项目选择器
	project_selector.project_selected.connect(_on_project_selected)

	# 初始状态按钮
	add_button.pressed.connect(_on_add_button_pressed)
	start_button.pressed.connect(_on_start_button_pressed)

	# 专注状态按钮
	cancel_button.long_press_completed.connect(_on_cancel_button_long_pressed)
	pause_button.pressed.connect(_on_pause_button_pressed)
	resume_button.pressed.connect(_on_resume_button_pressed)
	complete_button.long_press_completed.connect(_on_complete_button_long_pressed)

	# 弹窗信号
	input_modal.confirmed.connect(_on_input_modal_confirmed)
	input_modal.cancelled.connect(_on_input_modal_cancelled)
	confirm_modal.confirmed.connect(_on_confirm_modal_confirmed)
	confirm_modal.cancelled.connect(_on_confirm_modal_cancelled)


## 连接专注管理器信号
func _connect_focus_manager_signals() -> void:
	focus_manager.focus_started.connect(_on_focus_started)
	focus_manager.focus_paused.connect(_on_focus_paused)
	focus_manager.focus_resumed.connect(_on_focus_resumed)
	focus_manager.focus_completed.connect(_on_focus_completed)
	focus_manager.focus_cancelled.connect(_on_focus_cancelled)
	focus_manager.time_updated.connect(_on_time_updated)


## 初始化UI状态
func _initialize_ui() -> void:
	# 隐藏UI
	hide_ui()

	# 设置初始状态
	_set_ui_state(UIState.IDLE)


## 加载项目数据
func _load_projects() -> void:
	var projects: Array[ProjectData] = database_manager.get_all_projects()
	project_selector.set_projects(projects)


## 处理输入事件（点击屏幕任意位置激活UI）
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if not is_ui_visible:
			show_ui()
		_reset_auto_hide_timer()


## 显示UI
func show_ui() -> void:
	if is_ui_visible:
		return
	is_ui_visible = true
	show()

	# 分别为不同区域设置动画
	var tween: Tween = create_tween()
	tween.set_parallel(true)

	# 全局淡入效果
	modulate.a = 0.0
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

	# 获取屏幕高度用于底部区域动画
	var screen_height = get_viewport().size.y

	# 顶部区域从上方��入
	top_area.position.y = -top_area.size.y  # 隐藏在屏幕上方
	tween.tween_property(top_area, "position:y", top_area_original_position.y, 0.3)

	# 设置区域从上方滑入
	settings_area.position.y = -settings_area.size.y  # 隐�������在屏幕上方
	tween.tween_property(settings_area, "position:y", settings_area_original_position.y, 0.3)

	# 底部区域从下方滑入
	bottom_area.position.y = screen_height  # 隐藏在屏幕下方
	tween.tween_property(bottom_area, "position:y", bottom_area_original_position.y, 0.3)

	_reset_auto_hide_timer()
	ui_state_changed.emit(true)


## 隐藏UI
func hide_ui() -> void:
	if not is_ui_visible:
		return
	is_ui_visible = false
	auto_hide_timer.stop()

	# ��别为不同区域设置动画
	var tween: Tween = create_tween()
	tween.set_parallel(true)

	# 全局淡出效果
	tween.tween_property(self, "modulate:a", 0.0, 0.3)

	# 顶部区域和设置区域：向上滑出
	tween.tween_property(top_area, "position:y", -top_area.size.y, 0.3)
	tween.tween_property(settings_area, "position:y", -settings_area.size.y, 0.3)

	# 底部区域向下滑出
	var screen_height = get_viewport().size.y
	tween.tween_property(bottom_area, "position:y", screen_height, 0.3)

	await tween.finished
	hide()
	ui_state_changed.emit(false)


## 重置自动隐藏计时器
func _reset_auto_hide_timer() -> void:
	if is_ui_visible:
		auto_hide_timer.start()


## 设置UI状态
func _set_ui_state(state: UIState) -> void:
	current_state = state

	match state:
		UIState.IDLE:
			# 显示初始状态UI
			focus_timer.hide()
			initial_state.show()
			focus_state.hide()

		UIState.FOCUSING:
			# 显示专注状态UI
			focus_timer.show()
			initial_state.hide()
			focus_state.show()
			_update_focus_buttons()


## 更新专注状态按钮显示
func _update_focus_buttons() -> void:
	var focus_state_enum: FocusManager.FocusState = focus_manager.get_current_state()

	match focus_state_enum:
		FocusManager.FocusState.RUNNING:
			pause_button.show()
			resume_button.hide()
		FocusManager.FocusState.PAUSED:
			pause_button.hide()
			resume_button.show()
		FocusManager.FocusState.IDLE:
			pass

# === UI事件处理 ===

func _on_stats_button_pressed() -> void:
	# TODO: 显示统计面板
	_pause_if_focusing()
	print("显示统计页面")


func _on_shop_button_pressed() -> void:
	# TODO: 显示商城面板
	_pause_if_focusing()
	print("显示商城页面")


func _on_settings_button_pressed() -> void:
	# TODO: 显示设置面板
	_pause_if_focusing()
	print("显示设置页面")


func _on_project_selected(_project: ProjectData) -> void:
	# 项目被选中时重置自动隐藏计时器
	_reset_auto_hide_timer()


func _on_add_button_pressed() -> void:
	var existing_names: Array[String] = []
	var projects: Array[ProjectData]  = database_manager.get_all_projects()
	for project in projects:
		existing_names.append(project.name)

	input_modal.show_input("新建旅途", "请输入旅途名称", existing_names)
	_reset_auto_hide_timer()


func _on_start_button_pressed() -> void:
	var current_project: ProjectData = project_selector.get_current_project()
	if current_project:
		focus_manager.start_focus(current_project)
	_reset_auto_hide_timer()


func _on_cancel_button_long_pressed() -> void:
	"""长按取消按钮完成后直接取消专注"""
	focus_manager.cancel_focus()
	_reset_auto_hide_timer()


func _on_pause_button_pressed() -> void:
	focus_manager.pause_focus()
	_reset_auto_hide_timer()


func _on_resume_button_pressed() -> void:
	focus_manager.resume_focus()
	_reset_auto_hide_timer()


func _on_complete_button_long_pressed() -> void:
	"""长按完成按钮完成后直接完成专注"""
	focus_manager.complete_focus()
	_reset_auto_hide_timer()

# === 弹窗事件处理 ===

var pending_modal_action: String = ""
var pending_project_to_delete: ProjectData


func _on_input_modal_confirmed(text: String) -> void:
	# 创建新项目
	var project_id: int = database_manager.create_project(text)
	if project_id > 0:
		_load_projects()
		# 选中新创建的项目
		var projects: Array[ProjectData] = database_manager.get_all_projects()
		for i in range(projects.size()):
			if projects[i].id == project_id:
				project_selector.set_current_index(i)
				break


func _on_input_modal_cancelled() -> void:
	pass


func _on_confirm_modal_confirmed() -> void:
	match pending_modal_action:
		"delete_project":
			if pending_project_to_delete:
				database_manager.delete_project(pending_project_to_delete.id)
				_load_projects()
				pending_project_to_delete = null

	pending_modal_action = ""


func _on_confirm_modal_cancelled() -> void:
	pending_modal_action = ""
	pending_project_to_delete = null


# === 专注管理器事件处理 ===

func _on_focus_started(_project: ProjectData) -> void:
	# 专注开始时设置UI状态并重置计时器显示
	_set_ui_state(UIState.FOCUSING)
	focus_timer.reset()


func _on_focus_paused() -> void:
	_update_focus_buttons()


func _on_focus_resumed() -> void:
	_update_focus_buttons()


func _on_focus_completed(session: FocusSessionData) -> void:
	# 保存会话数据
	database_manager.create_focus_session(session)

	# 重新加载项目数据（更新总时长）
	_load_projects()

	# 回到初始状态
	_set_ui_state(UIState.IDLE)


func _on_focus_cancelled() -> void:
	_set_ui_state(UIState.IDLE)


func _on_time_updated(elapsed_seconds: int) -> void:
	focus_timer.update_display(elapsed_seconds)


func _on_auto_hide_timeout() -> void:
	hide_ui()


## 如果正在专注则自动暂停
func _pause_if_focusing() -> void:
	if current_state == UIState.FOCUSING and focus_manager.get_current_state() == FocusManager.FocusState.RUNNING:
		focus_manager.pause_focus()


## 清理资源
func _exit_tree() -> void:
	if database_manager:
		database_manager.close()
	if focus_manager:
		focus_manager.cleanup()
