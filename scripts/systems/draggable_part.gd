extends Area3D
class_name DraggablePart

## Sistema simples de drag & drop para 3D

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

func _ready() -> void:
	original_position = global_position
	# Garantir que input_ray_pickable está habilitado
	input_ray_pickable = true
	print("[Part] ", part_name, " ready at ", original_position)

func _input_event(_viewport, event, _position, _normal, _shape_idx):
	# Este método é chamado quando o mouse clica no objeto
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_drag()
			else:
				end_drag()

func _process(_delta):
	# Mover objeto com mouse enquanto arrasta
	if is_dragging and camera:
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var dir = camera.project_ray_normal(mouse_pos)
		
		# Criar plano horizontal na altura do objeto
		var plane = Plane(Vector3.UP, original_position.y)
		var new_pos = plane.intersects_ray(from, dir)
		
		if new_pos:
			global_position = new_pos

func start_drag():
	if is_placed:
		return
	
	# Pegar a câmera principal
	camera = get_viewport().get_camera_3d()
	if not camera:
		print("[Part] ERROR: No camera found!")
		return
	
	is_dragging = true
	picked_up.emit()
	print("[Part] ", part_name, " started dragging")

func end_drag():
	if not is_dragging:
		return
	
	is_dragging = false
	
	# Verificar se está perto da posição de snap
	var distance = global_position.distance_to(target_position)
	print("[Part] ", part_name, " dropped at distance ", distance, " from target (snap: ", snap_distance, ")")
	
	if distance <= snap_distance:
		# Snap para posição correta
		global_position = target_position
		is_placed = true
		placed_correctly.emit()
		print("[Part] ", part_name, " PLACED CORRECTLY!")
	else:
		# Voltar para posição original
		global_position = original_position
	
	dropped.emit()

func reset():
	global_position = original_position
	is_placed = false
	is_dragging = false
