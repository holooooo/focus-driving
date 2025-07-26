extends Sprite2D


@onready var front_wheel: Sprite2D = $FrontWheel
@onready var back_wheel: Sprite2D = $BackWheel

@export var roll_speed: float = 60

@export var flip: bool = false:
	set(value):
		flip = value
		flip_car()

enum CarState { LEFT, RIGHT, CENTER, STOP }

@export var car_state: CarState = CarState.CENTER:
	set(value):
		if car_state != value:
			car_state = value
			_on_state_changed()

@export var drive_speed: float = 200 # px/s
@export var center_scale: float = 1.0
@export var stop_scale: float = 1.2

var target_roll_speed: float = 60
var anim_time: float         = 0.3 # 动画时长
var anim_timer: float        = 0.0
var animating: bool          = false
var start_scale: float       = 1.0
var end_scale: float         = 1.0
var start_roll_speed: float  = 60
var end_roll_speed: float    = 60

@onready var original_y: float = position.y
@onready var original_scale: Vector2 = scale


func _ready() -> void:
	# 记录原始位置
	flip_car()
	set_scale(Vector2(center_scale*original_scale.x, center_scale*original_scale.y))


func _process(delta: float) -> void:
	if animating:
		anim_timer += delta
		var t = clamp(anim_timer / anim_time, 0, 1)
		roll_speed = lerp(start_roll_speed, end_roll_speed, t)
		var s = lerp(start_scale, end_scale, t)
		set_scale(Vector2(s, s))
		if t >= 1:
			animating = false
	else:
		match car_state:
			CarState.LEFT:
				flip = true
				position.x -= drive_speed * delta
				roll_speed = target_roll_speed
			CarState.RIGHT:
				flip = false
				position.x += drive_speed * delta
				roll_speed = target_roll_speed
			CarState.CENTER:
				flip = false
				roll_speed = target_roll_speed
			# x不动
			CarState.STOP:
				roll_speed = 0
	# x不动
	rolling_wheel(delta)


func _on_state_changed():
	if car_state == CarState.STOP:
		# 居中到停止，轮速渐变为0，放大动画
		animating = true
		anim_timer = 0
		start_scale = center_scale * original_scale.x
		end_scale = stop_scale * original_scale.x
		start_roll_speed = target_roll_speed
		end_roll_speed = 0
	elif car_state == CarState.CENTER:
		# 停止到居中，轮速渐变为正常，缩小动画
		animating = true
		anim_timer = 0
		start_scale = stop_scale * original_scale.x
		end_scale = center_scale * original_scale.x
		start_roll_speed = 0
		end_roll_speed = target_roll_speed


func rolling_wheel(delta: float) -> void:
	if roll_speed == 0:
		# 如果轮速为0，直接返回
		return
	# 旋转前后轮
	front_wheel.rotation += roll_speed * delta
	back_wheel.rotation += roll_speed * delta
	# 使汽车偶尔上下抖动
	var shake_amount: float   = 2
	var shake_offset: Vector2 = Vector2(position.x,
	original_y+ randf_range(0, shake_amount))
	position.y = shake_offset.y


func flip_car() -> void:
	# 翻转汽车
	if flip:
		scale.x = -abs(scale.x)
	else:
		scale.x = abs(scale.x)
