extends StaticBody3D
class_name DraggablePart

## Sistema de drag & drop - versão final com debug

signal placed_correctly
signal picked_up
signal dropped

@export var target_position: Vector3 = Vector3.ZERO
@export var snap_distance: float = 1.0
@export var part_name: String = "part"

var is_placed: bool = false
var is_dragging: bool = false
var original_position: Vector3

func _ready() -> void:
	original_position = global_position
	
	# CONFIGURAÇÃO CRÍTICA PARA DETECTAR CLIQUE!
	input_ray_pickable = true
	
	print("[Part] ", part_name, " ready at ", original_position)
	print("[Part] ", part_name, " input_ray_pickable = ", input_ray_pickable)

# ESTE É O MÉTODO CORRETO PARA DETECTAR CLIQUE EM 3D!
func _input_event(camera: Camera3D, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	print("[Part] ", part_name, " _input_event called!")
	
	if event is InputEventMouseButton:
		print("[Part] ", part_name, " MouseButton: button_index=", event.button_index, " pressed=", event.pressed)
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				print("[Part] ", part_name, " CLICK DETECTADO - Starting drag")
				_start_drag(camera)
			else:
				print("[Part] ", part_name, " RELEASE - Ending drag")
				_end_drag()

func _process(delta: float) -> void:
	if is_dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		var camera = get_viewport().get_camera_3d()
		
		if camera:
			var from = camera.project_ray_origin(mouse_pos)
			var dir = camera.project_ray_normal(mouse_pos)
			var plane = Plane(Vector3.UP, original_position.y)
			var new_pos = plane.intersects_ray(from, dir)
			
			if new_pos:
				global_position = new_pos

func _start_drag(camera: Camera3D) -> void:
	if is_placed:
		print("[Part] ", part_name, " Already placed!")
		return
	
	if not camera:
		camera = get_viewport().get_camera_3d()
	
	if not camera:
		print("[Part] ", part_name, " ERROR: No camera found!")
		return
	
	print("[Part] ", part_name, " Drag STARTED")
	is_dragging = true
	picked_up.emit()

func _end_drag() -> void:
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

func reset() -> void:
	global_position = original_position
	is_placed = false
	is_dragging = false
