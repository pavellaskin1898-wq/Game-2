@tool
extends RefCounted

# Модуль сервера для связи с Python backend
var server_url: String = "http://127.0.0.1:5000"
var yandex_token: String = ""
var is_connected: bool = false

func _init():
	print("AI_Yandex: Server module initialized by LaskinPO")

func set_token(token: String):
	yandex_token = token
	print("AI_Yandex: Token set successfully")

func connect_to_server() -> bool:
	# Здесь будет логика подключения к Python серверу
	is_connected = true
	print("AI_Yandex: Connected to server at ", server_url)
	return true

func send_command(command: String) -> Dictionary:
	# Здесь будет логика отправки команд на сервер
	return {"status": "success", "message": "Command executed: " + command}
