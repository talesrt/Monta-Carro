extends RigidBody3D
class_name DraggablePart

## Uma peça do carro que pode ser arrastada com mouse

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
	freeze = true
	print("[Part] ", part_name, " ready at ", original_position)

func _physics_process(_delta):
	# Verificar input de mouse
	if Input.is_action_just_pressed("ui_click"):  # Botão esquerdo do mouse
		# Verificar se mouse está sobre este objeto
		var mouse_pos = get_viewport().get_mouse_position()
		if camera:
			var from = camera.project_ray_origin(mouse_pos)
			var to = from + camera.project_ray_normal(mouse_pos) * 1000
			
			var space = get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(from, to)
			var result = space.intersect_ray(query)
			
			if result and result.collider == self:
				start_drag()
	
	elif Input.is_action_just_released("ui_click"):
		if is_dragging:
			end_drag()

func start_drag():
	if is_placed:
		return
	
	camera = get_viewport().get_camera_3d()
	is_dragging = true
	freeze = false
	picked_up.emit()
	print("[Part] ", part_name, " started dragging")

func end_drag():
	if not is_dragging:
		return
	
	is_dragging = false
	
	# Verificar se está perto da posição correta
	var distance = global_position.distance_to(target_position)
	
	if distance <= snap_distance:
		global_position = target_position
		is_placed = true
		freeze = true
		placed_correctly.emit()
		print("[Part] ", part_name, " placed correctly!")
	else:
		global_position = original_position
		freeze = true
	
	dropped.emit()

func _process(_delta):
	# Mover com mouse enquanto arrasta
	if is_dragging and camera:
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var dir = camera.project_ray_normal(mouse_pos)
		
		# Criar plano na altura do objeto
		var plane = Plane(Vector3.UP, original_position.y)
		var intersect = plane.intersects_ray(from, dir)
		
		if intersect:
			global_position = intersect

func reset():
	global_position = original_position
	is_placed = false
	is_dragging = false
	freeze = true
