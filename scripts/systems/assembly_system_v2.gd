extends Node3D
class_name AssemblySystem

## Sistema de montagem - conecta DraggableParts aos sockets do modelo GLB

signal assembly_complete
signal part_placed(part_name: String)
signal progress_changed(placed: int, total: int)

@export var parts_container: Node3D
@export var car_model_path: String = "res://assets/models/car_1.tscn"
@export var auto_load_model: bool = true

# Referências
var draggable_parts: Array[Node] = []
var placed_count: int = 0
var loaded_model: Node3D = null
var _total_parts: int = 0

func _ready() -> void:
	if auto_load_model and car_model_path != "":
		_load_model()
	_find_parts()
	print("[Assembly] Sistema pronto. Peças encontradas: %d" % draggable_parts.size())

func _load_model() -> void:
	print("[Assembly] Carregando modelo: ", car_model_path)
	var scene = load(car_model_path)
	if scene:
		loaded_model = scene.instantiate()
		add_child(loaded_model)
		_disable_model_physics(loaded_model)
		print("[Assembly] Modelo instanciado: ", loaded_model.name)
	else:
		print("[Assembly] ERRO: Não conseguiu carregar modelo")

func _disable_model_physics(node: Node) -> void:
	if node is RigidBody3D:
		node.freeze = true
		node.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	if node is CollisionShape3D:
		node.disabled = true
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
		_drill_for_parts(container)
		_connect_signals()
		_total_parts = draggable_parts.size()

func _drill_for_parts(node: Node) -> void:
	for child in node.get_children():
		# Aceita tanto DraggablePart (Area3D) quanto StaticBody3D com o script
		if child.has_method("start_dragging") and child.has_signal("part_snapped"):
			draggable_parts.append(child)
			print("[Assembly] Peça encontrada: ", child.name)
		if child.get_child_count() > 0:
			_drill_for_parts(child)

func _connect_signals() -> void:
	for part in draggable_parts:
		if part.has_signal("part_snapped") and part.part_snapped.get_connection_count() == 0:
			part.part_snapped.connect(_on_part_snapped)

func _on_part_snapped(part_name: String) -> void:
	print("[Assembly] Peça encaixada: ", part_name)
	placed_count += 1
	part_placed.emit(part_name)
	progress_changed.emit(placed_count, _total_parts)

	if placed_count >= _total_parts and _total_parts > 0:
		print("[Assembly] MONTAGEM COMPLETA!")
		assembly_complete.emit()

func get_total_parts() -> int:
	return _total_parts

func get_placed_parts() -> int:
	return placed_count

func is_complete() -> bool:
	return placed_count >= _total_parts and _total_parts > 0

func reset_assembly() -> void:
	placed_count = 0
	for part in draggable_parts:
		if part.has_method("reset"):
			part.reset()
		elif part.has_method("set_placed"):
			part.set_placed(false)
	progress_changed.emit(0, _total_parts)
