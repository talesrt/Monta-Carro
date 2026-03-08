extends Node3D
class_name WashSystem

## Sistema de lavagem do carro

signal wash_complete(cleanliness: float)
signal wash_progress_changed(progress: float)

@export var car_mesh: MeshInstance3D
@export var dirty_material: Material
@export var clean_material: Material

var cleanliness: float = 0.0 # 0 = sujo, 100 = limpo
var is_washing: bool = false
var wash_speed: float = 15.0 # Quanto limpa por segundo

# Áreas de sujeira (placeholder - nanti we'll have multiple dirty zones)
var dirty_zones: Array[MeshInstance3D] = []

func _ready() -> void:
	# Setup inicial - carro começa sujo
	set_dirty()

func _process(delta: float) -> void:
	if is_washing:
		cleanliness += wash_speed * delta
		cleanliness = min(100.0, cleanliness)
		
		wash_progress_changed.emit(cleanliness / 100.0)
		
		# Atualizar visual
		_update_cleanliness_visual()
		
		if cleanliness >= 100.0:
			finish_wash()

func start_wash() -> void:
	if cleanliness >= 100.0:
		return
	is_washing = true
	print("[Wash] Lavagem iniciada!")

func stop_wash() -> void:
	is_washing = false
	print("[Wash] Lavagem pausada. Limpeza: ", cleanliness, "%")

func finish_wash() -> void:
	is_washing = false
	cleanliness = 100.0
	set_clean()
	wash_complete.emit(cleanliness)
	print("[Wash] Lavagem completa! Carro limpo.")

func reset() -> void:
	is_washing = false
	cleanliness = 0.0
	set_dirty()

func set_dirty() -> void:
	cleanliness = 0.0
	if car_mesh and dirty_material:
		car_mesh.material_override = dirty_material
	print("[Wash] Carro sujo")

func set_clean() -> void:
	cleanliness = 100.0
	if car_mesh and clean_material:
		car_mesh.material_override = clean_material
	print("[Wash] Carro limpo")

func _update_cleanliness_visual() -> void:
	# Aqui我们可以 interpolar entre materiais ou transparency
	# Por enquanto, apenas log
	pass

func get_cleanliness_percentage() -> float:
	return cleanliness / 100.0
