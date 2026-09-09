@tool
extends RefCounted

var server: TCPServer = null
var clients: Array = []
var is_running: bool = false
var port: int = 8080

func start() -> Error:
	if is_running:
		return OK
	
	server = TCPServer.new()
	var err = server.listen(port, "127.0.0.1")
	if err != OK:
		print("HTTP Server failed to start on port ", port)
		return err
	
	is_running = true
	print("HTTP Server started on port ", port)
	return OK

func stop() -> void:
	if server:
		server.stop()
		server = null
	is_running = false
	print("HTTP Server stopped")

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		stop()
