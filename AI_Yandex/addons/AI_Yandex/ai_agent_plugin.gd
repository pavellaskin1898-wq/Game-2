@tool
extends EditorPlugin

# Относительные пути для корректной работы внутри addons/AI_Yandex
const SERVER_SCRIPT := preload("./http_server.gd")
const DOCK_SCENE := preload("./dock_ui.tscn")

var dock_control: Control
var server_instance: RefCounted

func _enter_tree() -> void:
	# Инициализация серверного модуля
	server_instance = SERVER_SCRIPT.new()
	
	# Создание и добавление панели интерфейса
	dock_control = DOCK_SCENE.instantiate()
	
	if dock_control:
		# Godot 4 API: add_control_to_dock(slot: DockSlot, control: Control)
		add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock_control)
		print("AI_Yandex: Панель успешно создана. Автор: LaskinPO")
	else:
		push_error("AI_Yandex: Ошибка создания панели! Проверьте dock_ui.tscn")

func _exit_tree() -> void:
	# Очистка при отключении плагина
	if dock_control:
		remove_control_from_docks(dock_control)
		dock_control.queue_free()
		dock_control = null
	
	if server_instance:
		server_instance = null
	
	print("AI_Yandex: Плагин отключен.")
