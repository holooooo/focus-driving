class_name InputModal
extends Control

## 输入弹窗组件
## 提供文本输入对话框功能

signal confirmed(text: String)
signal cancelled()

@onready var background: ColorRect = $Background
@onready var panel: Panel = $CenterContainer/Panel
@onready var title_label: Label = $CenterContainer/Panel/VBoxContainer/TitleLabel
@onready var input_field: LineEdit = $CenterContainer/Panel/VBoxContainer/InputField
@onready var error_label: Label = $CenterContainer/Panel/VBoxContainer/ErrorLabel
@onready var button_container: HBoxContainer = $CenterContainer/Panel/VBoxContainer/ButtonContainer
@onready var confirm_button: Button = $CenterContainer/Panel/VBoxContainer/ButtonContainer/ConfirmButton
@onready var cancel_button: Button = $CenterContainer/Panel/VBoxContainer/ButtonContainer/CancelButton

var max_length: int = 25
var existing_names: Array[String] = []

func _ready() -> void:
	# 连接信号
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	input_field.text_changed.connect(_on_text_changed)
	input_field.text_submitted.connect(_on_text_submitted)
	background.gui_input.connect(_on_background_input)
	
	# 初始隐藏
	hide()
	error_label.hide()

## 显示输入弹窗
func show_input(title: String, placeholder: String = "", existing_names_list: Array[String] = []) -> void:
	title_label.text = title
	input_field.placeholder_text = placeholder
	input_field.text = ""
	existing_names = existing_names_list
	error_label.hide()
	
	show()
	# 简单的淡入效果
	var tween = create_tween()
	modulate.a = 0.0
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
	
	# 自动聚焦输入框
	await get_tree().process_frame
	input_field.grab_focus()

## 隐藏弹窗
func hide_modal() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	await tween.finished
	hide()

## 验证输入内容
func _validate_input(text: String) -> String:
	if text.is_empty():
		return "项目名称不能为空"
	
	if text.length() > max_length:
		return "项目名称不能超过%d个字符" % max_length
	
	if text in existing_names:
		return "项目名称已存在"
	
	return ""

func _on_text_changed(new_text: String) -> void:
	var error = _validate_input(new_text)
	if error.is_empty():
		error_label.hide()
		confirm_button.disabled = false
	else:
		error_label.text = error
		error_label.show()
		confirm_button.disabled = true

func _on_confirm_pressed() -> void:
	var text = input_field.text.strip_edges()
	var error = _validate_input(text)
	
	if error.is_empty():
		confirmed.emit(text)
		hide_modal()

func _on_cancel_pressed() -> void:
	cancelled.emit()
	hide_modal()

func _on_text_submitted(text: String) -> void:
	if not confirm_button.disabled:
		_on_confirm_pressed()

func _on_background_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		cancelled.emit()
		hide_modal()
