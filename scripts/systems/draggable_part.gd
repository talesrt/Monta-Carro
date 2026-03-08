extends RigidBody3D
class_name DraggablePart

## Uma peça do carro que pode ser arrastada

signal placed_correctly
signal picked_up
signal dropped

@export var target_position: Vector3 = Vector3.ZERO
@export var snap_distance: float = 1.5
@export var part_name: String = "part"

var is_placed: bool = false
var is_dragging: bool = false
var original_position: Vector3

func _ready() -> void:
	original_position = global_position
	freeze = true # Começa estático

func _input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_drag()
			else:
				end_drag()

func start_drag() -> void:
	if is_placed:
		return
	
	is_dragging = true
	freeze = false
	picked_up.emit()

func end_drag() -> void:
	if not is_dragging:
		return
	
	is_dragging = false
	
	# Verificar se está perto da posição correta
	var distance = global_position.distance_to(target_position)
	
	if distance <= snap_distance:
		# Snap para posição correta
		global_position = target_position
		is_placed = true
		freeze = true
		placed_correctly.emit()
		print("[Part] ", part_name, " placed correctly!")
	else:
		# Voltar para posição original
		global_position = original_position
		freeze = true
	
	dropped.emit()

func reset() -> void:
	global_position = original_position
	is_placed = false
	is_dragging = false
	freeze = true
