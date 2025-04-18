extends Window

@export var filesystem: FileSystem
@export var grid_container: GridContainer
@export var path_label: Label
@export var sidebar_container: VBoxContainer

@export var sidebar_btn: PackedScene
@export var folder_btn: PackedScene
@export var file_focused_style: StyleBoxFlat
@export var file_unfocused_style: StyleBoxEmpty
var selected_file : String

func _ready() -> void:
	update_ui()
	var shortcuts = filesystem.get_sidebar_shortcuts()

	for path in shortcuts:
		var button: Button = sidebar_btn.instantiate()
		button.text = path.back()
		button.flat = true
		button.tooltip_text = "/" + "/".join(path.slice(1, path.size()))  # Exclude "Drives"
		button.connect("pressed", func():
			filesystem.current_path = path.duplicate()
			update_ui()
		)
		sidebar_container.add_child(button)

func update_ui():
	var folder = filesystem.get_current_folder()
	clear_children(grid_container)
	
	path_label.text = "/" + "/".join(filesystem.current_path)
	
	for _name in folder.keys():
		var is_folder = typeof(folder[_name]) == TYPE_DICTIONARY
		var button: Button = folder_btn.instantiate()
		button.custom_minimum_size = Vector2(64, 64)
		button.text = _name
		if !is_folder:
			button.add_theme_stylebox_override("focus", file_focused_style)
			button.icon = preload("uid://brcm4rqn5h16v")
		else:
			button.add_theme_stylebox_override("focus", file_unfocused_style)
		button.pressed.connect(_on_item_selected.bind(_name))
		grid_container.add_child(button)

func clear_children(object):
	for child in object.get_children():
		child.queue_free()

func _on_close_requested() -> void:
	SoundManager.click_sfx.play()
	var tween = create_tween()
	tween.tween_property(self, "size", Vector2i.ZERO, 0.1)
	await tween.finished
	self.queue_free()

func _on_item_selected(_name) -> void:
	SoundManager.click_sfx.play()
	var folder = filesystem.get_current_folder()
	if typeof(folder[_name]) == TYPE_DICTIONARY:
		filesystem.current_path.append(_name)
		update_ui()
	else:
		selected_file = _name
		print("Selected file:", _name)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("delete_file"):
		filesystem.delete_file(selected_file, self)

func _on_back_button_pressed() -> void:
	SoundManager.click_sfx.play()
	filesystem.go_back(self)

func _on_delete_button_pressed() -> void:
	SoundManager.click_sfx.play()
	filesystem.delete_file(selected_file, self)
