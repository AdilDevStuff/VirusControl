extends Window

@export var upgrades: Array[UpgradeItem]

@onready var prompt: Label = $Prompt

func _ready() -> void:
	for upgrade in upgrades:
		var btn_node = get_node(upgrade.item_btn)
		btn_node.text = upgrade.item_name + "\n(%d Pts)" % upgrade.item_cost

func buy_upgrade(idx: int):
	var upgrade = upgrades[idx]
	var btn_node = get_node(upgrade.item_btn)
	
	if Global.score >= upgrade.item_cost:
		Global.score -= upgrade.item_cost
		prompt.text = "Bought %s" % upgrade.item_name
		$AnimationPlayer.play("ShowPrompt")
		if !upgrade.item_property.is_empty(): Global[upgrade.item_property] = true
		elif !upgrade.item_method.is_empty():
			get_tree().call_group(upgrade.item_method_group, upgrade.item_method)
			
		upgrade.item_cost += upgrade.item_cost_increase_rate
		btn_node.text = upgrade.item_name + "\n(%d Pts)" % upgrade.item_cost
		
		if idx == 0 and Global.autoclose_timer_wait_time >= 0.5:
			Global.autoclose_timer_wait_time -= 0.5
			Events.autoclose_wait_time_changed.emit()
	else:
		prompt.text = "Not Enough Points!"
		$AnimationPlayer.play("ShowPrompt")

# SIGNAL CALLBACKS
func _on_close_requested() -> void:
	SoundManager.click_sfx.play()
	var tween = create_tween()
	tween.tween_property(self, "size", Vector2i.ZERO, 0.1)
	await tween.finished
	self.queue_free()

func on_item_clicked(index: int) -> void:
	SoundManager.click_sfx.play()
	buy_upgrade(index)
