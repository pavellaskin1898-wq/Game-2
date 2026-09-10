@tool
extends Control

var http_request: HTTPRequest
var server_url: String = "http://127.0.0.1:5000"
var yandex_token: String = ""
var is_connected: bool = false
var autonomous_mode: bool = false

# UI References
@onready var login_edit: LineEdit = $VBoxContainer/LoginEdit
@onready var password_edit: LineEdit = $VBoxContainer/PasswordEdit
@onready var get_token_btn: Button = $VBoxContainer/GetTokenBtn
@onready var server_edit: LineEdit = $VBoxContainer/ServerEdit
@onready var connect_btn: Button = $VBoxContainer/ConnectBtn
@onready var status_label: Label = $VBoxContainer/StatusPanel/StatusLabel
@onready var autonomous_check: CheckBox = $VBoxContainer/AutonomousCheck
@onready var command_edit: TextEdit = $VBoxContainer/CommandEdit
@onready var send_btn: Button = $VBoxContainer/SendBtn

func _ready() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	
	# Connect buttons
	get_token_btn.pressed.connect(_on_get_token_pressed)
	connect_btn.pressed.connect(_on_connect_pressed)
	send_btn.pressed.connect(_on_send_pressed)
	autonomous_check.toggled.connect(_on_autonomous_toggled)
	
	update_status("Ready to connect")

func set_server(server_instance: RefCounted) -> void:
	# Optional: link with internal server if needed
	pass

func _on_get_token_pressed() -> void:
	var login = login_edit.text.strip_edges()
	var password = password_edit.text.strip_edges()
	
	if login.is_empty() or password.is_empty():
		update_status("Error: Enter login and password")
		return
	
	update_status("Getting token from Yandex...")
	
	var url = server_url + "/api/auth/yandex"
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({"login": login, "password": password})
	
	var err = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		update_status("Error: Failed to send request")

func _on_connect_pressed() -> void:
	server_url = server_edit.text.strip_edges()
	if server_url.is_empty():
		server_url = "http://127.0.0.1:5000"
	
	update_status("Connecting to server...")
	
	var url = server_url + "/api/status"
	var headers = ["Content-Type: application/json"]
	
	var err = http_request.request(url, headers, HTTPClient.METHOD_GET, "")
	if err != OK:
		update_status("Error: Cannot reach server")
		is_connected = false

func _on_send_pressed() -> void:
	if not is_connected:
		update_status("Error: Not connected to server")
		return
	
	var command = command_edit.text.strip_edges()
	if command.is_empty():
		return
	
	update_status("Sending command...")
	
	var url = server_url + "/api/command"
	var headers = ["Content-Type: application/json"]
	if not yandex_token.is_empty():
		headers.append("Authorization: Bearer " + yandex_token)
	var body = JSON.stringify({"command": command, "language": "ru"})
	
	var err = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		update_status("Error: Failed to send command")

func _on_autonomous_toggled(toggled_on: bool) -> void:
	autonomous_mode = toggled_on
	if autonomous_mode and is_connected:
		update_status("Autonomous mode: ON")
	else:
		update_status("Autonomous mode: OFF")

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var response_string = body.get_string_from_utf8()
	var json = JSON.new()
	var parse_result = json.parse(response_string)
	var data = {}
	if parse_result == OK:
		data = json.data
	
	# Handle auth response
	if "/auth/yandex" in http_request.get_requested_url():
		if response_code == 200 and data.has("token"):
			yandex_token = data["token"]
			update_status("Token received successfully!")
		else:
			update_status("Error getting token: " + str(data.get("error", "Unknown error")))
	
	# Handle status response
	if "/status" in http_request.get_requested_url():
		if response_code == 200:
			is_connected = true
			update_status("Connected to AI_Yandex Server ✓")
			status_label.add_theme_color_override("font_color", Color.GREEN)
		else:
			is_connected = false
			update_status("Disconnected (Server unreachable)")
			status_label.add_theme_color_override("font_color", Color.RED)
	
	# Handle command response
	if "/command" in http_request.get_requested_url():
		if response_code == 200:
			update_status("Command executed: " + str(data.get("result", "OK")))
		else:
			update_status("Command failed: " + str(data.get("error", "Unknown error")))

func update_status(message: String) -> void:
	status_label.text = "Status: " + message
