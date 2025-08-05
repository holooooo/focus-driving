extends Node2D

enum City {
	CITY_A,
	CITY_B,
	CITY_C,
	CITY_D,
	CITY_E
}
enum Stage {
	CityRoad,
	Highway,
	CountryRoad,
}
@export var city: City
@export var stage: Stage
@export var TotalDistance: float = 0.0
@export var car: CarResource

@export var speed_scale: float = 1:
	set(value):
		speed_scale = value
		setup_speed()

@onready var background: Node2D = $Background
@onready var focus_ui: FocusUI = $FocusUI

var current_distance: float = 0.0

func _ready() -> void:
	setup_speed()
	# 连接专注UI信号
	if focus_ui:
		focus_ui.ui_state_changed.connect(_on_focus_ui_state_changed)

func setup_speed()->void:
	if !background:
		return
	var children: Array[Node] = background.get_children()
	for child in children:
		if child is Parallax2D:
			child.autoscroll *= speed_scale

## 处理专注UI状态变化
## [br]根据UI显示状态调整驾驶场景的行为
func _on_focus_ui_state_changed(is_visible: bool) -> void:
	# UI显示时可以暂停背景动画或降低速度
	# UI隐藏时恢复正常
	if is_visible:
		# 可以在这里添加UI显示时的场景调整逻辑
		pass
	else:
		# 可以在这里添加UI隐藏时的场景恢复逻辑
		pass
