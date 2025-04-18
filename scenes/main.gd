extends Control
class_name DesktopEnvironment

@export var infection_increase_threshold: float = 1.0
@export var popups: Array[PackedScene]

@export var file_explorer_scene: PackedScene
@export var software_store_scene: PackedScene
@export var infection_meter: ProgressBar

@onready var spawn_area: ReferenceRect = $SpawnArea
@onready var virus_popups: Control = $VirusPopups
@onready var autoclose_delay: Timer = $AutocloseDelay
@onready var score_label: Label = $ScoreLabel

var window_instance: Window

func _ready() -> void:
	Events.virus_deleted.connect(_on_virus_deleted)
	Events.autoclose_wait_time_changed.connect(_on_autoclose_wait_time_updated)

func _process(delta: float) -> void:
	get_score()
	Global.score = clampi(Global.score, 0, Global.score)
	score_label.text = "Score: %d pts" % Global.score
	if Global.can_virus_popup:
		infection_meter.value += infection_increase_threshold * delta
	infection_increase_threshold = 2.0 if virus_popups.get_child_count() >= 10 else 1.0
	
func create_new_window() -> void:
	if not Global.antivirus_activated and Global.can_virus_popup:
		window_instance = popups.pick_random().instantiate()

		window_instance.desktop_env = self
		window_instance.size = Vector2.ZERO
		var random_position_x = randf_range(spawn_area.pivot_offset.x, spawn_area.size.x)
		var random_position_y = randf_range(spawn_area.pivot_offset.y, spawn_area.size.y)
		var tween = create_tween()
		tween.tween_property(window_instance, "size", Vector2i(400, 150), 0.1)
		window_instance.position = Vector2(random_position_x, random_position_y)
		virus_popups.add_child(window_instance)

func close_all_popups() -> void:
	if virus_popups.get_child_count() > 0:
		for popup in virus_popups.get_children():
			popup.close_window()

# ---------- SIGNAL CALLBACKS ---------- #

func _on_virus_deleted() -> void:
	print("VIRUS Has been Deleted!")
	Global.can_virus_popup = false
	while !virus_popups.get_child_count() == 0:
		virus_popups.get_child(0).close_window()
		await get_tree().create_timer(0.1).timeout
	# TODO: Show Win Screen

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
