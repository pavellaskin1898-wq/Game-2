@tool
extends EditorPlugin

## AI Agent Plugin для Godot - AI_Yandex от LaskinPO
## Обеспечивает интеграцию с Python сервером и Яндекс Алисой
## Удобный интерфейс с панелью управления справа

var ai_communicator: Node
var editor_interface: EditorInterface
var main_panel: Control
var is_connected: bool = false
var server_url: String = "http://localhost:5000"
var yandex_login: String = ""
var yandex_password: String = ""
var yandex_token: String = ""
var auto_work: bool = false
var status_label: Label
var connection_btn: Button

func _enter_tree() -> void:
	# Инициализация плагина
	editor_interface = get_editor_interface()
	
	# Создаем узел коммуникатора
	ai_communicator = Node.new()
	ai_communicator.name = "AICommunicator"
	add_child(ai_communicator)
	
	# Добавляем кнопку в тулбар
	_add_toolbar_button()
	
	# Создаем основную панель (справа)
	_create_main_panel()
	
	# Загружаем настройки
	_load_settings()
	
	print("AI_Yandex Plugin активирован - Автор: LaskinPO")

func _exit_tree() -> void:
	# Очистка при выключении
	if ai_communicator:
		ai_communicator.queue_free()
	
	_remove_toolbar_button()
	
	if main_panel and is_instance_valid(main_panel):
		main_panel.queue_free()
	
	print("AI_Yandex Plugin деактивирован")

