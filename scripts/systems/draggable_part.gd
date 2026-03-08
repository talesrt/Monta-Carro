extends Area3D
class_name DraggablePart

## Uma peça do carro que pode ser arrastada com mouse

signal placed_correctly
signal picked_up
signal dropped

@export var target_position: Vector3 = Vector3.ZERO
@export var snap_distance: float = 1.5
@export var part_name: String = "part"
@export var mesh_instance: MeshInstance3D

var is_placed: bool = false
var is_dragging: bool = false
var original_position: Vector3
var camera: Camera3D

func _ready() -> void:
	original_position = global_position
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	print("[Part] ", part_name, " ready at ", original_position)

func _input_event(_viewport, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_drag()
			else:
				end_drag()

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
	
	# Verificar se está perto da posição correta
	var distance = global_position.distance_to(target_position)
	
	if distance <= snap_distance:
		global_position = target_position
		is_placed = true
		placed_correctly.emit()
		print("[Part] ", part_name, " placed correctly!")
	else:
		global_position = original_position
	
	dropped.emit()

func _on_mouse_entered():
	# Highlight quando mouse está sobre a peça
	if mesh_instance and mesh_instance.get_surface_override_material(0) == null:
		# Poderia adicionar highlight aqui
		pass

func _on_mouse_exited():
	pass

func reset():
	global_position = original_position
	is_placed = false
	is_dragging = false
