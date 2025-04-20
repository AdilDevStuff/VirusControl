extends Control
class_name DesktopEnvironment

@export var infection_increase_threshold: float = 1.0
@export var popups: Array[PackedScene]

@export var file_explorer_scene: PackedScene
@export var software_store_scene: PackedScene
@export var dialog_box_scene: PackedScene
@export var infection_meter: ProgressBar

@onready var spawn_area: ReferenceRect = $SpawnArea
@onready var virus_popups: Control = $VirusPopups
@onready var autoclose_delay: Timer = $AutocloseDelay
@onready var score_label: Label = $ScoreLabel

var window_instance: Window

func _ready() -> void:
	Global.score = 0
	Global.can_virus_popup = false
	
	if Global.dialog_played_once:
		Global.can_virus_popup = true
	
	Events.virus_deleted.connect(_on_virus_deleted)
	Events.dialog_finished.connect(_on_dialogs_finished)
	Events.autoclose_wait_time_changed.connect(_on_autoclose_wait_time_updated)
	create_intro_dialog_box()

func _process(delta: float) -> void:
	if OS.is_debug_build(): get_score()
	Global.score = clampi(Global.score, 0, Global.score)
	score_label.text = "Score: %d pts" % Global.score
	if Global.can_virus_popup:
		infection_meter.value += infection_increase_threshold * delta
	infection_increase_threshold = 2.0 if virus_popups.get_child_count() >= 10 else 1.0

func create_intro_dialog_box() -> void:
	if !Global.dialog_played_once:
		var dialog_box = dialog_box_scene.instantiate()
		add_child(dialog_box)

func create_new_window() -> void:
	if Global.can_virus_popup:
		window_instance = popups.pick_random().instantiate()

		window_instance.desktop_env = self
		window_instance.size = Vector2.ZERO
		
		var spawn_rect_global_pos = spawn_area.get_global_position()
		var spawn_rect_size = spawn_area.size
		var random_pos = spawn_rect_global_pos + Vector2(
			randf_range(0.0, spawn_rect_size.x),
			randf_range(0.0, spawn_rect_size.y)
		)
		var tween = create_tween()
		tween.tween_property(window_instance, "size", Vector2i(400, 150), 0.1)
		window_instance.position = random_pos
		virus_popups.add_child(window_instance)

func close_all_popups() -> void:
	if virus_popups.get_child_count() > 0:
		for popup in virus_popups.get_children():
			popup.close_window()

# ---------- SIGNAL CALLBACKS ---------- #

func _on_dialogs_finished() -> void:
	Global.can_virus_popup = true
	Global.dialog_played_once = true
	
	if !FileAccess.file_exists("user://save.txt"):
		var file = FileAccess.open("user://save.txt", FileAccess.WRITE)
		file.store_var(Global.dialog_played_once)

func _on_virus_deleted() -> void:
	Global.can_virus_popup = false
	infection_meter.hide()
	while !virus_popups.get_child_count() == 0:
		virus_popups.get_child(0).close_window()
		await get_tree().create_timer(0.1).timeout
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/WinScreen.tscn")

func _on_autoclose_wait_time_updated() -> void:
	autoclose_delay.wait_time = Global.autoclose_timer_wait_time

func _on_window_spawn_delay_timeout() -> void:
	create_new_window()

func _on_file_explorer_pressed() -> void:
	SoundManager.click_sfx.play()
	var file_explorer_instance: Window = file_explorer_scene.instantiate()
	file_explorer_instance.size = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(file_explorer_instance, "size", Vector2i(885, 425), 0.1)
	add_child(file_explorer_instance)

func _on_software_store_pressed() -> void:
	SoundManager.click_sfx.play()
	var software_store_instance: Window = software_store_scene.instantiate()
	software_store_instance.size = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(software_store_instance, "size", Vector2i(885, 425), 0.1)
	add_child(software_store_instance)

func _on_autoclose_delay_timeout() -> void:
	if Global.autoclose_ability_activated:
		if virus_popups.get_child_count() > 0:
			virus_popups.get_child(0).close_window()

func _on_infection_meter_value_changed(value: float) -> void:
	if value >= infection_meter.max_value:
		Events.system_infected.emit()
		get_tree().change_scene_to_file("res://scenes/rsod.tscn")

# ---------- DEBUG FUNCTIONS ---------- #
func get_score() -> void:
	if Input.is_action_just_pressed("ui_accept"):
		Global.increase_score(100)
