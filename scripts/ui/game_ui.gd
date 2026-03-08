extends Control
class_name GameUI

## Interface do usuário do jogo

@onready var state_label: Label = $StateLabel
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var action_button: Button = $ActionButton
@onready var fuel_bar: ProgressBar = $FuelBar
@onready var condition_bar: ProgressBar = $ConditionBar

signal button_pressed(action: String)

var current_action: String = "wash"

func _ready() -> void:
	action_button.pressed.connect(_on_button_pressed)
	update_ui("Montar", 0.0)

func _on_button_pressed() -> void:
	button_pressed.emit(current_action)
	print("[UI] Botão pressionado: ", current_action)

func update_state(state_text: String) -> void:
	if state_label:
		state_label.text = state_text

func update_progress(value: float) -> void:
	if progress_bar:
		progress_bar.value = value * 100.0

func update_fuel(value: float) -> void:
	if fuel_bar:
		fuel_bar.value = value

func update_condition(value: float) -> void:
	if condition_bar:
		condition_bar.value = value

func set_action_button(action: String) -> void:
	current_action = action
	match action:
		"wash":
			action_button.text = "Lavar"
		"drive":
			action_button.text = "Dirigir"
		"refuel":
			action_button.text = "Abastecer"
		"repair":
			action_button.text = "Reparar"
		"reset":
			action_button.text = "Reiniciar"

func show_fuel_bar(show: bool) -> void:
	if fuel_bar:
		fuel_bar.visible = show

func show_condition_bar(show: bool) -> void:
	if condition_bar:
		condition_bar.visible = show

func update_ui(state_text: String, progress: float) -> void:
	update_state(state_text)
	update_progress(progress)
