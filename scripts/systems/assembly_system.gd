extends Node3D
class_name AssemblySystem

## Sistema de montagem do carro - gerencia as peças e validação

signal assembly_complete
signal part_placed(part_name: String)
signal progress_changed(placed: int, total: int)

@export var parts_container: Node3D

# Referências para as peças (definir no editor ou via código)
var parts: Array[DraggablePart] = []
var placed_count: int = 0

func _ready() -> void:
	# Procurar peças
	_find_parts()
	print("[Assembly] Sistema de montagem pronto. Peças: ", parts.size())

func _find_parts() -> void:
	var container: Node
	
	# Se parts_container está definido, usar ele
	if parts_container:
		container = parts_container
		print("[Assembly] Usando parts_container definido: ", container.name)
	else:
		# Se não, procurar PartsContainer como filho
		container = get_node_or_null("PartsContainer")
		if container:
			print("[Assembly] PartsContainer encontrado automaticamente")
		else:
			# Se não encontrar, usar este nó
			container = self
			print("[Assembly] Usando self como container")
	
	if container:
		# Procurar peças nos filhos (e netos)
		_find_parts_in_node(container)

func _find_parts_in_node(node: Node) -> void:
	for child in node.get_children():
		if child is DraggablePart:
			parts.append(child)
			# Conectar sinal diretamente aqui para garantir
			if not child.placed_correctly.is_connected(_on_part_placed):
				child.placed_correctly.connect(_on_part_placed)
			print("[Assembly] Encontrada peça: ", child.part_name)
		# Procurar nos netos também (recursivo)
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
	
	# Encontrar qual peça disparou
	for part in parts:
		if part.is_placed:
			print("[Assembly] Peça disparou: ", part.part_name)
			part_placed.emit(part.part_name)
	
	progress_changed.emit(placed_count, parts.size())
	
	print("[Assembly] Peça colocada! ", placed_count, "/", parts.size())
	
	# Verificar se todas as peças estão no lugar
	if is_complete():
		print("[Assembly] Montagem COMPLETA! Emitindo sinal...")
		assembly_complete.emit()
		print("[Assembly] Sinal assembly_complete.emit() enviado!")

func reset_assembly() -> void:
	placed_count = 0
	for part in parts:
		part.reset()
	progress_changed.emit(0, parts.size())
