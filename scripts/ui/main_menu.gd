extends Control

signal start_game

@onready var start_button: Button = $StartButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed() -> void:
	start_game.emit()
	print("[MainMenu] Jogo iniciado!")
