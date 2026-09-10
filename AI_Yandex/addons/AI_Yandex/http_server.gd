@tool
extends RefCounted

# Модуль HTTP/TCP сервера для связи с Python
var server: TCPServer = null
var is_running: bool = false

func _init():
	print("AI_Yandex: Серверный модуль инициализирован (LaskinPO)")

func start_server(host: String = "127.0.0.1", port: int = 5005) -> Error:
	if is_running:
		push_warning("AI_Yandex: Сервер уже запущен")
		return OK
	
	server = TCPServer.new()
	var err = server.listen(port, host)
	
	if err == OK:
		is_running = true
		print("AI_Yandex: Сервер запущен на %s:%d" % [host, port])
	else:
		push_error("AI_Yandex: Ошибка запуска сервера: %s" % error_string(err))
	
	return err

func stop_server():
	if server:
		server.stop()
		is_running = false
		print("AI_Yandex: Сервер остановлен")
