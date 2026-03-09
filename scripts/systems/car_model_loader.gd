extends Node3D
class_name CarModelLoader

## Carrega o modelo GLB e detecta sockets para snap
## Desabilita física automática

@export var model_path: String = "res://assets/models/Car_1.glb"
@export var auto_load: bool = true

var loaded_model: Node3D = null
var sockets: Dictionary = {}

func _ready() -> void:
	if auto_load:
		load_model()

func load_model() -> void:
	print("[CarModel] Carregando modelo: ", model_path)
	
	var scene = load(model_path)
	if scene:
		loaded_model = scene.instantiate()
		add_child(loaded_model)
		print("[CarModel] Modelo instanciado: ", loaded_model.name)
		
		# Desabilitar física de todos os nós
		_disable_physics(loaded_model)
		
		_find_sockets(loaded_model)
	else:
		print("[CarModel] ERRO: Não conseguiu carregar modelo")

func _disable_physics(node: Node) -> void:
	# Desabilitar RigidBody
	if node is RigidBody3D:
		node.freeze = true
		node.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
		print("[CarModel] RigidBody3D desabilitado: ", node.name)
	
	# Desabilitar CollisionShape3D
	if node is CollisionShape3D:
		node.disabled = true
		print("[CarModel] CollisionShape3D desabilitado: ", node.name)
	
	# Procura recursivamente
	for child in node.get_children():
		_disable_physics(child)

func _find_sockets(node: Node) -> void:
	for child in node.get_children():
		var node_name = child.name
		
		# Detectar sockets pelo nome
		if node_name.begins_with("socket_"):
			sockets[node_name] = child
			print("[CarModel] Socket encontrado: ", node_name, " at ", child.global_position)
		
		# Procura recursivamente
		if child.get_child_count() > 0:
			_find_sockets(child)

func get_socket_position(socket_name: String) -> Vector3:
	if sockets.has(socket_name):
		return sockets[socket_name].global_position
	return Vector3.ZERO

func get_all_socket_names() -> Array[String]:
	return sockets.keys()
