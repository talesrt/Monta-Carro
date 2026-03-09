extends StaticBody3D
class_name DraggablePart

## Sistema de drag & drop - usando raycast manual

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
	print("[Part] ", part_name, " ready at ", original_position)

func _process(delta: float) -> void:
	# Sempre verificar clique do mouse
	if Input.is_action_just_pressed("ui_click"):
		_check_click()

func _check_click() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	
	if not camera:
		return
	
	# Raycast do mouse para ver se clicou nesta peça
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	
	var result = space.intersect_ray(query)
	
	if result and result.collider == self:
		print("[Part] ", part_name, " CLICKED!")
		start_drag()
	
	elif is_dragging:
		# Se está arrastando e clicou em outro lugar, soltar
		end_drag()

func _physics_process(delta: float) -> void:
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

func _input(event: InputEvent) -> void:
	# Soltar quando soltar o botão
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and is_dragging:
			end_drag()

func start_drag() -> void:
	if is_placed:
		print("[Part] ", part_name, " Already placed!")
		return
	
	print("[Part] ", part_name, " Drag started!")
	is_dragging = true
	picked_up.emit()

func end_drag() -> void:
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
