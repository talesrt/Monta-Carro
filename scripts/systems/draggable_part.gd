extends StaticBody3D
class_name DraggablePart

## Sistema de drag & drop - abordagem com physics raycast

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
var mouse_over: bool = false

func _ready() -> void:
	original_position = global_position
	input_ray_pickable = true  # IMPORTANTE!
	print("[Part] ", part_name, " ready at ", original_position)

func _input_event(camera, event, position, normal, shape_idx):
	# Este é o método correto para StaticBody3D/Area3D
	print("[Part] ", part_name, " _input_event: ", event)
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				print("[Part] ", part_name, " CLICK - Starting drag")
				start_drag()
			else:
				print("[Part] ", part_name, " RELEASE - Ending drag")
				end_drag()

func _process(delta):
	# Verificar se mouse está sobre o objeto
	if not mouse_over:
		return
	
	if is_dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var dir = camera.project_ray_normal(mouse_pos)
		
		# Plano horizontal na altura do objeto
		var plane = Plane(Vector3.UP, original_position.y)
		var new_pos = plane.intersects_ray(from, dir)
		
		if new_pos:
			global_position = new_pos

func _on_mouse_entered():
	print("[Part] ", part_name, " Mouse entered")
	mouse_over = true

func _on_mouse_exited():
	print("[Part] ", part_name, " Mouse exited")
	mouse_over = false

func start_drag():
	if is_placed:
		print("[Part] ", part_name, " Already placed!")
		return
	
	camera = get_viewport().get_camera_3d()
	if not camera:
		print("[Part] ", part_name, " ERROR: No camera!")
		return
	
	print("[Part] ", part_name, " Drag started!")
	is_dragging = true
	picked_up.emit()

func end_drag():
	if not is_dragging:
		return
	
	is_dragging = false
	
	var distance = global_position.distance_to(target_position)
	print("[Part] ", part_name, " Dropped! Distance: ", distance)
	
	if distance <= snap_distance:
		global_position = target_position
		is_placed = true
		placed_correctly.emit()
		print("[Part] ", part_name, " PLACED CORRECTLY!")
	else:
		global_position = original_position
		print("[Part] ", part_name, " Returned to start")
	
	dropped.emit()

func reset():
	global_position = original_position
	is_placed = false
	is_dragging = false
