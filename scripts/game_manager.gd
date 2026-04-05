extends Node3D
class_name GameManager

## Gerenciador principal do jogo - conecta todos os sistemas

@export var car_state_manager: CarStateManager
@export var assembly_system: AssemblySystem
@export var wash_system: Node
@export var drive_system: Node
@export var maintenance_system: Node
@export var game_ui: Node

@onready var car_body: RigidBody3D

func _ready() -> void:
	_connect_signals()
	_start_game()

func _connect_signals() -> void:
	if assembly_system and assembly_system.assembly_complete.get_connection_count() == 0:
		assembly_system.assembly_complete.connect(_on_assembly_complete)

	if car_state_manager:
		car_state_manager.state_changed.connect(_on_state_changed)
		car_state_manager.needs_maintenance.connect(_on_needs_maintenance)

func _start_game() -> void:
	print("[GameManager] Jogo iniciado!")
	if car_state_manager:
		update_ui_for_state(car_state_manager.current_state)

## handlers

func _on_assembly_complete() -> void:
	print("[GameManager] Montagem completa!")
	if car_state_manager:
		car_state_manager.complete_assembly()

func _on_state_changed(from_state: int, to_state: int) -> void:
	print("[GameManager] Estado: ", CarStateManager.CarState.keys()[to_state])
	if game_ui:
		update_ui_for_state(to_state)

func _on_needs_maintenance(type: String) -> void:
	print("[GameManager] Manutenção: ", type)
	if game_ui and game_ui.has_method("set_action_button"):
		game_ui.set_action_button(type)

func _on_ui_button_pressed(action: String) -> void:
	match action:
		"wash":
			if car_state_manager and car_state_manager.current_state == CarStateManager.CarState.ASSEMBLED:
				car_state_manager.wash_car()
		"drive":
			if car_state_manager and car_state_manager.can_drive():
				car_state_manager.start_driving()
		"reset":
			reset_game()

## UI

func update_ui_for_state(state: int) -> void:
	if not game_ui or not game_ui.has_method("update_ui"):
		return

	match state:
		CarStateManager.CarState.UNASSEMBLED:
			var prog := 0.0
			if assembly_system:
				prog = assembly_system.get_placed_parts() / float(max(1, assembly_system.get_total_parts()))
			game_ui.update_ui("Monte o carro!", prog)
			if game_ui.has_method("set_action_button"):
				game_ui.set_action_button("")

		CarStateManager.CarState.ASSEMBLED:
			game_ui.update_ui("Carro Montado! Hora de lavar.", 1.0)
			if game_ui.has_method("set_action_button"):
				game_ui.set_action_button("wash")

		CarStateManager.CarState.READY_TO_DRIVE:
			game_ui.update_ui("Pronto para dirigir!", 1.0)
			if game_ui.has_method("set_action_button"):
				game_ui.set_action_button("drive")

		CarStateManager.CarState.DRIVING:
			game_ui.update_ui("Dirigindo...", 1.0)

		CarStateManager.CarState.DIRTY, CarStateManager.CarState.BROKEN:
			game_ui.update_ui("Precisa de manutenção!", 0.0)
			if game_ui.has_method("set_action_button"):
				game_ui.set_action_button("repair")

func _process(delta: float) -> void:
	if car_state_manager and game_ui and game_ui.has_method("update_fuel"):
		game_ui.update_fuel(car_state_manager.fuel)
		game_ui.update_condition(car_state_manager.condition)

func reset_game() -> void:
	print("[GameManager] Resetando...")
	if car_state_manager:
		car_state_manager.reset_car()
	if assembly_system:
		assembly_system.reset_assembly()
	if car_state_manager:
		update_ui_for_state(car_state_manager.current_state)
