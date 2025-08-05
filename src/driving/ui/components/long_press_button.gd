class_name LongPressButton
extends Button

## 长按按钮组件
## 支持长按确认操作，在点击位置动态创建环形进度条

signal long_press_completed()
signal long_press_started()
signal long_press_cancelled()
@export var long_press_duration: float = 3.0  # 长按持续时间（秒）
@export var progress_color: Color = Color(0.23529412, 0.2509804, 0.7764706, 1) # 进度条颜色
@export var progress_width: float = 20.0  # 进度条宽度
@export var progress_radius: float = 48.0  # 进度条半径

var is_pressing: bool  = false
var press_timer: float = 0.0
var progress_indicator: Control
var click_position: Vector2
var tween: Tween


func _ready() -> void:
	# 连接按钮事件
	gui_input.connect(_on_gui_input)


func _process(delta: float) -> void:
	if is_pressing:
		press_timer += delta

		# 更新进度条显示
		if progress_indicator:
			progress_indicator.queue_redraw()

		# 检查是否完成长按
		if press_timer >= long_press_duration:
			_complete_long_press()


func _on_gui_input(event: InputEvent) -> void:
	"""处理GUI输入事件"""
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# 记录点击位置（相对于屏幕的全局位置）
			click_position = event.global_position
			_start_long_press()
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_cancel_long_press()


func _start_long_press() -> void:
	"""开始长按计时"""
	is_pressing = true
	press_timer = 0.0
	_create_progress_indicator()
	long_press_started.emit()

	# 添加按钮按下的视觉反馈
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.1)


func _create_progress_indicator() -> void:
	"""在点击位置创建进度条指示器"""
	# 获取根节点（通常是场景的主节点）
	var root = get_tree().current_scene
	if not root:
		print("无法获取根节点")
		return

	# 创建进度条节点
	progress_indicator = Control.new()
	progress_indicator.name = "LongPressProgressIndicator"
	progress_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress_indicator.size = Vector2(progress_radius * 2, progress_radius * 2)
	progress_indicator.position = click_position - Vector2(progress_radius, progress_radius)

	# 设置高z-index确保显示在最前面
	progress_indicator.z_index = 1000

	# 确保不受父节点透明度影响
	progress_indicator.modulate = Color.WHITE

	# 连接绘制信号
	progress_indicator.draw.connect(_draw_progress_indicator)

	# 添加到根节点而不是按钮本身
	owner.add_child(progress_indicator)
	

func _complete_long_press() -> void:
	"""完成长按操作"""
	is_pressing = false
	_destroy_progress_indicator()
	long_press_completed.emit()

	# 恢复按钮大小
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)


func _cancel_long_press() -> void:
	"""取消长按操作"""
	if not is_pressing:
		return

	is_pressing = false
	press_timer = 0.0
	_destroy_progress_indicator()
	long_press_cancelled.emit()

	# 恢复按钮大小
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)


func _destroy_progress_indicator() -> void:
	"""销毁进度条指示器"""
	if progress_indicator:
		progress_indicator.queue_free()
		progress_indicator = null


func _draw_progress_indicator() -> void:
	"""绘制环形进度条"""
	if not is_pressing or not progress_indicator:
		return

	var progress: float = press_timer / long_press_duration
	var center: Vector2 = Vector2(progress_radius, progress_radius)
	var radius: float   = progress_radius - progress_width / 2

	# 绘制背景圆环（更明显的颜色）
	progress_indicator.draw_arc(center, radius, 0, 2 * PI, 64,  Color(1, 1, 0, 0), progress_width)

	# 绘制进度圆环
	var angle_from: float = -PI / 2  # 从顶部开始
	var angle_to: float   = angle_from + (2 * PI * progress)

	if progress > 0:
		progress_indicator.draw_arc(center, radius, angle_from, angle_to, 64, progress_color, progress_width)

	# 绘制中心点作为参考
	progress_indicator.draw_circle(center, 5, Color.YELLOW)
	
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_MOUSE_EXIT:
			# 鼠标离开时取消长按
			if is_pressing:
				_cancel_long_press()


## 设置长按持续时间
func set_long_press_duration(duration: float) -> void:
	long_press_duration = duration


## 设置进度条颜色
func set_progress_color(color: Color) -> void:
	progress_color = color


## 设置进度条宽度
func set_progress_width(width: float) -> void:
	progress_width = width


## 获取当前长按进度（0.0 到 1.0）
func get_press_progress() -> float:
	if not is_pressing:
		return 0.0
	return press_timer / long_press_duration


## 是否正在长按
func is_long_pressing() -> bool:
	return is_pressing
