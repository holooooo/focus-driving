extends Node
class_name CarGenerator
@export var car_scenes: Array[PackedScene] = [] # 车辆场景列表
@export var max_npc: int = 2
@export var min_speed: float = 800
@export var max_speed: float = 1600
@export var spawn_interval: float = 3
@export var screen_left: float = -3000
@export var screen_right: float = 3000
@export var postion_y: float = 90

var npc_count: int     = 0
var spawn_timer: float = 0.0


func _process(delta: float) -> void:
	spawn_timer += delta
	if npc_count < max_npc and spawn_timer >= spawn_interval:
		spawn_timer = 0
		_spawn_npc()
	# 回收驶出画面的车辆
	for child in get_children():
		if child is Car:
			if child.global_position.x < screen_left or child.global_position.x > screen_right:
				child.queue_free()
				npc_count -= 1


func _spawn_npc() -> void:
	if car_scenes.size() == 0:
		return
	var scene: PackedScene = car_scenes[randi() % car_scenes.size()]
	var car: Car       = scene.instantiate()
	var is_right: bool = randi() % 2 == 0 # true右，false左
	car.scale *= 0.95
	if is_right:
		car.car_state = car.CarState.RIGHT
		car.drive_speed = randf_range(min_speed, max_speed)
		car.global_position = Vector2(screen_left, postion_y)
		car.z_index = 11
		var slow_car: bool = randi() % 2 == 0
		if slow_car:
			car.global_position = Vector2(screen_right, postion_y)
			car.drive_speed *= -0.5 # 减速车
			car.z_index = 9
	else:
		car.car_state = car.CarState.LEFT
		car.drive_speed = randf_range(min_speed, max_speed)
		car.global_position = Vector2(screen_right, postion_y)
		car.z_index = 8
	npc_count += 1
	add_child(car)
