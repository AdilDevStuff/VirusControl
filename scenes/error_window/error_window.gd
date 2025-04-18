extends Window
class_name ErrorWindow

var desktop_env : DesktopEnvironment 
@export var error_messages: Array[String]
@onready var label: Label = $PanelContainer/CenterContainer/Label

func _ready() -> void:
	label.text = error_messages.pick_random()

func close_window() -> void:
	Global.increase_score(5)
	var tween = create_tween()
	tween.tween_property(self, "size", Vector2i.ZERO, 0.1)
	await tween.finished
	self.queue_free()

func _on_close_requested() -> void:
	SoundManager.click_sfx.play()
	close_window()

func _on_fix_button_pressed() -> void:
	if desktop_env:
		var rand_no : int = randi_range(0,2)
		
		for i in rand_no:
			desktop_env.create_new_window()
			
	var tween = create_tween()
	tween.tween_property(self, "size", Vector2i.ZERO, 0.1)
	await tween.finished
	self.queue_free()
