extends Area3D
# Pontos onde as peças devem ser encaixadas
# Removi "class_name" para evitar conflitos

## Coloque estes nodes onde cada peça do carro deve ir

@export var part_type: String = "Roda"  ## Tipo de peça que aceita (deve corresponder ao part_name da peça)
@export var show_outline: bool = true  ## Mostrar contorno indicando onde colocar
@export var outline_color: Color = Color(1.0, 1.0, 0.0, 0.3)  ## Cor do contorno (amarelo transparente)

var is_occupied: bool = false
var outline_mesh: MeshInstance3D

signal part_placed(part_type)


func _ready():
	# Adicionar ao grupo para que peças possam encontrar
	add_to_group("snap_points")
	
	# Metadados para identificação
	set_meta("part_type", part_type)
	set_meta("occupied", false)
	
	# Criar outline visual
	if show_outline:
		create_outline()
	
	print("Ponto de encaixe criado para: %s" % part_type)


func create_outline():
	"""Cria um contorno visual mostrando onde colocar a peça"""
	outline_mesh = MeshInstance3D.new()
	add_child(outline_mesh)
	
	# Criar mesh (você pode ajustar o tamanho conforme a peça)
	var mesh = BoxMesh.new()
	mesh.size = Vector3(1, 1, 1)  # Ajuste conforme necessário
	outline_mesh.mesh = mesh
	
	# Material transparente
	var material = StandardMaterial3D.new()
	material.albedo_color = outline_color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	# Adicionar emissão para brilhar
	material.emission_enabled = true
	material.emission = outline_color
	material.emission_energy_multiplier = 0.5
	
	outline_mesh.set_surface_override_material(0, material)
	
	# Animar pulsação
	animate_outline()


func animate_outline():
	"""Faz o contorno pulsar para chamar atenção"""
	if not outline_mesh:
		return
		
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(outline_mesh, "scale", Vector3(1.1, 1.1, 1.1), 1.0)
	tween.tween_property(outline_mesh, "scale", Vector3(1.0, 1.0, 1.0), 1.0)


func _on_part_snapped():
	"""Chamado quando uma peça é encaixada aqui"""
	is_occupied = true
	set_meta("occupied", true)
	
	# Esconder outline
	if outline_mesh:
		var tween = create_tween()
		tween.tween_property(outline_mesh, "modulate:a", 0.0, 0.3)
		await tween.finished
		outline_mesh.visible = false
	
	part_placed.emit(part_type)
	print("Peça %s colocada no ponto de encaixe!" % part_type)


func show_highlight():
	"""Destaca o ponto quando uma peça compatível está próxima"""
	if outline_mesh and not is_occupied:
		outline_mesh.modulate = Color(0.5, 1.0, 0.5, 0.6)  # Verde brilhante


func hide_highlight():
	"""Remove destaque"""
	if outline_mesh and not is_occupied:
		outline_mesh.modulate = outline_color
