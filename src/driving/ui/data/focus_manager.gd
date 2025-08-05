class_name FocusManager
extends RefCounted

## 专注会话管理器
## 负责专注会话的业务逻辑，包括计时、状态管理等

signal focus_started(project: ProjectData)
signal focus_paused()
signal focus_resumed()
signal focus_completed(session: FocusSessionData)
signal focus_cancelled()
signal time_updated(elapsed_seconds: int)

enum FocusState {
	IDLE,       # 空闲状态
	RUNNING,    # 专注进行中
	PAUSED      # 暂停状态
}

var current_state: FocusState = FocusState.IDLE
var current_project: ProjectData
var start_time: int
var elapsed_seconds: int
var pause_start_time: int
var total_pause_duration: int

var timer: Timer

func _init() -> void:
	timer = Timer.new()
	timer.wait_time = 1.0  # 每秒更新一次
	timer.timeout.connect(_on_timer_timeout)

## 开始专注会话
func start_focus(project: ProjectData) -> void:
	if current_state != FocusState.IDLE:
		push_warning("当前已有专注会话进行中")
		return
	
	current_project = project
	start_time = int(Time.get_unix_time_from_system())
	elapsed_seconds = 0
	total_pause_duration = 0
	current_state = FocusState.RUNNING
	
	timer.start()
	focus_started.emit(project)

## 暂停专注会话
func pause_focus() -> void:
	if current_state != FocusState.RUNNING:
		push_warning("当前没有进行中的专注会话")
		return
	
	current_state = FocusState.PAUSED
	pause_start_time = int(Time.get_unix_time_from_system())
	timer.stop()
	focus_paused.emit()

## 恢复专注会话
func resume_focus() -> void:
	if current_state != FocusState.PAUSED:
		push_warning("当前没有暂停的专注会话")
		return
	
	current_state = FocusState.RUNNING
	# 累计暂停时长
	total_pause_duration += int(Time.get_unix_time_from_system()) - pause_start_time
	timer.start()
	focus_resumed.emit()

## 完成专注会话
func complete_focus(note: String = "") -> void:
	if current_state == FocusState.IDLE:
		push_warning("当前没有专注会话")
		return
	
	# 如果是暂停状态，先计算暂停时长
	if current_state == FocusState.PAUSED:
		total_pause_duration += int(Time.get_unix_time_from_system()) - pause_start_time
	
	timer.stop()
	
	# 创建会话数据
	var session = FocusSessionData.new()
	session.project_id = current_project.id
	session.note = note
	session.start_time = start_time
	session.duration = elapsed_seconds
	session.created_at = int(Time.get_unix_time_from_system())
	
	# 重置状态
	_reset_state()
	
	focus_completed.emit(session)

## 取消专注会话
func cancel_focus() -> void:
	if current_state == FocusState.IDLE:
		push_warning("当前没有专注会话")
		return
	
	timer.stop()
	_reset_state()
	focus_cancelled.emit()

## 重置状态
func _reset_state() -> void:
	current_state = FocusState.IDLE
	current_project = null
	start_time = 0
	elapsed_seconds = 0
	pause_start_time = 0
	total_pause_duration = 0

## 获取当前专注状态
func get_current_state() -> FocusState:
	return current_state

## 获取格式化的经过时间
func get_formatted_elapsed_time() -> String:
	var hours: int = elapsed_seconds / 3600
	var minutes: int = (elapsed_seconds % 3600) / 60
	var seconds: int = elapsed_seconds % 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds]

## 获取当前项目
func get_current_project() -> ProjectData:
	return current_project

## 定时器回调
func _on_timer_timeout() -> void:
	if current_state == FocusState.RUNNING:
		elapsed_seconds += 1
		time_updated.emit(elapsed_seconds)

## 清理资源
func cleanup() -> void:
	if timer:
		timer.stop()
		timer = null
