@tool
extends Node

# Простой HTTP сервер для обработки команд от Python бэкенда
var server: HTTPServer
var is_running := false

func _ready() -> void:
	# Сервер будет запускаться по требованию
	pass

func start_server(port: int = 6007) -> Error:
	if is_running:
		return OK
	
	# Инициализация сервера (реализация зависит от версии Godot)
	# В Godot 4.x можно использовать ENet или WebSocket для двусторонней связи
	print("AI_Yandex Server готов к запуску на порту: ", port)
	is_running = true
	return OK

func stop_server() -> void:
	is_running = false
	print("AI_Yandex Server остановлен")

func process_command(command: String) -> Dictionary:
	# Обработка входящих команд от AI
	var result := {
		"success": true,
		"message": "Команда выполнена: " + command
	}
	
	# Парсинг команды и выполнение действий в редакторе
	if command.contains("создай сцену"):
		_create_new_scene()
	elif command.contains("добавь ноду"):
		_add_node_to_scene()
	elif command.contains("запусти"):
		_run_project()
	
	return result

func _create_new_scene() -> void:
	var new_scene := Scene.new()
	var root_node := Node3D.new()
	root_node.name = "Main"
	new_scene.add_child(root_node)
	# Сохранение сцены будет реализовано через EditorInterface

func _add_node_to_scene() -> void:
	# Добавление новой ноды в текущую сцену
	var editor_interface := Engine.get_meta("EditorInterface") as EditorInterface
	if editor_interface:
		var current_scene := editor_interface.get_edited_scene_root()
		if current_scene:
			var new_node := Node3D.new()
			new_node.name = "NewNode"
			current_scene.add_child(new_node)

func _run_project() -> void:
	var editor_interface := Engine.get_meta("EditorInterface") as EditorInterface
	if editor_interface:
		editor_interface.play_main_scene()
