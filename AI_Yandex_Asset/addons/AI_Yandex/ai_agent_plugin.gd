@tool
extends EditorPlugin

# Относительные пути для корректной работы внутри папки addons
const SERVER_SCRIPT := preload("./http_server.gd")
const DOCK_SCENE := preload("./dock_ui.tscn")

var dock_control: Control
var server_instance: RefCounted

func _enter_tree() -> void:
	# 1. Инициализация сервера (логика)
	server_instance = SERVER_SCRIPT.new()
	
	# 2. Создание интерфейса (Dock)
	dock_control = DOCK_SCENE.instantiate()
	
	if dock_control:
		# Добавляем контрол в правый док (Upper Left)
		# Godot 4 API: add_control_to_dock(slot: DockSlot, control: Control)
		add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock_control)
		print("AI_Yandex: Dock panel created successfully by LaskinPO")
	else:
		push_error("AI_Yandex: Failed to instantiate dock scene. Check dock_ui.tscn root node.")

func _exit_tree() -> void:
	# Убираем панель при отключении плагина
	if dock_control:
		remove_control_from_docks(dock_control)
		dock_control.queue_free()
		dock_control = null
	
	if server_instance:
		server_instance = null
	
	print("AI_Yandex: Plugin disabled.")
