@tool
extends Control

signal connect_requested(host: String, port: int)
signal auth_requested(login: String, password: String)
signal command_requested(command: String)

@onready var login_input: LineEdit = $VBoxContainer/LoginInput
@onready var password_input: LineEdit = $VBoxContainer/PasswordInput
@onready var host_input: LineEdit = $VBoxContainer/HostInput
@onready var port_input: SpinBox = $VBoxContainer/PortInput
@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var connect_button: Button = $VBoxContainer/ConnectButton
@onready var auth_button: Button = $VBoxContainer/AuthButton
@onready var command_input: LineEdit = $VBoxContainer/CommandInput
@onready var send_button: Button = $VBoxContainer/SendButton
@onready var autonomous_check: CheckBox = $VBoxContainer/AutonomousCheck

var is_autonomous: bool = false

func _ready() -> void:
	# Initialize UI
	host_input.text = "http://localhost"
	port_input.value = 5000
	status_label.text = "Status: Disconnected"
	status_label.add_theme_color_override("font_color", Color.RED)
	
	# Connect buttons
	connect_button.pressed.connect(_on_connect_pressed)
	auth_button.pressed.connect(_on_auth_pressed)
	send_button.pressed.connect(_on_send_pressed)
	autonomous_check.toggled.connect(_on_autonomous_toggled)
	command_input.text_submitted.connect(_on_command_entered)

func _on_connect_pressed() -> void:
	var host = host_input.text
	var port = int(port_input.value)
	emit_signal("connect_requested", host, port)
	status_label.text = "Status: Connecting..."
	status_label.add_theme_color_override("font_color", Color.YELLOW)

func _on_auth_pressed() -> void:
	var login = login_input.text
	var password = password_input.text
	
	if login == "" or password == "":
		status_label.text = "Error: Login and password required"
		status_label.add_theme_color_override("font_color", Color.RED)
		return
	
	emit_signal("auth_requested", login, password)
	status_label.text = "Status: Authenticating..."
	status_label.add_theme_color_override("font_color", Color.YELLOW)

func _on_send_pressed() -> void:
	var command = command_input.text
	if command == "":
		return
	
	emit_signal("command_requested", command)
	command_input.text = ""

func _on_command_entered(new_text: String) -> void:
	_on_send_pressed()

func _on_autonomous_toggled(toggled_on: bool) -> void:
	is_autonomous = toggled_on
	if is_autonomous:
		status_label.text = "Status: Autonomous mode enabled"
		status_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		status_label.text = "Status: Connected"
		status_label.add_theme_color_override("font_color", Color.GREEN)

func set_status_connected() -> void:
	status_label.text = "Status: Connected"
	status_label.add_theme_color_override("font_color", Color.GREEN)

func set_status_disconnected() -> void:
	status_label.text = "Status: Disconnected"
	status_label.add_theme_color_override("font_color", Color.RED)

func set_status_error(message: String) -> void:
	status_label.text = "Error: " + message
	status_label.add_theme_color_override("font_color", Color.RED)
