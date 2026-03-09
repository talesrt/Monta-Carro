extends Node3D
class_name CarModelLoader

## Carrega o modelo GLB e detecta sockets para snap

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
		
		_find_sockets(loaded_model)
	else:
		print("[CarModel] ERRO: Não conseguiu carregar modelo")

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
