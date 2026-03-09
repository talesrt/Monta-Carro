extends Node3D
class_name AssemblySystem

## Sistema de montagem do carro - com suporte a GLB

signal assembly_complete
signal part_placed(part_name: String)
signal progress_changed(placed: int, total: int)

@export var parts_container: Node3D
@export var model_path: String = "res://assets/models/Car_1.glb"
@export var auto_load_model: bool = true

# Referências para as peças
var parts: Array[DraggablePart] = []
var placed_count: int = 0
var loaded_model: Node3D = null

func _ready() -> void:
	# Carregar modelo se habilitado
	if auto_load_model and model_path != "":
		_load_model()
	
	# Procurar peças
	_find_parts()
	print("[Assembly] Sistema de montagem pronto. Peças: ", parts.size())

func _load_model() -> void:
	print("[Assembly] Carregando modelo: ", model_path)
	var scene = load(model_path)
	if scene:
		loaded_model = scene.instantiate()
		add_child(loaded_model)
		print("[Assembly] Modelo instanciado: ", loaded_model.name)
		
		# Desabilitar física do modelo
		_disable_model_physics(loaded_model)
	else:
		print("[Assembly] ERRO: Não conseguiu carregar modelo")

func _disable_model_physics(node: Node) -> void:
	# Desabilitar RigidBody
	if node is RigidBody3D:
		node.freeze = true
		node.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
		print("[Assembly] RigidBody3D desabilitado: ", node.name)
	
	# Desabilitar CollisionShape3D
	if node is CollisionShape3D:
		node.disabled = true
	
	# Procura recursivamente
	for child in node.get_children():
		_disable_model_physics(child)

func _find_parts() -> void:
	var container: Node
	
	if parts_container:
		container = parts_container
	else:
		container = get_node_or_null("PartsContainer")
		if not container:
			container = self
	
	if container:
		_find_parts_in_node(container)

func _find_parts_in_node(node: Node) -> void:
	for child in node.get_children():
		if child is DraggablePart:
			parts.append(child)
			if not child.placed_correctly.is_connected(_on_part_placed):
				child.placed_correctly.connect(_on_part_placed)
			print("[Assembly] Encontrada peça: ", child.part_name)
		
		if child.get_child_count() > 0:
			_find_parts_in_node(child)

func get_total_parts() -> int:
	return parts.size()

func get_placed_parts() -> int:
	return placed_count

func is_complete() -> bool:
	return placed_count >= parts.size()

func _on_part_placed() -> void:
	print("[Assembly] _on_part_placed chamado!")
	placed_count += 1
	
	for part in parts:
		if part.is_placed:
			print("[Assembly] Peça disparou: ", part.part_name)
			part_placed.emit(part.part_name)
	
	progress_changed.emit(placed_count, parts.size())
	
	print("[Assembly] Peça colocada! ", placed_count, "/", parts.size())
	
	if is_complete():
		print("[Assembly] Montagem COMPLETA!")
		assembly_complete.emit()

func reset_assembly() -> void:
	placed_count = 0
	for part in parts:
		part.reset()
	progress_changed.emit(0, parts.size())
