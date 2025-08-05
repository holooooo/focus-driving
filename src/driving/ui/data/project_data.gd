class_name ProjectData
extends RefCounted

## 项目数据模型
## 用于表示单个项目的数据结构

var id: int
var name: String
var total_focus_time: int  # 总专注时长，单位：秒

func _init(p_id: int = 0, p_name: String = "", p_total_focus_time: int = 0) -> void:
	id = p_id
	name = p_name
	total_focus_time = p_total_focus_time

## 验证项目名称是否有效
## 检查长度限制和非空条件
func is_valid_name() -> bool:
	return name.length() > 0 and name.length() <= 25

## 获取格式化的总专注时长
## 返回 HH:MM:SS 格式的字符串
func get_formatted_total_time() -> String:
	var hours: int = total_focus_time / 3600
	var minutes: int = (total_focus_time % 3600) / 60
	var seconds: int = total_focus_time % 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds]

## 从字典创建ProjectData实例
## 用于数据库查询结果转换
static func from_dict(data: Dictionary) -> ProjectData:
	return ProjectData.new(
		data.get("id", 0),
		data.get("name", ""),
		data.get("total_focus_time", 0)
	)

## 转换为字典格式
## 用于数据库插入/更新操作
func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"total_focus_time": total_focus_time
	}
