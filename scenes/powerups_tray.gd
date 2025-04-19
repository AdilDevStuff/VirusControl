extends HBoxContainer

@onready var auto_closer_btn: TextureButton = $AutoCloserBtn
@onready var antivirus_toggle_btn: TextureButton = $AntivirusToggleBtn

func _ready() -> void:
	auto_closer_btn.visible = Global.autoclose_ability_activated
	antivirus_toggle_btn.visible = Global.antivirus_activated
	antivirus_toggle_btn.tooltip_text = "Antivirus is Disabled. Click to Toggle"

func _process(delta: float) -> void:
	auto_closer_btn.visible = Global.autoclose_ability_activated
	antivirus_toggle_btn.visible = Global.antivirus_activated

func _on_antivirus_toggle_btn_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Global.can_virus_popup = false
		antivirus_toggle_btn.modulate = Color.INDIAN_RED
		antivirus_toggle_btn.tooltip_text = "Antivirus is Enabled. Click to Toggle"
	else:
		Global.can_virus_popup = true
		antivirus_toggle_btn.modulate = Color.WHITE
		antivirus_toggle_btn.tooltip_text = "Antivirus is Disabled. Click to Toggle"