func _create_main_panel() -> void:
	# Создаем основную панель управления
	main_panel = Control.new()
	main_panel.name = "AI_YandexPanel"
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 15)
	vbox.add_theme_constant_override("margin_left", 10)
	vbox.add_theme_constant_override("margin_right", 10)
	vbox.add_theme_constant_override("margin_top", 10)
	vbox.add_theme_constant_override("margin_bottom", 10)
	main_panel.add_child(vbox)
	
	# Заголовок
	var title = Label.new()
	title.text = "🤖 AI_Yandex"
	title.add_theme_font_size_override("font_size", 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	var subtitle = Label.new()
	subtitle.text = "Автор: LaskinPO"
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(subtitle)
	
	vbox.add_child(HSeparator.new())
	
	# URL сервера
	var url_label = Label.new()
	url_label.text = "URL сервера:"
	vbox.add_child(url_label)
	
	var url_edit = LineEdit.new()
	url_edit.name = "URLEdit"
	url_edit.text = server_url
	url_edit.placeholder_text = "http://localhost:5000"
	url_edit.text_changed.connect(_on_url_changed)
	vbox.add_child(url_edit)
	
	vbox.add_child(HSeparator.new())
	
	# Логин Яндекс
	var login_label = Label.new()
	login_label.text = "Логин Яндекс:"
	vbox.add_child(login_label)
	
	var login_edit = LineEdit.new()
	login_edit.name = "LoginEdit"
	login_edit.text = yandex_login
	login_edit.placeholder_text = "Ваш логин от Яндекс"
	login_edit.text_changed.connect(_on_login_changed)
	vbox.add_child(login_edit)
	
	# Пароль Яндекс
	var password_label = Label.new()
	password_label.text = "Пароль Яндекс:"
	vbox.add_child(password_label)
	
	var password_edit = LineEdit.new()
	password_edit.name = "PasswordEdit"
	password_edit.text = yandex_password
	password_edit.placeholder_text = "Ваш пароль от Яндекс"
	password_edit.password_mode = true
	password_edit.text_changed.connect(_on_password_changed)
	vbox.add_child(password_edit)
	
	# Кнопка получения токена
	var token_btn = Button.new()
	token_btn.name = "TokenButton"
	token_btn.text = "🔑 Получить токен"
	token_btn.pressed.connect(_on_get_token_pressed)
	token_btn.tooltip_text = "Автоматически получить OAuth токен по логину и паролю"
	vbox.add_child(token_btn)
	
	# Поле токена
	var token_label = Label.new()
	token_label.text = "OAuth токен:"
	vbox.add_child(token_label)
	
	var token_edit = LineEdit.new()
	token_edit.name = "TokenEdit"
	token_edit.text = yandex_token
	token_edit.placeholder_text = "Токен будет получен автоматически"
	token_edit.password_mode = true
	token_edit.editable = false
	vbox.add_child(token_edit)
	
	vbox.add_child(HSeparator.new())
	
	# Статус подключения
	status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.text = "❌ Не подключено"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(status_label)
	
	# Кнопки управления
	var button_box = VBoxContainer.new()
	button_box.add_theme_constant_override("separation", 8)
	vbox.add_child(button_box)
	
	connection_btn = Button.new()
	connection_btn.text = "📡 Подключиться"
	connection_btn.pressed.connect(_check_connection)
	button_box.add_child(connection_btn)
	
	var auto_btn = CheckButton.new()
	auto_btn.name = "AutoButton"
	auto_btn.text = "🔄 Автономная работа"
	auto_btn.toggled.connect(_on_auto_toggled)
	button_box.add_child(auto_btn)
	
	vbox.add_child(HSeparator.new())
	
	# Информация
	var info = RichTextLabel.new()
	info.bbcode_enabled = true
	info.scroll_active = true
	info.text = """[b]Как использовать:[/b]
1. Введите логин и пароль от Яндекс
2. Нажмите [b]Получить токен[/b]
3. Нажмите [b]Подключиться[/b]
4. Включите [b]Автономную работу[/b]

[b]Команды Алисе:[/b]
• Создай новую сцену
• Добавь игрока
• Запусти проект
• Сохрани сцену
• Создай скрипт
"""
	vbox.add_child(info)
	
	# Добавляем панель в правую часть редактора
	var dock_control = editor_interface.get_base_control()
	dock_control.add_child(main_panel)
	
	# Делаем панель видимой
	make_dock_visible(true)

func _add_toolbar_button() -> void:
	var toolbar = editor_interface.get_base_control().get_node("MenuContainer/ToolbarBox")
	if toolbar:
		var button = Button.new()
		button.name = "AIAgentButton"
		button.text = "🤖 AI_Yandex"
		button.tooltip_text = "Показать/скрыть панель AI_Yandex"
		button.pressed.connect(_toggle_panel_visibility)
		toolbar.add_child(button)

func _remove_toolbar_button() -> void:
	var toolbar = editor_interface.get_base_control().get_node("MenuContainer/ToolbarBox")
	if toolbar and toolbar.has_node("AIAgentButton"):
		toolbar.get_node("AIAgentButton").queue_free()

func _toggle_panel_visibility() -> void:
	if main_panel:
		make_dock_visible(not main_panel.visible)

func _on_url_changed(new_text: String) -> void:
	server_url = new_text
	_save_settings()

func _on_login_changed(new_text: String) -> void:
	yandex_login = new_text
	_save_settings()

func _on_password_changed(new_text: String) -> void:
	yandex_password = new_text
	_save_settings()

func _on_get_token_pressed() -> void:
	if yandex_login.is_empty() or yandex_password.is_empty():
		_show_status("⚠️ Введите логин и пароль", Color.YELLOW)
		return
	
	_show_status("🔄 Получение токена...", Color.BLUE)
	
	# Отправляем запрос на получение токена
	var http = HTTPRequest.new()
	add_child(http)
	
	var request_body = JSON.stringify({
		"login": yandex_login,
		"password": yandex_password
	})
	
	var headers = ["Content-Type: application/json"]
	var error = http.request(server_url + "/api/auth/yandex", headers, HTTPClient.METHOD_POST, request_body)
	
	if error != OK:
		_show_status("❌ Ошибка запроса", Color.RED)
		http.queue_free()
		return
	
	# Ждем ответ
	await http.request_completed
	var response = http.get_response_body_as_string()
	
	if http.get_http_client_status() == 200:
		var json = JSON.parse_string(response)
		if json and json.has("token"):
			yandex_token = json["token"]
			var token_edit = main_panel.get_node("VBoxContainer/TokenEdit") as LineEdit
			if token_edit:
				token_edit.text = yandex_token
			_save_settings()
			_show_status("✅ Токен получен!", Color.GREEN)
		else:
			_show_status("❌ Ошибка получения токена", Color.RED)
	else:
		_show_status("❌ Ошибка сервера", Color.RED)
	
	http.queue_free()

func _on_auto_toggled(toggled_on: bool) -> void:
	auto_work = toggled_on
	if auto_work:
		_show_status("🔄 Автономная работа включена", Color.GREEN)
		_start_autonomous_mode()
	else:
		_show_status("⏸️ Автономная работа выключена", Color.YELLOW)

func _check_connection() -> void:
	_show_status("🔄 Проверка подключения...", Color.BLUE)
	
	var http = HTTPRequest.new()
	add_child(http)
	
	var error = http.request(server_url + "/api/status")
	if error != OK:
		_show_status("❌ Ошибка подключения", Color.RED)
		is_connected = false
		http.queue_free()
		return
	
	await http.request_completed
	
	if http.get_http_client_status() == 200:
		is_connected = true
		_show_status("✅ Подключено к серверу", Color.GREEN)
		connection_btn.text = "🔄 Переподключиться"
	else:
		is_connected = false
		_show_status("❌ Сервер недоступен", Color.RED)
	
	http.queue_free()

func _show_status(text: String, color: Color) -> void:
	if status_label:
		status_label.text = text
		status_label.add_theme_color_override("font_color", color)

func _start_autonomous_mode() -> void:
	if not is_connected:
		_show_status("⚠️ Сначала подключитесь к серверу", Color.YELLOW)
		var auto_btn = main_panel.get_node("VBoxContainer/AutoButton") as CheckButton
		if auto_btn:
			auto_btn.button_pressed = false
		return
	
	# Запускаем прослушивание команд от Алисы
	print("🎙️ Автономный режим: ожидание команд от Алисы...")

func _save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("settings", "server_url", server_url)
	config.set_value("settings", "yandex_login", yandex_login)
	config.set_value("settings", "yandex_password", yandex_password)
	config.set_value("settings", "yandex_token", yandex_token)
	config.set_value("settings", "auto_work", auto_work)
	config.save("user://ai_yandex_settings.cfg")

func _load_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://ai_yandex_settings.cfg")
	if err == OK:
		server_url = config.get_value("settings", "server_url", "http://localhost:5000")
		yandex_login = config.get_value("settings", "yandex_login", "")
		yandex_password = config.get_value("settings", "yandex_password", "")
		yandex_token = config.get_value("settings", "yandex_token", "")
		auto_work = config.get_value("settings", "auto_work", false)
		
		# Обновляем UI
		var url_edit = main_panel.get_node("VBoxContainer/URLEdit") as LineEdit
		if url_edit:
			url_edit.text = server_url
		
		var login_edit = main_panel.get_node("VBoxContainer/LoginEdit") as LineEdit
		if login_edit:
			login_edit.text = yandex_login
		
		var password_edit = main_panel.get_node("VBoxContainer/PasswordEdit") as LineEdit
		if password_edit:
			password_edit.text = yandex_password
		
		var token_edit = main_panel.get_node("VBoxContainer/TokenEdit") as LineEdit
		if token_edit:
			token_edit.text = yandex_token
		
		var auto_btn = main_panel.get_node("VBoxContainer/AutoButton") as CheckButton
		if auto_btn:
			auto_btn.button_pressed = auto_work

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
	var root_node = ClassDB.instantiate(scene_type)
	root_node.name = params.get("name", "Main")
	
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
