@tool
extends EditorPlugin

const SERVER_SCRIPT := preload("res://addons/AI_Yandex/http_server.gd")
const DOCK_SCENE := preload("res://addons/AI_Yandex/dock_ui.tscn")

var dock_instance: Control
var http_server_instance: RefCounted

func _enter_tree() -> void:
	# Initialize HTTP Server
	http_server_instance = SERVER_SCRIPT.new()
	
	# Create Dock UI
	dock_instance = DOCK_SCENE.instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock_instance)
	
	# Connect signals if needed
	if dock_instance.has_signal("connect_requested"):
		dock_instance.connect_requested.connect(_on_connect_requested)
	if dock_instance.has_signal("auth_requested"):
		dock_instance.auth_requested.connect(_on_auth_requested)

func _exit_tree() -> void:
	if is_instance_valid(dock_instance):
		remove_control_from_docks(dock_instance)
		dock_instance.queue_free()
	
	if is_instance_valid(http_server_instance):
		if http_server_instance.has_method("stop"):
			http_server_instance.stop()

func _on_connect_requested() -> void:
	if is_instance_valid(http_server_instance) and http_server_instance.has_method("start"):
		http_server_instance.start()

func _on_auth_requested(login: String, password: String) -> void:
	print("Auth requested for: ", login)
	# Handle auth logic here
