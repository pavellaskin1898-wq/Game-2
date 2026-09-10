@tool
extends Node

signal connection_status_changed(status: String)
signal auth_completed(success: bool, token: String)
signal command_executed(result: String)

var http_client: HTTPClient
var server_host: String = "http://localhost"
var server_port: int = 5000
var yandex_token: String = ""
var is_connected: bool = false

func _ready() -> void:
	http_client = HTTPClient.new()

func connect_to_server(host: String, port: int) -> void:
	server_host = host
	server_port = port
	is_connected = true
	emit_signal("connection_status_changed", "Connected to " + host + ":" + str(port))

func authenticate(login: String, password: String) -> void:
	var url = server_host + ":" + str(server_port) + "/api/auth/yandex"
	var headers = ["Content-Type: application/json"]
	var body = {"login": login, "password": password}
	
	var json_body = JSON.stringify(body)
	
	http_client.connect_to_host(url, server_port)
	
	# Wait for connection
	while http_client.get_status() == HTTPClient.STATUS_CONNECTING or http_client.get_status() == HTTPClient.STATUS_RESOLVING:
		http_client.poll()
		await get_tree().process_frame
	
	if http_client.get_status() != HTTPClient.STATUS_CONNECTED:
		emit_signal("auth_completed", false, "Connection failed")
		return
	
	# Send request
	http_client.request(HTTPClient.METHOD_POST, "/api/auth/yandex", headers, json_body)
	
	# Wait for response
	while http_client.get_status() == HTTPClient.STATUS_REQUESTING or http_client.get_status() == HTTPClient.STATUS_BODY:
		http_client.poll()
		await get_tree().process_frame
	
	if http_client.has_response():
		var response_code = http_client.get_response_code()
		if response_code == 200:
			var response_body = http_client.read_response_body_as_string()
			var json = JSON.parse_string(response_body)
			if json and json.has("token"):
				yandex_token = json["token"]
				emit_signal("auth_completed", true, yandex_token)
			else:
				emit_signal("auth_completed", false, "Invalid response format")
		else:
			emit_signal("auth_completed", false, "HTTP Error: " + str(response_code))
	else:
		emit_signal("auth_completed", false, "No response from server")

func send_command(command: String) -> void:
	if not is_connected:
		emit_signal("command_executed", "Not connected to server")
		return
	
	var url = server_host + ":" + str(server_port) + "/api/command"
	var headers = ["Content-Type: application/json"]
	if yandex_token != "":
		headers.append("Authorization: Bearer " + yandex_token)
	
	var body = {"command": command}
	var json_body = JSON.stringify(body)
	
	http_client.request(HTTPClient.METHOD_POST, "/api/command", headers, json_body)
	
	# Wait for response
	while http_client.get_status() == HTTPClient.STATUS_REQUESTING or http_client.get_status() == HTTPClient.STATUS_BODY:
		http_client.poll()
		await get_tree().process_frame
	
	if http_client.has_response():
		var response_code = http_client.get_response_code()
		if response_code == 200:
			var response_body = http_client.read_response_body_as_string()
			emit_signal("command_executed", "Command executed: " + response_body)
		else:
			emit_signal("command_executed", "HTTP Error: " + str(response_code))
	else:
		emit_signal("command_executed", "No response from server")
