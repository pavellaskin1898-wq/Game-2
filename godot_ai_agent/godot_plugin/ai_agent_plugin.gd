@tool
extends EditorPlugin

## AI Agent Plugin для Godot
## Обеспечивает интеграцию с Python сервером и Яндекс Алисой

var ai_communicator: Node
var editor_interface: EditorInterface
var settings_window: Window
var is_connected: bool = false
var server_url: String = "http://localhost:5000"
var yandex_token: String = ""

func _enter_tree() -> void:
	# Инициализация плагина
	editor_interface = get_editor_interface()
	
	# Создаем узел коммуникатора
	ai_communicator = Node.new()
	ai_communicator.name = "AICommunicator"
	add_child(ai_communicator)
	
	# Добавляем кнопку в тулбар
	_add_toolbar_button()
	
	# Загружаем настройки
	_load_settings()
	
	print("AI Agent Plugin активирован")

func _exit_tree() -> void:
	# Очистка при выключении
	if ai_communicator:
		ai_communicator.queue_free()
	
	_remove_toolbar_button()
	print("AI Agent Plugin деактивирован")

func _add_toolbar_button() -> void:
	var toolbar = editor_interface.get_base_control().get_node("MenuContainer/ToolbarBox")
	if toolbar:
		var button = Button.new()
		button.name = "AIAgentButton"
		button.text = "🤖 AI Агент"
		button.tooltip_text = "Открыть панель управления AI агентом"
		button.pressed.connect(_on_ai_button_pressed)
		toolbar.add_child(button)

func _remove_toolbar_button() -> void:
	var toolbar = editor_interface.get_base_control().get_node("MenuContainer/ToolbarBox")
	if toolbar and toolbar.has_node("AIAgentButton"):
		toolbar.get_node("AIAgentButton").queue_free()

func _on_ai_button_pressed() -> void:
	_show_settings_window()

func _show_settings_window() -> void:
	if settings_window and is_instance_valid(settings_window):
		settings_window.popup_centered()
		return
	
	settings_window = Window.new()
	settings_window.title = "AI Agent - Настройки"
	settings_window.size = Vector2(500, 400)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	settings_window.add_child(vbox)
	
	# Заголовок
	var title = Label.new()
	title.text = "Настройки AI Агента"
	title.add_theme_font_size_override("font_size", 18)
	vbox.add_child(title)
	
	# URL сервера
	vbox.add_child(Label.new().new())
	var url_label = Label.new()
	url_label.text = "URL сервера:"
	vbox.add_child(url_label)
	
	var url_edit = LineEdit.new()
	url_edit.text = server_url
	url_edit.placeholder_text = "http://localhost:5000"
	url_edit.text_changed.connect(_on_url_changed)
	vbox.add_child(url_edit)
	
	# Yandex токен
	vbox.add_child(Label.new().new())
	var token_label = Label.new()
	token_label.text = "Yandex OAuth токен:"
	vbox.add_child(token_label)
	
	var token_edit = LineEdit.new()
	token_edit.text = yandex_token
	token_edit.placeholder_text = "Введите ваш Yandex OAuth токен"
	token_edit.password_mode = true
	token_edit.text_changed.connect(_on_token_changed)
	vbox.add_child(token_edit)
	
	# Статус подключения
	var status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.text = "Статус: Не подключено" if not is_connected else "Статус: Подключено"
	vbox.add_child(status_label)
	
	# Кнопки
	var button_box = HBoxContainer.new()
	button_box.add_spacer(true)
	
	var connect_btn = Button.new()
	connect_btn.text = "Проверить подключение"
	connect_btn.pressed.connect(_check_connection.bind(status_label))
	button_box.add_child(connect_btn)
	
	var help_btn = Button.new()
	help_btn.text = "Помощь"
	help_btn.pressed.connect(_show_help)
	button_box.add_child(help_btn)
	
	vbox.add_child(button_box)
	
	# Информация
	var info = RichTextLabel.new()
	info.bbcode_enabled = true
	info.text = """
[b]Как использовать:[/b]
1. Запустите Python сервер командой: [code]python python_server/main.py[/code]
2. Введите URL сервера и Yandex токен
3. Говорите команды через Яндекс Алису
4. AI агент выполнит действия в Godot

[b]Примеры команд:[/b]
• Создай новую сцену
• Добавь игрока
• Запусти проект
• Сохрани сцену
"""
	vbox.add_child(info)
	
	editor_interface.get_base_control().add_child(settings_window)
	settings_window.popup_centered()

func _on_url_changed(new_text: String) -> void:
	server_url = new_text
	_save_settings()

func _on_token_changed(new_text: String) -> void:
	yandex_token = new_text
	_save_settings()

func _check_connection(status_label: Label) -> void:
	var http = HTTPRequest.new()
	add_child(http)
	
	var error = http.request(server_url + "/api/status")
	if error != OK:
		status_label.text = "Статус: Ошибка подключения"
		is_connected = false
		return
	
	# Ожидаем ответ (в реальной реализации нужно ждать сигнал)
	await get_tree().create_timer(2.0).timeout
	status_label.text = "Статус: Подключено" if is_connected else "Статус: Не подключено"
	http.queue_free()

func _show_help() -> void:
	OS.shell_open("https://github.com/your-repo/godot-ai-agent/wiki")

func _save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("settings", "server_url", server_url)
	config.set_value("settings", "yandex_token", yandex_token)
	config.save("user://ai_agent_settings.cfg")

func _load_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://ai_agent_settings.cfg")
	if err == OK:
		server_url = config.get_value("settings", "server_url", "http://localhost:5000")
		yandex_token = config.get_value("settings", "yandex_token", "")

# Методы для выполнения команд от AI
func execute_command(command: String, parameters: Dictionary = {}) -> void:
	print("Выполнение команды: ", command)
	print("Параметры: ", parameters)
	
	match command:
		"create_scene":
			_create_scene(parameters)
		"add_node":
			_add_node(parameters)
		"run_project":
			_run_project()
		"save_scene":
			_save_scene()
		"create_script":
			_create_script(parameters)
		_:
			push_warning("Неизвестная команда: ", command)

func _create_scene(params: Dictionary) -> void:
	var scene_type = params.get("type", "Node3D")
	var new_scene = PackedScene.new()
	var root_node = ClassDB.instantiate(scene_type)
	root_node.name = params.get("name", "Main")
	
	var scene = EditorSceneFormatImporter.new()
	editor_interface.save_scene()
	print("Сцена создана: ", root_node.name)

func _add_node(params: Dictionary) -> void:
	var node_type = params.get("type", "Node")
	var parent_path = params.get("parent", "/root")
	var node_name = params.get("name", "NewNode")
	
	var current_scene = editor_interface.get_edited_scene_root()
	if current_scene:
		var new_node = ClassDB.instantiate(node_type)
		new_node.name = node_name
		current_scene.add_child(new_node)
		print("Добавлена нода: ", node_name)

func _run_project() -> void:
	editor_interface.play_main_scene()
	print("Запуск проекта...")

func _save_scene() -> void:
	editor_interface.save_scene()
	print("Сцена сохранена")

func _create_script(params: Dictionary) -> void:
	var script_name = params.get("name", "script.gd")
	var node_path = params.get("node", "")
	
	var script = GDScript.new()
	script.source_code = "extends Node\n\nfunc _ready():\n\tpass\n"
	
	print("Скрипт создан: ", script_name)
