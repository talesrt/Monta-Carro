extends Node3D
class_name DriveSystem

## Sistema de direção do carro

signal drive_started
signal drive_stopped
signal distance_updated(distance: float)
signal fuel_updated(fuel: float)

@export var car_body: RigidBody3D

var is_driving: bool = false
var move_speed: float = 5.0
var turn_speed: float = 2.0
var current_distance: float = 0.0
var input_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	print("[Drive] Sistema de direção pronto")

func _physics_process(delta: float) -> void:
	if not is_driving or not car_body:
		return
	
	# Processar input
	var velocity = Vector3.ZERO
	
	# Forward/backward
	if input_direction.y != 0:
		velocity.z = -input_direction.y * move_speed * delta
	
	# Turning
	if input_direction.x != 0:
		car_body.rotate_y(input_direction.x * turn_speed * delta)
	
	# Aplicar movimento
	if velocity != Vector3.ZERO:
		car_body.apply_central_force(velocity * 10.0)
		current_distance += velocity.length()
		distance_updated.emit(current_distance)

func _process(delta: float) -> void:
	# Input do teclado para teste
	if Input.is_action_pressed("ui_up"):
		input_direction.y = 1.0
	elif Input.is_action_pressed("ui_down"):
		input_direction.y = -1.0
	else:
		input_direction.y = move_toward(input_direction.y, 0, delta * 5.0)
	
	if Input.is_action_pressed("ui_left"):
		input_direction.x = 1.0
	elif Input.is_action_pressed("ui_right"):
		input_direction.x = -1.0
	else:
		input_direction.x = move_toward(input_direction.x, 0, delta * 5.0)

func start_drive() -> void:
	if is_driving:
		return
	is_driving = true
	print("[Drive] Direção iniciada!")
	drive_started.emit()

func stop_drive() -> void:
	if not is_driving:
		return
	is_driving = false
	print("[Drive] Direção parada. Distância: ", current_distance, "m")
	drive_stopped.emit()

func reset_drive() -> void:
	stop_drive()
	current_distance = 0.0
	distance_updated.emit(0.0)

func get_distance() -> float:
	return current_distance

func set_movement_input(direction: Vector2) -> void:
	# Para input touch
	input_direction = direction
