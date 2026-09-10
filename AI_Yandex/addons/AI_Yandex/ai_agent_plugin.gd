@tool
extends EditorPlugin

const SERVER_SCRIPT := preload("res://addons/AI_Yandex/http_server.gd")
const DOCK_SCENE := preload("res://addons/AI_Yandex/dock_ui.tscn")

var dock_instance: Control
var http_server_instance: Node

func _enter_tree() -> void:
	# Create HTTP Server instance
	http_server_instance = SERVER_SCRIPT.new()
	add_child(http_server_instance)
	
	# Create Dock UI
	dock_instance = DOCK_SCENE.instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock_instance)
	
	# Connect signals if needed
	if dock_instance.has_signal("connect_requested"):
		dock_instance.connect("connect_requested", _on_connect_requested)
	if dock_instance.has_signal("auth_requested"):
		dock_instance.connect("auth_requested", _on_auth_requested)
	if dock_instance.has_signal("command_requested"):
		dock_instance.connect("command_requested", _on_command_requested)

func _exit_tree() -> void:
	# Clean up
	if is_instance_valid(dock_instance):
		remove_control_from_docks(dock_instance)
		dock_instance.queue_free()
	
	if is_instance_valid(http_server_instance):
		http_server_instance.queue_free()

func _on_connect_requested(host: String, port: int) -> void:
	if is_instance_valid(http_server_instance):
		http_server_instance.connect_to_server(host, port)

func _on_auth_requested(login: String, password: String) -> void:
	if is_instance_valid(http_server_instance):
		http_server_instance.authenticate(login, password)

func _on_command_requested(command: String) -> void:
	if is_instance_valid(http_server_instance):
		http_server_instance.send_command(command)
