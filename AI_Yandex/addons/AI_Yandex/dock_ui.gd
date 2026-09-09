@tool
extends VBoxContainer

signal connect_requested()
signal auth_requested(login: String, password: String)

@onready var login_input: LineEdit = $LoginInput
@onready var password_input: LineEdit = $PasswordInput
@onready var get_token_btn: Button = $GetTokenBtn
@onready var connect_btn: Button = $ConnectBtn
@onready var auto_work_check: CheckBox = $AutoWorkCheck
@onready var status_label: Label = $StatusLabel
@onready var log_output: TextEdit = $LogOutput

var is_connected: bool = false

func _ready() -> void:
	_connect_signals()
	_log("AI_Yandex Dock initialized")

func _connect_signals() -> void:
	get_token_btn.pressed.connect(_on_get_token_pressed)
	connect_btn.pressed.connect(_on_connect_pressed)
	auto_work_check.toggled.connect(_on_auto_work_toggled)

func _on_get_token_pressed() -> void:
	var login = login_input.text.strip_edges()
	var password = password_input.text.strip_edges()
	
	if login.is_empty() or password.is_empty():
		_log("Error: Please enter login and password")
		return
	
	_log("Requesting token for: " + login)
	auth_requested.emit(login, password)
	# Note: Actual token request should be handled by Python server

func _on_connect_pressed() -> void:
	if not is_connected:
		_log("Connecting to server...")
		connect_requested.emit()
		_set_status(true)
	else:
		_log("Disconnecting from server...")
		_set_status(false)

func _on_auto_work_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_log("Autonomous mode enabled")
	else:
		_log("Autonomous mode disabled")

func _set_status(connected: bool) -> void:
	is_connected = connected
	if connected:
		status_label.text = "Status: Connected"
		status_label.label_settings.font_color = Color(0.2, 0.8, 0.2, 1)
	else:
		status_label.text = "Status: Disconnected"
		status_label.label_settings.font_color = Color(1, 0.3, 0.3, 1)

func _log(message: String) -> void:
	var timestamp = Time.get_datetime_string_from_system()
	log_output.text += "[" + timestamp + "] " + message + "\n"
	log_output.scroll_vertical = log_output.get_line_count()
