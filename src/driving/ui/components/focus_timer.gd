class_name FocusTimer
extends Control

## 专注计时器UI组件
## 显示当前专注会话的时长

@onready var time_label: Label = $TimeLabel

var current_seconds: int = 0

func _ready() -> void:
	# 初始显示
	update_display(0)

## 更新时间显示
## [br]时间格式为 HH:MM:SS
func update_display(seconds: int) -> void:
	current_seconds = seconds
	var hours: int = seconds / 3600
	var minutes: int = (seconds % 3600) / 60
	var secs: int = seconds % 60
	if hours == 0:
		time_label.text = "%02d:%02d" % [minutes, secs]
	else:
		time_label.text = "%02d:%02d:%02d" % [hours, minutes, secs]

## 重置计时器显示
func reset() -> void:
	update_display(0)
