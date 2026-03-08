extends Node3D
class_name CarAssemblyManager

## Gerenciador principal do jogo de montagem do carro
## Coloque este script no node principal da cena

# Configurações
@export var required_parts: Array[String] = ["Roda_FL", "Roda_FR", "Roda_BL", "Roda_BR", "Porta", "Capô"]
@export var show_celebration: bool = true
@export var auto_next_level: bool = false

# Estado do jogo
var parts_placed: Dictionary = {}
var total_parts: int = 0
var placed_count: int = 0

# UI (opcional - você pode criar sua própria UI)
@onready var progress_label: Label = $UI/ProgressLabel if has_node("UI/ProgressLabel") else null
@onready var celebration_panel: Control = $UI/CelebrationPanel if has_node("UI/CelebrationPanel") else null

# Sinais
signal part_placed(part_name, current_count, total_count)
signal game_completed()
signal progress_updated(percentage)


func _ready():
	# Inicializar contadores
	total_parts = required_parts.size()
	
	for part in required_parts:
		parts_placed[part] = false
	
	# Conectar sinais de todas as peças arrastavéis
	connect_draggable_parts()
	
	# Conectar sinais de pontos de encaixe
	connect_snap_points()
	
	# Atualizar UI inicial
	update_ui()
	
	print("Jogo iniciado! Peças necessárias: %d" % total_parts)


func connect_draggable_parts():
	"""Conecta sinais de todas as peças arrastáveis"""
	var parts = get_tree().get_nodes_in_group("draggable_parts")
	
	for part in parts:
		if part is DraggablePart:
			part.part_snapped.connect(_on_part_snapped)
			part.part_picked_up.connect(_on_part_picked_up)
			part.part_dropped.connect(_on_part_dropped)


func connect_snap_points():
	"""Conecta sinais de todos os pontos de encaixe"""
	var points = get_tree().get_nodes_in_group("snap_points")
	
	for point in points:
		if point is SnapPoint:
			point.part_placed.connect(_on_snap_point_filled)


func _on_part_picked_up(part_name: String):
	"""Chamado quando uma peça é pega"""
	print("Peça pega: %s" % part_name)
	# Poderia adicionar som de "pegar"
	play_sound("pick_up")


func _on_part_dropped(part_name: String, success: bool):
	"""Chamado quando uma peça é solta"""
	if success:
		print("Peça %s encaixada com sucesso!" % part_name)
		play_sound("snap_success")
	else:
		print("Peça %s não encaixou" % part_name)
		play_sound("snap_fail")


func _on_part_snapped(part_name: String):
	"""Chamado quando uma peça é encaixada corretamente"""
	if not parts_placed.has(part_name):
		return
	
	if not parts_placed[part_name]:
		parts_placed[part_name] = true
		placed_count += 1
		
		# Emitir sinal de progresso
		part_placed.emit(part_name, placed_count, total_parts)
		
		var percentage = (float(placed_count) / float(total_parts)) * 100.0
		progress_updated.emit(percentage)
		
		print("Progresso: %d/%d (%.1f%%)" % [placed_count, total_parts, percentage])
		
		# Atualizar UI
		update_ui()
		
		# Verificar se completou
		check_completion()


func _on_snap_point_filled(part_type: String):
	"""Chamado quando um ponto de encaixe é preenchido"""
	print("Ponto de encaixe preenchido: %s" % part_type)


func check_completion():
	"""Verifica se todas as peças foram colocadas"""
	if placed_count >= total_parts:
		complete_game()


func complete_game():
	"""Chamado quando o jogador completa o jogo"""
	print("🎉 JOGO COMPLETO! PARABÉNS! 🎉")
	game_completed.emit()
	
	# Mostrar celebração
	if show_celebration:
		show_celebration_screen()
	
	# Som de vitória
	play_sound("victory")
	
	# Próximo nível (se configurado)
	if auto_next_level:
		await get_tree().create_timer(3.0).timeout
		next_level()


func show_celebration_screen():
	"""Mostra tela de comemoração"""
	if celebration_panel:
		celebration_panel.visible = true
		
		# Animar
		var tween = create_tween()
		tween.tween_property(celebration_panel, "modulate:a", 1.0, 0.5)
	else:
		# Criar uma tela simples se não existir
		print("🎊 PARABÉNS! VOCÊ MONTOU O CARRO! 🎊")


func update_ui():
	"""Atualiza a interface do usuário"""
	if progress_label:
		var percentage = (float(placed_count) / float(total_parts)) * 100.0
		progress_label.text = "Progresso: %d/%d (%.0f%%)" % [placed_count, total_parts, percentage]


func reset_game():
	"""Reinicia o jogo"""
	# Resetar contadores
	placed_count = 0
	for part in parts_placed.keys():
		parts_placed[part] = false
	
	# Resetar peças
	var parts = get_tree().get_nodes_in_group("draggable_parts")
	for part in parts:
		if part is DraggablePart:
			part.is_snapped = false
			part.input_ray_pickable = true
			part.global_position = part.original_position
			part.modulate = Color.WHITE
	
	# Resetar pontos de encaixe
	var points = get_tree().get_nodes_in_group("snap_points")
	for point in points:
		if point is SnapPoint:
			point.is_occupied = false
			point.set_meta("occupied", false)
			if point.outline_mesh:
				point.outline_mesh.visible = true
				point.outline_mesh.modulate = point.outline_color
	
	# Atualizar UI
	update_ui()
	
	print("Jogo reiniciado!")


func next_level():
	"""Carrega próximo nível (você precisa implementar)"""
	print("Carregando próximo nível...")
	# get_tree().change_scene_to_file("res://scenes/level_2.tscn")


func play_sound(sound_name: String):
	"""Toca efeito sonoro (você precisa adicionar os AudioStreamPlayers)"""
	var sound_player = get_node_or_null("Sounds/" + sound_name)
	if sound_player and sound_player is AudioStreamPlayer:
		sound_player.play()


func get_progress_percentage() -> float:
	"""Retorna o progresso atual em porcentagem"""
	return (float(placed_count) / float(total_parts)) * 100.0


func get_remaining_parts() -> Array[String]:
	"""Retorna lista de peças que ainda faltam colocar"""
	var remaining: Array[String] = []
	for part in parts_placed.keys():
		if not parts_placed[part]:
			remaining.append(part)
	return remaining
