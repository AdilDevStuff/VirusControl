extends PanelContainer

@export var dialogs: Array[String]

@onready var dialog_anim: AnimationPlayer = $DialogAnim
@onready var rich_text_label: RichTextLabel = $MarginContainer/VBoxContainer/RichTextLabel
@onready var dialog_sfx: AudioStreamPlayer = $"../DialogSfx"

var current_dialog_idx: int
var last_visible_characters: int = 0

func _ready() -> void:
	dialog_anim.play("Start")
	next_dialog()

func _process(delta: float) -> void:
	var current_visible = rich_text_label.visible_characters
	if current_visible > last_visible_characters:
		if !dialog_sfx.playing:
			dialog_sfx.play()
		last_visible_characters = current_visible

func next_dialog() -> void:
	if current_dialog_idx < dialogs.size():
		rich_text_label.text = dialogs[current_dialog_idx]
		dialog_anim.play("Start")
		last_visible_characters = 0

func _on_next_btn_pressed() -> void:
	current_dialog_idx += 1
	next_dialog()
	if current_dialog_idx >= dialogs.size():
		Events.dialog_finished.emit()
		self.get_parent().queue_free()
