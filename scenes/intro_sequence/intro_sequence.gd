extends Control

@export var main_scene: PackedScene
@onready var search_text: Label = $SearchText
@onready var key_sfx: AudioStreamPlayer = $KeySfx

var last_visible_characters: int = 0

func _process(delta: float) -> void:
	var current_visible = search_text.visible_characters
	if current_visible > last_visible_characters:
		if !key_sfx.playing:
			key_sfx.play()
		last_visible_characters = current_visible

func switch_to_main_scene():
	get_tree().change_scene_to_packed(main_scene)
