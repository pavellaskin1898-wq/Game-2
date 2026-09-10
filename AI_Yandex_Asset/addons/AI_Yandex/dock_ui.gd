@tool
extends Control

@onready var login_edit: LineEdit = $VBoxContainer/LoginEdit
@onready var pass_edit: LineEdit = $VBoxContainer/PassEdit
@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var get_token_btn: Button = $VBoxContainer/GetTokenBtn
@onready var connect_btn: Button = $VBoxContainer/ConnectBtn
@onready var autonomous_check: CheckBox = $VBoxContainer/AutonomousCheck

func _ready():
	get_token_btn.pressed.connect(_on_get_token_pressed)
	connect_btn.pressed.connect(_on_connect_pressed)
	if autonomous_check:
		autonomous_check.toggled.connect(_on_autonomous_toggled)

func _on_get_token_pressed():
	var login = login_edit.text
	var password = pass_edit.text
	if login.is_empty() or password.is_empty():
		status_label.text = "Ошибка: Введите логин и пароль!"
		status_label.add_theme_color_override("font_color", Color.RED)
		return
	
	status_label.text = "Запрос токена..."
	status_label.remove_theme_color_override("font_color")
	print("AI_Yandex: Requesting token for user: ", login)
	# Здесь будет HTTP запрос к Python серверу для получения токена

func _on_connect_pressed():
	status_label.text = "Подключение к серверу..."
	status_label.remove_theme_color_override("font_color")
	print("AI_Yandex: Connecting to local server...")
	# Здесь будет логика подключения к серверу

func _on_autonomous_toggled(toggled_on: bool):
	if toggled_on:
		status_label.text = "Автономный режим: ВКЛ"
		print("AI_Yandex: Autonomous mode enabled")
	else:
		status_label.text = "Автономный режим: ВЫКЛ"
		print("AI_Yandex: Autonomous mode disabled")
