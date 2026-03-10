extends Node3D
class_name AssemblySystemV2

## Sistema de montagem v2 - conecta DraggableParts aos sockets do modelo GLB

signal assembly_complete
signal part_placed(part_name: String)
signal progress_changed(placed: int, total: int)

@export var parts_container: Node3D
@export var car_model_path: String = "res://assets/models/car_1.tscn"
@export var auto_load_model: bool = true

# Referências
var draggable_parts: Array[Area3D] = []
var snap_points: Array[Area3D] = []
var placed_count: int = 0
var loaded_model: Node3D = null

# Mapeamento de peças para sockets
# formato: { "WheelFL": "socket_wheel_FL", "Engine": "socket_engine", etc }
var part_to_socket_map: Dictionary = {
	"WheelFL": "socket_wheel_FL",
	"WheelFR": "socket_wheel_FR", 
	"WheelRL": "socket_wheel_RL",
	"WheelRR": "socket_wheel_RR",
	"Engine": "socket_engine",
	"Chassis": "socket_frame"
}

func _ready() -> void:
	# Carregar modelo se habilitado
	if auto_load_model and car_model_path != "":
		_load_model()
	
	# Procurar peças e sockets
	_find_parts_and_sockets()
	
	print("[AssemblyV2] Sistema pronto. Peças: %d, Sockets: %d" % [draggable_parts.size(), snap_points.size()])

func _load_model() -> void:
	print("[AssemblyV2] Carregando modelo: ", car_model_path)
	var scene = load(car_model_path)
	if scene:
		loaded_model = scene.instantiate()
		add_child(loaded_model)
		print("[AssemblyV2] Modelo instanciado: ", loaded_model.name)
		
		# Desabilitar física do modelo
		_disable_model_physics(loaded_model)
	else:
		print("[AssemblyV2] ERRO: Não conseguiu carregar modelo")

func _disable_model_physics(node: Node) -> void:
	if node is RigidBody3D:
		node.freeze = true
		node.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	
	if node is CollisionShape3D:
		node.disabled = true
	
	for child in node.get_children():
		_disable_model_physics(child)

func _find_parts_and_sockets() -> void:
	var container: Node
	
	if parts_container:
		container = parts_container
	else:
		container = get_node_or_null("PartsContainer")
		if not container:
			container = self
	
	if container:
		# Procurar DraggableParts
		_find_draggable_parts(container)
		
		# Procurar SnapPoints no modelo carregado
		if loaded_model:
			_find_snap_points(loaded_model)
		
		# Conectar sinais
		_connect_signals()

func _find_draggable_parts(node: Node) -> void:
	for child in node.get_children():
		if child is Area3D:
			# Verificar se tem script de draggable
			if child.has_method("start_dragging"):
				draggable_parts.append(child)
				print("[AssemblyV2] Encontrada peça arrastável: ", child.name)
		
		if child.get_child_count() > 0:
			_find_draggable_parts(child)

func _find_snap_points(node: Node) -> void:
	for child in node.get_children():
		# Verificar se é um SnapPoint (tem script ou está no grupo)
		if child.is_in_group("snap_points") or child.has_method("_on_part_snapped"):
			snap_points.append(child)
			print("[AssemblyV2] Encontrado socket: ", child.name)
		
		# Procura recursiva
		if child.get_child_count() > 0:
			_find_snap_points(child)

func _connect_signals() -> void:
	for part in draggable_parts:
		# Conectar sinal de snapped
		if part.has_signal("part_snapped"):
			part.part_snapped.connect(_on_part_snapped.bind(part.name))
		
		# Conectar sinal de dropped
		if part.has_signal("part_dropped"):
			part.part_dropped.connect(_on_part_dropped.bind(part))

func _on_part_snapped(part_name: String) -> void:
	print("[AssemblyV2] Peça encaixada: ", part_name)
	placed_count += 1
	part_placed.emit(part_name)
	progress_changed.emit(placed_count, draggable_parts.size())
	
	if placed_count >= draggable_parts.size():
		print("[AssemblyV2] MONTAGEM COMPLETA!")
		assembly_complete.emit()

func _on_part_dropped(part_name: String, success: bool, part: Area3D) -> void:
	if success:
		# Verificar se encaixou no socket correto
		var expected_socket = part_to_socket_map.get(part_name, "")
		if expected_socket != "":
			_find_and_snap_to_socket(part, expected_socket)

func _find_and_snap_to_socket(part: Area3D, socket_name: String) -> void:
	if not loaded_model:
		return
	
	# Procurar socket pelo nome no modelo
	var socket = _find_node_by_name(loaded_model, socket_name)
	if socket:
		print("[AssemblyV2] Encontrou socket: ", socket_name, " em ", socket.global_position)
		# O SnapPoint.gd vai handles o snap automaticamente
	else:
		print("[AssemblyV2] Socket não encontrado: ", socket_name)

func _find_node_by_name(node: Node, target_name: String) -> Node:
	if node.name == target_name:
		return node
	
	for child in node.get_children():
		var result = _find_node_by_name(child, target_name)
		if result:
			return result
	
	return null

func get_total_parts() -> int:
	return draggable_parts.size()

func get_placed_parts() -> int:
	return placed_count

func is_complete() -> bool:
	return placed_count >= draggable_parts.size()

func reset_assembly() -> void:
	placed_count = 0
	for part in draggable_parts:
		if part.has_method("reset"):
			part.reset()
	progress_changed.emit(0, draggable_parts.size())
