extends Node3D
class_name DraggablePart

## Uma peça do carro - abordagem simplificada

signal placed_correctly
signal picked_up
signal dropped

@export var target_position: Vector3 = Vector3.ZERO
@export var snap_distance: float = 1.5
@export var part_name: String = "part"

var is_placed: bool = false
var is_dragging: bool = false
var original_position: Vector3
var camera: Camera3D

func _ready() -> void:
	original_position = global_position
	input_ray_pickable = true
	print("[Part] ", part_name, " ready at ", original_position)

func _input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			start_drag()
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			end_drag()

func _process(_delta):
	if is_dragging and camera:
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var dir = camera.project_ray_normal(mouse_pos)
		
		var plane = Plane(Vector3.UP, original_position.y)
		var intersect = plane.intersects_ray(from, dir)
		
		if intersect:
			global_position = intersect

func start_drag():
	if is_placed:
		return
	
	camera = get_viewport().get_camera_3d()
	is_dragging = true
	picked_up.emit()
	print("[Part] ", part_name, " started dragging")

func end_drag():
	if not is_dragging:
		return
	
	is_dragging = false
	
	var distance = global_position.distance_to(target_position)
	
	if distance <= snap_distance:
		global_position = target_position
		is_placed = true
		placed_correctly.emit()
		print("[Part] ", part_name, " placed correctly!")
	else:
		global_position = original_position
	
	dropped.emit()

func reset():
	global_position = original_position
	is_placed = false
	is_dragging = false
