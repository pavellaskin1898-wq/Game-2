@tool
extends EditorPlugin

var dock_panel: Control
var http_server: Node
var is_connected := false
var yandex_login := ""
var yandex_password := ""
var yandex_token := ""
var server_url := "http://localhost:5000"
var auto_mode := false

const SERVER_SCRIPT := preload("res://addons/AI_Yandex/godot_plugin/http_server.gd")
const DOCK_SCENE := preload("res://addons/AI_Yandex/godot_plugin/dock_ui.tscn")

func _enter_tree() -> void:
	# Инициализация HTTP сервера для приема команд
	http_server = Node.new()
	http_server.set_script(SERVER_SCRIPT)
	add_child(http_server)
	
	# Создание панели интерфейса
	dock_panel = DOCK_SCENE.instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock_panel)
	
	# Подключение сигналов интерфейса
	_setup_signals()
	
	print("AI_Yandex (Автор: LaskinPO) - плагин активирован")

func _exit_tree() -> void:
	if dock_panel:
		remove_control_from_docks(dock_panel)
		dock_panel.queue_free()
		dock_panel = null
	
	if http_server:
		http_server.queue_free()
		http_server = null
	
	print("AI_Yandex - плагин деактивирован")

func _setup_signals() -> void:
	if not dock_panel:
		return
	
	# Получение элементов управления из сцены дока
	var login_input := dock_panel.get_node_or_null("LoginInput") as LineEdit
	var password_input := dock_panel.get_node_or_null("PasswordInput") as LineEdit
	var get_token_btn := dock_panel.get_node_or_null("GetTokenBtn") as Button
	var connect_btn := dock_panel.get_node_or_null("ConnectBtn") as Button
	var auto_check := dock_panel.get_node_or_null("AutoCheck") as CheckBox
	var status_label := dock_panel.get_node_or_null("StatusLabel") as Label
	
	if login_input:
		login_input.text_changed.connect(_on_login_changed)
	if password_input:
		password_input.text_changed.connect(_on_password_changed)
	if get_token_btn:
		get_token_btn.pressed.connect(_on_get_token_pressed)
	if connect_btn:
		connect_btn.pressed.connect(_on_connect_pressed)
	if auto_check:
		auto_check.toggled.connect(_on_auto_toggled)

func _on_login_changed(new_text: String) -> void:
	yandex_login = new_text

func _on_password_changed(new_text: String) -> void:
	yandex_password = new_text

func _on_get_token_pressed() -> void:
	if yandex_login.is_empty() or yandex_password.is_empty():
		_show_status("Ошибка: Введите логин и пароль", Color.RED)
		return
	
	_show_status("Получение токена...", Color.YELLOW)
	# Здесь будет логика получения токена через HTTP запрос к Python серверу
	# Для примера просто имитируем успешное получение
	await get_tree().create_timer(1.0).timeout
	yandex_token = "mock_token_" + str(Time.get_unix_time_from_system())
	_show_status("Токен получен успешно!", Color.GREEN)

func _on_connect_pressed() -> void:
	if yandex_token.is_empty():
		_show_status("Сначала получите токен!", Color.RED)
		return
	
	_show_status("Подключение к серверу...", Color.YELLOW)
	is_connected = true
	_show_status("Подключено к AI_Yandex серверу", Color.GREEN)

func _on_auto_toggled(toggled_on: bool) -> void:
	auto_mode = toggled_on
	if auto_mode:
		_show_status("Автономный режим включен", Color.BLUE)
	else:
		_show_status("Автономный режим выключен", Color.GRAY)

func _show_status(text: String, color: Color) -> void:
	if dock_panel:
		var status_label := dock_panel.get_node_or_null("StatusLabel") as Label
		if status_label:
			status_label.text = text
			status_label.modulate = color

func execute_command(command_text: String) -> void:
	if not is_connected:
		push_warning("AI_Yandex: Не подключено к серверу")
		return
	
	# Отправка команды на Python сервер для обработки
	print("AI_Yandex: Выполнение команды: ", command_text)
	# Логика выполнения команды через HTTP запрос
