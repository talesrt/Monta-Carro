extends Node3D

## Cena principal do jogo - gerencia o fluxo geral

@onready var car_state_manager: CarStateManager = $CarStateManager
@onready var camera: Camera3D = $Camera3D
@onready var ui: Control = $UI

# Referências para os sistemas
@export var assembly_system_path: NodePath
@export var drive_system_path: NodePath

var current_phase: String = "assembly" # assembly, wash, drive, maintenance

func _ready() -> void:
	# Conectar sinais
	car_state_manager.state_changed.connect(_on_state_changed)
	car_state_manager.needs_maintenance.connect(_on_needs_maintenance)
	
	# Iniciar na fase de montagem
	start_assembly_phase()

func _process(delta: float) -> void:
	# Updates globais aqui
	pass

## Fases do jogo

func start_assembly_phase() -> void:
	current_phase = "assembly"
	print("[Game] Fase: Montagem")
	# Aqui chamaria o sistema de montagem

func start_wash_phase() -> void:
	current_phase = "wash"
	print("[Game] Fase: Lavagem")
	# Aqui chamaria o sistema de lavagem

func start_drive_phase() -> void:
	current_phase = "drive"
	print("[Game] Fase: Direção")
	# Aqui chamaria o sistema de direção

func start_maintenance_phase() -> void:
	current_phase = "maintenance"
	print("[Game] Fase: Manutenção")
	# Aqui chamaria o sistema de manutenção

## Sinais

func _on_state_changed(from_state: int, to_state: int) -> void:
	print("[Game] Estado mudou: ", CarStateManager.CarState.keys()[from_state], " -> ", CarStateManager.CarState.keys()[to_state])
	
	# Transicionar fases baseado no estado
	match to_state:
		CarStateManager.CarState.ASSEMBLED:
			start_wash_phase()
		CarStateManager.CarState.READY_TO_DRIVE:
			# Esperar input do jogador para dirigir
			pass
		CarStateManager.CarState.DRIVING:
			pass
		CarStateManager.CarState.DIRTY, CarStateManager.CarState.BROKEN:
			start_maintenance_phase()

func _on_needs_maintenance(type: String) -> void:
	print("[Game] Precisa de manutenção: ", type)
	# Notificar UI

## Funções públicas para UI

func on_drive_button_pressed() -> void:
	if car_state_manager.can_drive():
		car_state_manager.start_driving()

func on_wash_button_pressed() -> void:
	if car_state_manager.current_state == CarStateManager.CarState.ASSEMBLED:
		car_state_manager.wash_car()

func on_refuel_button_pressed() -> void:
	car_state_manager.refuel()

func on_repair_button_pressed() -> void:
	car_state_manager.repair()
