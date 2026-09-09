# Godot HTTP Server для получения команд от Python
# Этот скрипт должен быть добавлен в ваш проект Godot

extends Node

const PORT = 6000
var server: TCPServer = null
var clients: Array = []
var plugin_reference: EditorPlugin = null

func _ready() -> void:
	start_server()

func start_server() -> Error:
	server = TCPServer.new()
	var error = server.listen(PORT, "127.0.0.1")
	
	if error == OK:
		print(f"🎮 Godot HTTP сервер запущен на порту {PORT}")
	else:
		print(f"❌ Ошибка запуска сервера: {error}")
	
	return error

func _process(_delta: float) -> void:
	if server and server.is_listening():
		# Принимаем новых клиентов
		if server.is_connection_available():
			var client = server.take_connection()
			if client:
				clients.append(client)
				print("🔗 Новый клиент подключен")
		
		# Обрабатываем данные от клиентов
		for i in range(clients.size() - 1, -1, -1):
			var client: StreamPeerTCP = clients[i]
			client.poll()
			
			var status = client.get_status()
			if status == StreamPeer.STATUS_CONNECTED:
				# Читаем доступные данные
				var available = client.get_available_bytes()
				if available > 0:
					var data = client.get_utf8_string(available)
					process_command(data)
			elif status != StreamPeer.STATUS_CONNECTING:
				# Клиент отключился
				client.disconnect_from_host()
				clients.remove_at(i)

func process_command(data: String) -> void:
	print(f"📩 Получена команда: {data}")
	
	# Парсим JSON
	var json = JSON.new()
	var error = json.parse(data)
	
	if error != OK:
		print(f"❌ Ошибка парсинга JSON: {error}")
		return
	
	var parsed_data = json.get_data()
	var command = parsed_data.get("command", "")
	var parameters = parsed_data.get("parameters", {})
	
	# Выполняем команду
	if plugin_reference and plugin_reference.has_method("execute_command"):
		plugin_reference.execute_command(command, parameters)
	
	# Отправляем ответ
	send_response({"success": true, "command": command})

func send_response(response: Dictionary) -> void:
	var json_string = JSON.stringify(response)
	
	for client in clients:
		if client.get_status() == StreamPeer.STATUS_CONNECTED:
			client.put_utf8_string(json_string)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		stop_server()

func stop_server() -> void:
	if server:
		server.stop()
		print("🛑 Сервер остановлен")
