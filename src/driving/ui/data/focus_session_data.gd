class_name FocusSessionData
extends RefCounted

## 专注会话数据模型
## 用于表示单个专注会话的数据结构

var id: int
var project_id: int
var note: String
var start_time: int     # 开始时间戳
var duration: int       # 会话时长，单位：秒
var created_at: int     # 创建时间戳

func _init(p_id: int = 0, p_project_id: int = 0, p_note: String = "", 
		   p_start_time: int = 0, p_duration: int = 0, p_created_at: int = 0) -> void:
	id = p_id
	project_id = p_project_id
	note = p_note
	start_time = p_start_time
	duration = p_duration
	created_at = p_created_at

## 获取格式化的会话时长
## 返回 HH:MM:SS 格式的字符串
func get_formatted_duration() -> String:
	var hours: int = duration / 3600
	var minutes: int = (duration % 3600) / 60
	var seconds: int = duration % 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds]

## 获取格式化的开始时间
## 返回可读的日期时间字符串
func get_formatted_start_time() -> String:
	var datetime = Time.get_datetime_dict_from_unix_time(start_time)
	return "%04d-%02d-%02d %02d:%02d:%02d" % [
		datetime.year, datetime.month, datetime.day,
		datetime.hour, datetime.minute, datetime.second
	]

## 从字典创建FocusSessionData实例
## 用于数据库查询结果转换
static func from_dict(data: Dictionary) -> FocusSessionData:
	return FocusSessionData.new(
		data.get("id", 0),
		data.get("project_id", 0),
		data.get("note", ""),
		data.get("start_time", 0),
		data.get("duration", 0),
		data.get("created_at", 0)
	)

## 转换为字典格式
## 用于数据库插入/更新操作
func to_dict() -> Dictionary:
	return {
		"id": id,
		"project_id": project_id,
		"note": note,
		"start_time": start_time,
		"duration": duration,
		"created_at": created_at
	}
