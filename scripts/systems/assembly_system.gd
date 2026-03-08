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
	# Encontrar todas as peças automaticamente
	if parts_container:
		for child in parts_container.get_children():
			if child is DraggablePart:
				parts.append(child)
				child.placed_correctly.connect(_on_part_placed)
	
	print("[Assembly] Sistema de montagem pronto. Peças: ", parts.size())

func get_total_parts() -> int:
	return parts.size()

func get_placed_parts() -> int:
	return placed_count

func is_complete() -> bool:
	return placed_count >= parts.size()

func _on_part_placed() -> void:
	placed_count += 1
	var part = get_signal_source()
	if part:
		part_placed.emit(part.part_name)
	
	progress_changed.emit(placed_count, parts.size())
	
	print("[Assembly] Peça colocada! ", placed_count, "/", parts.size())
	
	# Verificar se todas as peças estão no lugar
	if is_complete():
		print("[Assembly] Montagem completa!")
		assembly_complete.emit()

func get_signal_source() -> DraggablePart:
	# Retorna a peça que disparou o sinal (solução alternativa)
	for part in parts:
		if part.is_placed:
			return part
	return null

func reset_assembly() -> void:
	placed_count = 0
	for part in parts:
		part.reset()
	progress_changed.emit(0, parts.size())
