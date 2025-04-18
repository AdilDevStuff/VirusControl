extends Control

@export var win_messages: Array[String]
@onready var win_message: Label = $PanelContainer/CenterContainer/HBoxContainer/VBoxContainer/WinMessage

func _ready() -> void:
	win_message.text = win_messages.pick_random()

func _on_restart_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
