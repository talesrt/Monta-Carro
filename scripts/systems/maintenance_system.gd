extends Node3D
class_name MaintenanceSystem

## Sistema de manutenção do carro

signal maintenance_complete(type: String)
signal maintenance_started(type: String)

enum MaintenanceType {
	REFUEL,    # Colocar gasolina
	REPAIR,    # Consertar motor/peças
	CLEAN      # Limpar (já coberto pelo wash system, mas mantido para compatibilidade)
}

@export var car_state_manager: CarStateManager

var current_maintenance: MaintenanceType = MaintenanceType.CLEAN
var is_maintaining: bool = false
var maintenance_speed: float = 25.0 # Porcentagem por segundo

func _ready() -> void:
	print("[Maintenance] Sistema de manutenção pronto")

func _process(delta: float) -> void:
	if not is_maintaining:
		return
	
	match current_maintenance:
		MaintenanceType.REFUEL:
			_perform_refuel(delta)
		MaintenanceType.REPAIR:
			_perform_repair(delta)
		MaintenanceType.CLEAN:
			# Limpeza é feita pelo wash system
			pass

func _perform_refuel(delta: float) -> void:
	if car_state_manager:
		car_state_manager.fuel += maintenance_speed * delta
		car_state_manager.fuel = min(100.0, car_state_manager.fuel)
		
		if car_state_manager.fuel >= 100.0:
			finish_maintenance("fuel")

func _perform_repair(delta: float) -> void:
	if car_state_manager:
		car_state_manager.condition += maintenance_speed * delta
		car_state_manager.condition = min(100.0, car_state_manager.condition)
		
		if car_state_manager.condition >= 100.0:
			finish_maintenance("repair")

func start_refuel() -> void:
	current_maintenance = MaintenanceType.REFUEL
	is_maintaining = true
	maintenance_started.emit("fuel")
	print("[Maintenance] Abastecendo...")

func start_repair() -> void:
	current_maintenance = MaintenanceType.REPAIR
	is_maintaining = true
	maintenance_started.emit("repair")
	print("[Maintenance] Reparando...")

func finish_maintenance(type: String) -> void:
	is_maintaining = false
	print("[Maintenance] Manutenção ", type, " completa!")
	maintenance_complete.emit(type)

func cancel_maintenance() -> void:
	is_maintaining = false
	print("[Maintenance] Manutenção cancelada")

func needs_refuel() -> bool:
	if car_state_manager:
		return car_state_manager.fuel < 100.0
	return false

func needs_repair() -> bool:
	if car_state_manager:
		return car_state_manager.condition < 100.0
	return false

func get_maintenance_types_needed() -> Array[String]:
	var needed: Array[String] = []
	if needs_refuel():
		needed.append("fuel")
	if needs_repair():
		needed.append("repair")
	return needed
