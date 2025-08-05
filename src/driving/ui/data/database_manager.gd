class_name DatabaseManager
extends RefCounted

## SQLite数据库管理器
## 负责所有数据库操作，包括表创建、CRUD操作等

const DB_PATH = "res://tmp/focus_driving.db"

var db: SQLite

func _init() -> void:
	db = SQLite.new()
	_initialize_database()

## 初始化数据库
## 创建数据库文件和必要的表结构
func _initialize_database() -> void:
	db.path = DB_PATH
	if not db.open_db():
		push_error("无法打开数据库: " + DB_PATH)
		return
	
	_create_tables()
	_ensure_default_project()

## 创建数据库表结构
func _create_tables() -> void:
	# 创建项目表
	var projects_sql = """
		CREATE TABLE IF NOT EXISTS projects (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			name TEXT NOT NULL UNIQUE,
			total_focus_time INTEGER DEFAULT 0
		)
	"""
	
	# 创建专注会话表
	var sessions_sql = """
		CREATE TABLE IF NOT EXISTS focus_sessions (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			project_id INTEGER NOT NULL,
			note TEXT DEFAULT '',
			start_time INTEGER NOT NULL,
			duration INTEGER NOT NULL,
			created_at INTEGER NOT NULL,
			FOREIGN KEY (project_id) REFERENCES projects (id)
		)
	"""
	
	db.query(projects_sql)
	db.query(sessions_sql)

## 确保存在默认项目
## 如果没有项目，自动创建名为"默认"的项目
func _ensure_default_project() -> void:
	var projects = get_all_projects()
	if projects.is_empty():
		create_project("默认")

## 创建新项目
## 返回创建的项目ID，失败返回-1
func create_project(name: String) -> int:
	if name.length() > 25 or name.is_empty():
		push_warning("项目名称无效: " + name)
		return -1
	
	# 检查是否重名
	if is_project_name_exists(name):
		push_warning("项目名称已存在: " + name)
		return -1
	
	var sql = "INSERT INTO projects (name, total_focus_time) VALUES (?, 0)"
	db.query_with_bindings(sql, [name])
	
	return db.last_insert_rowid

## 检查项目名称是否已存在
func is_project_name_exists(name: String) -> bool:
	var sql = "SELECT COUNT(*) as count FROM projects WHERE name = ?"
	if not db.query_with_bindings(sql, [name]):
		push_error("查询项目名称失败: " + db.error_message)
		return false
	
	if not error_message().is_empty():
		push_error("查询项目名称失败: " + db.error_message)
		return false
	
	var result = db.query_result
	return result.size() > 0 and result[0]["count"] > 0

## 获取所有项目
## 返回ProjectData数组
func get_all_projects() -> Array[ProjectData]:
	var sql = "SELECT * FROM projects ORDER BY id"
	if not db.query(sql):
		push_error("查询所有项目失败: " + db.error_message)
		return []
	
	if not error_message().is_empty():
		push_error("查询所有项目失败: " + db.error_message)
		return []
	
	var result = db.query_result
	var projects: Array[ProjectData] = []
	
	for row in result:
		projects.append(ProjectData.from_dict(row))
	
	return projects

## 根据ID获取项目
func get_project_by_id(id: int) -> ProjectData:
	var sql = "SELECT * FROM projects WHERE id = ?"
	if not db.query_with_bindings(sql, [id]):
		push_error("根据ID查询项目失败: " + db.error_message)
		return null
	
	if not error_message().is_empty():
		push_error("根据ID查询项目失败: " + db.error_message)
		return null
	
	var result = db.query_result
	if result.size() > 0:
		return ProjectData.from_dict(result[0])
	else:
		return null

## 更新项目信息
func update_project(project: ProjectData) -> bool:
	var sql = "UPDATE projects SET name = ?, total_focus_time = ? WHERE id = ?"
	db.query_with_bindings(sql, [project.name, project.total_focus_time, project.id])
	return error_message().is_empty()

## 删除项目
## 同时删除关联的专注会话
func delete_project(id: int) -> bool:
	# 先删除关联的会话
	var delete_sessions_sql = "DELETE FROM focus_sessions WHERE project_id = ?"
	db.query_with_bindings(delete_sessions_sql, [id])
	
	# 删除项目
	var delete_project_sql = "DELETE FROM projects WHERE id = ?"
	db.query_with_bindings(delete_project_sql, [id])
	
	return error_message().is_empty()

## 创建新的专注会话
func create_focus_session(session: FocusSessionData) -> int:
	var sql = """
		INSERT INTO focus_sessions (project_id, note, start_time, duration, created_at) 
		VALUES (?, ?, ?, ?, ?)
	"""
	
	db.query_with_bindings(sql, [
		session.project_id,
		session.note,
		session.start_time,
		session.duration,
		session.created_at
	])
	
	# 更新项目的总专注时长
	_update_project_total_time(session.project_id)
	
	return db.last_insert_rowid

## 更新项目的总专注时长
func _update_project_total_time(project_id: int) -> void:
	var sql = """
		UPDATE projects 
		SET total_focus_time = (
			SELECT COALESCE(SUM(duration), 0) 
			FROM focus_sessions 
			WHERE project_id = ?
		) 
		WHERE id = ?
	"""
	
	db.query_with_bindings(sql, [project_id, project_id])

## 获取项目的专注会话列表
func get_project_sessions(project_id: int) -> Array[FocusSessionData]:
	var sql = "SELECT * FROM focus_sessions WHERE project_id = ? ORDER BY created_at DESC"
	if not db.query_with_bindings(sql, [project_id]):
		push_error("查询项目会话失败: " + db.error_message)
		return []
	
	if not error_message().is_empty():
		push_error("查询项目会话失败: " + db.error_message)
		return []
	
	var result = db.query_result
	var sessions: Array[FocusSessionData] = []
	
	for row in result:
		sessions.append(FocusSessionData.from_dict(row))
	
	return sessions

## 关闭数据库连接
func close() -> void:
	if db:
		db.close()

		
func error_message() -> String:
	if db.error_message == "not an error":
		return ""
	return db.error_message
