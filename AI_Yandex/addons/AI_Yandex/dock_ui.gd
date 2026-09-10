@tool
extends Control

@onready var login_edit: LineEdit = $VBoxContainer/LoginEdit
@onready var pass_edit: LineEdit = $VBoxContainer/PassEdit
@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var get_token_btn: Button = $VBoxContainer/GetTokenBtn
@onready var connect_btn: Button = $VBoxContainer/ConnectBtn
@onready var auto_check: CheckBox = $VBoxContainer/AutoCheck

var is_connected: bool = false
var yandex_token: String = ""

func _ready():
	get_token_btn.pressed.connect(_on_get_token_pressed)
	connect_btn.pressed.connect(_on_connect_pressed)
	update_status("Ожидание ввода данных", Color.GRAY)

func _on_get_token_pressed():
	var login = login_edit.text.strip_edges()
	var password = pass_edit.text.strip_edges()
	
	if login.is_empty() or password.is_empty():
		update_status("Ошибка: Введите логин и пароль!", Color.RED)
		return
	
	update_status("Запрос токена...", Color.YELLOW)
	print("AI_Yandex: Запрос токена для пользователя: ", login)
	
	# Здесь будет HTTP запрос к Python серверу для получения OAuth токена
	# Пример: yandex_token = await request_yandex_token(login, password)
	
	await get_tree().create_timer(1.0).timeout
	yandex_token = "mock_token_12345" # Заглушка для демонстрации
	
	update_status("Токен получен!", Color.GREEN)
	print("AI_Yandex: Токен успешно получен")

func _on_connect_pressed():
	if yandex_token.is_empty():
		update_status("Сначала получите токен!", Color.RED)
		return
	
	update_status("Подключение к серверу...", Color.YELLOW)
	print("AI_Yandex: Подключение к локальному серверу...")
	
	# Здесь будет логика подключения к Python серверу
	is_connected = true
	update_status("✅ Подключено (Автономный режим)", Color.GREEN)
	
	if auto_check.button_pressed:
		print("AI_Yandex: Автономный режим активирован")

func update_status(text: String, color: Color):
	status_label.text = "Статус: " + text
	status_label.add_theme_color_override("font_color", color)
