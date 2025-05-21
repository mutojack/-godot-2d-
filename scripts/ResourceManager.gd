extends Node

# 资源目录路径
var basic_path := "res://resouces/drop/"
# 资源字典，键为id，值为资源对象
var items := {}

func _ready():
	load_all_resources()

# 加载所有资源
func load_all_resources():
	var dir = DirAccess.open(basic_path)
	if not dir:
		push_warning("无法打开资源目录: %s" % basic_path)
		return
	
	items.clear()  # 清空现有资源
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not file_name.begins_with(".") and file_name.ends_with(".tres"):
			var resource_path = basic_path.path_join(file_name)
			var res = load(resource_path)
			if not res:
				push_warning("加载资源失败: %s" % resource_path)
			elif res.id:
				items[res.id] = res
			else:
				push_warning("资源缺少id属性: %s" % resource_path)
		file_name = dir.get_next()
	dir.list_dir_end()

# 根据ID获取资源
func get_item(id: String) -> Resource:
	return items.get(id)

# 重新加载资源（开发时可用）
func reload_resources():
	load_all_resources()
