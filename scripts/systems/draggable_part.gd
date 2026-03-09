extends Area3D
class_name DraggablePart

## Sistema de drag & drop debugado

signal placed_correctly
signal picked_up
signal dropped

@export var target_position: Vector3 = Vector3.ZERO
@export var snap_distance: float = 1.0
@export var part_name: String = "part"

var is_placed: bool = false
var is_dragging: bool = false
var original_position: Vector3
var camera: Camera3D
var dragging_object: Node3D = null

func _ready() -> void:
	original_position = global_position
	input_ray_pickable = true
	print("[Part] ", part_name, " ready at ", original_position)

func _input_event(_viewport, event, _position, _normal, _shape_idx):
	print("[Part] ", part_name, " INPUT EVENT: ", event)
	if event is InputEventMouseButton:
		print("[Part] ", part_name, " Mouse button: pressed=", event.pressed, " button_index=", event.button_index)
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				print("[Part] ", part_name, " Starting drag...")
				start_drag()
			else:
				print("[Part] ", part_name, " Ending drag...")
				end_drag()

func _input(event):
	# Usar input global como backup
	if event is InputEventMouseMotion and is_dragging:
		process_drag(event.position)

func start_drag():
	if is_placed:
		print("[Part] ", part_name, " Already placed!")
		return
	
	camera = get_viewport().get_camera_3d()
	if not camera:
		# Tentar encontrar camera de outra forma
		camera = get_tree().get_first_node_in_group("main_camera") as Camera3D
		if not camera:
			print("[Part] ", part_name, " ERROR: No camera found!")
			return
	
	print("[Part] ", part_name, " Camera found: ", camera.name)
	is_dragging = true
	picked_up.emit()

func process_drag(mouse_pos: Vector2):
	if not camera:
		return
	
	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)
	var plane = Plane(Vector3.UP, original_position.y)
	var new_pos = plane.intersects_ray(from, dir)
	
	if new_pos:
		global_position = new_pos
		#print("[Part] ", part_name, " Pos: ", new_pos)

func end_drag():
	if not is_dragging:
		return
	
	is_dragging = false
	
	var distance = global_position.distance_to(target_position)
	print("[Part] ", part_name, " Dropped! Distance to target: ", distance)
	
	if distance <= snap_distance:
		global_position = target_position
		is_placed = true
		placed_correctly.emit()
		print("[Part] ", part_name, " PLACED!")
	else:
		global_position = original_position
		print("[Part] ", part_name, " Returned to start")
	
	dropped.emit()

func reset():
	global_position = original_position
	is_placed = false
	is_dragging = false
