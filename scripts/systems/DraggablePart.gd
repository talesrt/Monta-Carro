extends Area3D
# Script para peças do carro que podem ser arrastadas
# Removi "class_name" para evitar conflitos

## Use este script nas peças que a criança vai arrastar

# Configurações
@export var part_name: String = "Roda"  ## Nome da peça (Roda, Porta, Capô, etc)
@export var snap_distance: float = 0.5  ## Distância para encaixar automaticamente
@export var return_to_start: bool = true  ## Se volta ao lugar inicial quando soltar errado

# Estados
var is_dragging: bool = false
var is_snapped: bool = false
var camera: Camera3D
var drag_offset: Vector3 = Vector3.ZERO
var original_position: Vector3
var target_snap_position: Area3D = null

# Referências visuais
var original_material: Material
var highlight_material: StandardMaterial3D

# Sinais para comunicação
signal part_picked_up(part_name)
signal part_dropped(part_name, success)
signal part_snapped(part_name)


func _ready():
	# Salvar posição inicial
	original_position = global_position
	
	# Obter câmera principal
	camera = get_viewport().get_camera_3d()
	
	# Configurar material de destaque
	setup_highlight_material()
	
	# Configurar colisão para detecção de toque
	input_ray_pickable = true
	
	# Conectar sinais de input
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	print("Peça %s pronta para arrastar!" % part_name)


func setup_highlight_material():
	"""Criar material de destaque quando a peça está sendo arrastada"""
	highlight_material = StandardMaterial3D.new()
	highlight_material.albedo_color = Color(0.5, 1.0, 0.5, 1.0)  # Verde claro
	highlight_material.emission_enabled = true
	highlight_material.emission = Color(0.3, 0.8, 0.3)
	highlight_material.emission_energy_multiplier = 0.5


func _on_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int):
	"""Detecta quando a peça é tocada (funciona para touch e mouse)"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not is_snapped:
				start_dragging()
			elif not event.pressed and is_dragging:
				stop_dragging()


func _on_mouse_entered():
	"""Feedback visual quando o dedo/mouse está sobre a peça"""
	if not is_dragging and not is_snapped:
		apply_highlight(true)


func _on_mouse_exited():
	"""Remove feedback visual"""
	if not is_dragging:
		apply_highlight(false)


func start_dragging():
	"""Inicia o arrasto da peça"""
	is_dragging = true
	
	# Calcular offset do toque
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 100
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result:
		drag_offset = global_position - result.position
	
	# Feedback visual
	apply_highlight(true)
	scale_part(1.2)  # Aumenta um pouco para feedback
	
	# Emitir sinal
	part_picked_up.emit(part_name)
	print("Arrastando: %s" % part_name)


func stop_dragging():
	"""Para de arrastar e tenta encaixar"""
	is_dragging = false
	
	# Verificar se está próximo de algum ponto de encaixe
	var snap_point = find_nearest_snap_point()
	
	if snap_point and global_position.distance_to(snap_point.global_position) < snap_distance:
		# Encaixar!
		snap_to_position(snap_point)
		part_snapped.emit(part_name)
		part_dropped.emit(part_name, true)
		print("Peça %s ENCAIXADA!" % part_name)
	else:
		# Soltar sem encaixar
		if return_to_start:
			return_to_original_position()
		part_dropped.emit(part_name, false)
		print("Peça %s solta (não encaixou)" % part_name)
	
	# Remover feedback visual
	apply_highlight(false)
	scale_part(1.0)


func _process(_delta):
	"""Atualizar posição enquanto arrasta"""
	if is_dragging and camera:
		update_drag_position()


func update_drag_position():
	"""Atualiza a posição da peça seguindo o toque/mouse"""
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var normal = camera.project_ray_normal(mouse_pos)
	
	# Manter a peça a uma distância fixa da câmera
	var distance = camera.global_position.distance_to(original_position)
	var target_pos = from + normal * distance
	
	# Suavizar movimento
	global_position = global_position.lerp(target_pos + drag_offset, 0.3)
	
	# Verificar proximidade com pontos de encaixe para feedback visual
	check_snap_proximity()


func find_nearest_snap_point() -> Area3D:
	"""Encontra o ponto de encaixe mais próximo compatível"""
	var snap_points = get_tree().get_nodes_in_group("snap_points")
	var nearest: Area3D = null
	var nearest_distance = snap_distance
	
	for point in snap_points:
		if point is Area3D and point.has_meta("part_type"):
			# Verificar se aceita este tipo de peça
			if point.get_meta("part_type") == part_name:
				var distance = global_position.distance_to(point.global_position)
				if distance < nearest_distance:
					nearest = point
					nearest_distance = distance
	
	return nearest


func check_snap_proximity():
	"""Verifica se está próximo de um ponto de encaixe e dá feedback"""
	var snap_point = find_nearest_snap_point()
	
	if snap_point:
		var distance = global_position.distance_to(snap_point.global_position)
		if distance < snap_distance:
			# Feedback visual que pode encaixar
			if target_snap_position != snap_point:
				target_snap_position = snap_point
				# Poderia adicionar partículas, som, etc
				modulate = Color(0.5, 1.0, 0.5)  # Verde
		else:
			target_snap_position = null
			modulate = Color.WHITE
	else:
		target_snap_position = null
		modulate = Color.WHITE


func snap_to_position(snap_point: Area3D):
	"""Encaixa a peça no ponto de encaixe"""
	is_snapped = true
	
	# Animar até a posição
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", snap_point.global_position, 0.3)
	tween.tween_property(self, "rotation", snap_point.rotation, 0.3)
	
	# Desabilitar arrasto
	input_ray_pickable = false
	
	# Marcar ponto de encaixe como ocupado
	snap_point.set_meta("occupied", true)
	
	# Feedback visual de sucesso
	modulate = Color(0.5, 1.0, 0.5)


func return_to_original_position():
	"""Retorna a peça à posição inicial"""
	var tween = create_tween()
	tween.tween_property(self, "global_position", original_position, 0.5)


func apply_highlight(enable: bool):
	"""Aplica ou remove destaque visual"""
	var mesh_instance = get_node_or_null("MeshInstance3D")
	if mesh_instance:
		if enable:
			if original_material == null and mesh_instance.get_surface_override_material_count() > 0:
				original_material = mesh_instance.get_surface_override_material(0)
			mesh_instance.set_surface_override_material(0, highlight_material)
		else:
			if original_material:
				mesh_instance.set_surface_override_material(0, original_material)


func scale_part(target_scale: float):
	"""Anima o scale da peça"""
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ONE * target_scale, 0.2)
