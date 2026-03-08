extends Node3D
class_name GameManager

## Gerenciador principal do jogo - conecta todos os sistemas

@export var car_state_manager: CarStateManager
@export var assembly_system: AssemblySystem
@export var wash_system: WashSystem
@export var drive_system: DriveSystem
@export var maintenance_system: MaintenanceSystem
@export var game_ui: GameUI

# Referências para o carro (para movimento)
@onready var car_body: RigidBody3D

# Cena do carro completo (para quando montado)
var car_scene: PackedScene

func _ready() -> void:
	_connect_signals()
	_start_game()

func _connect_signals() -> void:
	# Assembly
	if assembly_system:
		assembly_system.assembly_complete.connect(_on_assembly_complete)
	
	# Wash
	if wash_system:
		wash_system.wash_complete.connect(_on_wash_complete)
	
	# Drive
	if drive_system:
		drive_system.drive_stopped.connect(_on_drive_stopped)
	
	# Car State
	if car_state_manager:
		car_state_manager.state_changed.connect(_on_state_changed)
		car_state_manager.needs_maintenance.connect(_on_needs_maintenance)

func _start_game() -> void:
	print("[GameManager] Jogo iniciado!")
	update_ui_for_state(CarStateManager.CarState.UNASSEMBLED)

## Conexão dos sistemas

func setup_assembly(system: AssemblySystem) -> void:
	assembly_system = system
	if system:
		system.assembly_complete.connect(_on_assembly_complete)

func setup_wash(system: WashSystem) -> void:
	wash_system = system

func setup_drive(system: DriveSystem) -> void:
	drive_system = system
	if system:
		system.car_body = car_body

func setup_maintenance(system: MaintenanceSystem) -> void:
	maintenance_system = system

func setup_ui(ui: GameUI) -> void:
	game_ui = ui
	if ui:
		ui.button_pressed.connect(_on_ui_button_pressed)

## handlers de eventos

func _on_assembly_complete() -> void:
	print("[GameManager] Montagem completa!")
	car_state_manager.complete_assembly()

func _on_wash_complete(cleanliness: float) -> void:
	print("[GameManager] Lavagem completa!")
	car_state_manager.wash_car()

func _on_drive_stopped() -> void:
	print("[GameManager] Direção parada!")
	car_state_manager.stop_driving()

func _on_state_changed(from_state: int, to_state: int) -> void:
	print("[GameManager] Estado mudou para: ", CarStateManager.CarState.keys()[to_state])
	update_ui_for_state(to_state)

func _on_needs_maintenance(type: String) -> void:
	print("[GameManager] Precisa de manutenção: ", type)
	game_ui.set_action_button(type)

func _on_ui_button_pressed(action: String) -> void:
	match action:
		"wash":
			if car_state_manager.current_state == CarStateManager.CarState.ASSEMBLED:
				car_state_manager.wash_car()
		"drive":
			if car_state_manager.can_drive():
				car_state_manager.start_driving()
				drive_system.start_drive()
		"refuel":
			if maintenance_system:
				maintenance_system.start_refuel()
		"repair":
			if maintenance_system:
				maintenance_system.start_repair()
		"reset":
			reset_game()

## Atualizar UI baseado no estado

func update_ui_for_state(state: int) -> void:
	if not game_ui:
		return
	
	match state:
		CarStateManager.CarState.UNASSEMBLED:
			game_ui.update_ui("Monte o carro!", assembly_system.get_placed_parts() / float(max(1, assembly_system.get_total_parts())))
			game_ui.set_action_button("wash")
			game_ui.show_fuel_bar(false)
			game_ui.show_condition_bar(false)
		
		CarStateManager.CarState.ASSEMBLED:
			game_ui.update_ui("Carro Montado! Hora de lavar.", 1.0)
			game_ui.set_action_button("wash")
		
		CarStateManager.CarState.READY_TO_DRIVE:
			game_ui.update_ui("Pronto para dirigir!", 1.0)
			game_ui.set_action_button("drive")
			game_ui.show_fuel_bar(true)
			game_ui.show_condition_bar(true)
		
		CarStateManager.CarState.DRIVING:
			game_ui.update_ui("Dirigindo...", 1.0)
			game_ui.set_action_button("drive")
		
		CarStateManager.CarState.DIRTY, CarStateManager.CarState.BROKEN:
			game_ui.update_ui("Precisa de manutenção!", 0.0)
			game_ui.show_fuel_bar(true)
			game_ui.show_condition_bar(true)
			
			# Mostrar botão de manutenção apropriado
			if maintenance_system:
				var needed = maintenance_system.get_maintenance_types_needed()
				if needed.size() > 0:
					game_ui.set_action_button(needed[0])

func _process(delta: float) -> void:
	# Atualizar barras de status
	if car_state_manager and game_ui:
		game_ui.update_fuel(car_state_manager.fuel)
		game_ui.update_condition(car_state_manager.condition)

func reset_game() -> void:
	print("[GameManager] Resetando jogo...")
	car_state_manager.reset_car()
	if assembly_system:
		assembly_system.reset_assembly()
	if drive_system:
		drive_system.reset_drive()
	update_ui_for_state(CarStateManager.CarState.UNASSEMBLED)
