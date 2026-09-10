@tool
extends RefCounted

var server: TCPServer = null
var port: int = 5001
var is_running: bool = false

signal command_received(command: String)

func start() -> Error:
	server = TCPServer.new()
	var err = server.listen(port, "127.0.0.1")
	if err == OK:
		is_running = true
		print("AI_Yandex TCP Server started on port ", port)
		# Note: In a real plugin, you'd need a thread or timeout to poll this
	else:
		print("Failed to start TCP Server on port ", port)
	return err

func stop() -> void:
	if server:
		server.stop()
		is_running = false
		print("AI_Yandex TCP Server stopped")

func get_status() -> Dictionary:
	return {
		"running": is_running,
		"port": port,
		"address": "127.0.0.1"
	}
