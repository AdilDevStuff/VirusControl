extends Control

@export var death_messages: Array[String]
@onready var death_screen_sfx: AudioStreamPlayer = $DeathScreenSFx
@onready var error_message: Label = $PanelContainer/CenterContainer/HBoxContainer/VBoxContainer/ErrorMessage

func _ready() -> void:
	error_message.text = death_messages.pick_random()
	death_screen_sfx.play(0.6)

func _on_restart_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
