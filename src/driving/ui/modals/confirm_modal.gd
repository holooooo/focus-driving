class_name ConfirmModal
extends Control

## 确认弹窗组件
## 提供简单的确认/取消对话框功能

signal confirmed()
signal cancelled()

@onready var background: ColorRect = $Background
@onready var panel: Panel = $CenterContainer/Panel
@onready var title_label: Label = $CenterContainer/Panel/VBoxContainer/TitleLabel
@onready var message_label: Label = $CenterContainer/Panel/VBoxContainer/MessageLabel
@onready var button_container: HBoxContainer = $CenterContainer/Panel/VBoxContainer/ButtonContainer
@onready var confirm_button: Button = $CenterContainer/Panel/VBoxContainer/ButtonContainer/ConfirmButton
@onready var cancel_button: Button = $CenterContainer/Panel/VBoxContainer/ButtonContainer/CancelButton

func _ready() -> void:
	# 连接按钮信号
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	
	# 点击背景关闭
	background.gui_input.connect(_on_background_input)
	
	# 初始隐藏
	hide()

## 显示确认弹窗
func show_confirm(title: String, message: String, confirm_text: String = "确认", cancel_text: String = "取消") -> void:
	title_label.text = title
	message_label.text = message
	confirm_button.text = confirm_text
	cancel_button.text = cancel_text
	
	show()
	# 简单的淡入效果
	var tween = create_tween()
	modulate.a = 0.0
	tween.tween_property(self, "modulate:a", 1.0, 0.2)

## 隐藏弹窗
func hide_modal() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	await tween.finished
	hide()

func _on_confirm_pressed() -> void:
	confirmed.emit()
	hide_modal()

func _on_cancel_pressed() -> void:
	cancelled.emit()
	hide_modal()

func _on_background_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		cancelled.emit()
		hide_modal()
