@tool
extends EditorPlugin

var dock_ui: Control
var http_server_instance: RefCounted

func _enter_tree() -> void:
	# Initialize HTTP Server
	http_server_instance = load("res://addons/AI_Yandex/http_server.gd").new()
	
	# Load and add the dock UI
	var DockScene = load("res://addons/AI_Yandex/dock_ui.tscn")
	dock_ui = DockScene.instantiate()
	
	# Add dock to the right panel
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, "AI_Yandex", dock_ui)
	
	# Pass server instance to UI if needed
	if dock_ui.has_method("set_server"):
		dock_ui.set_server(http_server_instance)

func _exit_tree() -> void:
	# Clean up
	if is_instance_valid(dock_ui):
		remove_control_from_docks(dock_ui)
		dock_ui.queue_free()
	
	if http_server_instance:
		if http_server_instance.has_method("stop"):
			http_server_instance.stop()
