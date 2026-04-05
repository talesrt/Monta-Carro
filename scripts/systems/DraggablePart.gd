extends Area3D
class_name DraggablePart

## Peça arrastável que encaixa nos sockets do modelo GLB

signal part_snapped(part_name: String)
signal part_picked_up(part_name: String)
signal part_dropped(part_name: String, success: bool)

@export var part_name: String = "part"
@export var snap_distance: float = 1.0
@export var return_on_fail: bool = true

var is_dragging: bool = false
var is_snapped: bool = false
var camera: Camera3D
var drag_offset: Vector3 = Vector3.ZERO
var original_position: Vector3

var _highlight_mat: StandardMaterial3D
var _original_mat: Material

func _ready() -> void:
	original_position = global_position
	camera = get_viewport().get_camera_3d()
	_setup_highlight()
	input_ray_pickable = true

	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	add_to_group("draggable_parts")
	print("[Part] %s pronto" % part_name)

func _setup_highlight() -> void:
	_highlight_mat = StandardMaterial3D.new()
	_highlight_mat.albedo_color = Color(0.5, 1.0, 0.5, 1.0)
	_highlight_mat.emission_enabled = true
	_highlight_mat.emission = Color(0.3, 0.8, 0.3)
	_highlight_mat.emission_energy_multiplier = 0.5

func _on_input_event(_camera: Node, event: InputEvent, _pos: Vector3, _normal: Vector3, _shape: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not is_snapped:
				start_dragging()
			elif not event.pressed and is_dragging:
				stop_dragging()

func _on_mouse_entered() -> void:
	if not is_dragging and not is_snapped:
		_apply_highlight(true)

func _on_mouse_exited() -> void:
	if not is_dragging:
		_apply_highlight(false)

func start_dragging() -> void:
	is_dragging = true
	part_picked_up.emit(part_name)
	_apply_highlight(true)
	_scale_part(1.2)
	print("[Part] Arrastando: %s" % part_name)

func stop_dragging() -> void:
	is_dragging = false
	_apply_highlight(false)
	_scale_part(1.0)

	var nearest := _find_nearest_snap()
	if nearest and global_position.distance_to(nearest.global_position) < snap_distance:
		_snap_to(nearest)
		part_snapped.emit(part_name)
		part_dropped.emit(part_name, true)
		print("[Part] %s ENCAIXADA!" % part_name)
	else:
		if return_on_fail:
			_return_to_start()
		part_dropped.emit(part_name, false)
		print("[Part] %s não encaixou" % part_name)

func _process(_delta: float) -> void:
	if is_dragging and camera:
		var mouse_pos := get_viewport().get_mouse_position()
		var from := camera.project_ray_origin(mouse_pos)
		var dir := camera.project_ray_normal(mouse_pos)
		var distance := camera.global_position.distance_to(original_position)
		var target := from + dir * distance
		global_position = global_position.lerp(target + drag_offset, 0.3)
		_check_proximity()

func _find_nearest_snap() -> Area3D:
	var snaps := get_tree().get_nodes_in_group("snap_points")
	var nearest: Area3D = null
	var best_dist := snap_distance

	for snap in snaps:
		if not (snap is Area3D):
			continue
		var snap_type = snap.get_meta("part_type") if snap.has_meta("part_type") else ""
		var snap_occupied = snap.get_meta("occupied") if snap.has_meta("occupied") else false
		if snap_occupied:
			continue
		var dist := global_position.distance_to(snap.global_position)
		if dist < best_dist:
			best_dist = dist
			nearest = snap

	return nearest

func _check_proximity() -> void:
	var mesh := get_node_or_null("MeshInstance3D")
	if not mesh:
		return
	var snap := _find_nearest_snap()
	if snap:
		mesh.modulate = Color(0.5, 1.0, 0.5)
	else:
		mesh.modulate = Color.WHITE

func _snap_to(snap: Area3D) -> void:
	is_snapped = true
	input_ray_pickable = false

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", snap.global_position, 0.3)
	tween.tween_property(self, "rotation", snap.rotation, 0.3)

	snap.set_meta("occupied", true)
	snap.is_occupied = true

	var mesh := get_node_or_null("MeshInstance3D")
	if mesh:
		mesh.modulate = Color(0.5, 1.0, 0.5)

func _return_to_start() -> void:
	var tween := create_tween()
	tween.tween_property(self, "global_position", original_position, 0.5)

func _apply_highlight(enable: bool) -> void:
	var mesh := get_node_or_null("MeshInstance3D")
	if not mesh:
		return
	if enable:
		var cur := mesh.get_surface_override_material(0)
		if cur and not (cur is StandardMaterial3D):
			_original_mat = cur
		mesh.set_surface_override_material(0, _highlight_mat)
	else:
		if _original_mat:
			mesh.set_surface_override_material(0, _original_mat)
		else:
			mesh.set_surface_override_material(0, null)

func _scale_part(target: float) -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3.ONE * target, 0.2)

func reset() -> void:
	global_position = original_position
	is_snapped = false
	is_dragging = false
	input_ray_pickable = true
	var mesh := get_node_or_null("MeshInstance3D")
	if mesh:
		mesh.modulate = Color.WHITE
	_scale_part(1.0)

func set_placed(placed: bool) -> void:
	is_snapped = placed
