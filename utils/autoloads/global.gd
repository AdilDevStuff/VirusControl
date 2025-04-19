extends Node

var score: int = 0

var can_virus_popup: bool = true

var antivirus_activated: bool = false
var antivirus_toggled: bool = false

var autoclose_ability_activated: bool = false

var virus_deleted: bool = false

var autoclose_timer_wait_time: float = 5.0

func increase_score(amount: int) -> void:
	score += amount
