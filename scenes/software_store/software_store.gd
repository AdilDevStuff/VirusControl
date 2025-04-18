extends Window

@export var upgrades: Array[UpgradeItem]

func _ready() -> void:
	for upgrade in upgrades:
		var btn_node = get_node(upgrade.item_btn)
		btn_node.text = upgrade.item_name + "\n(%d Pts)" % upgrade.item_cost

func buy_upgrade(idx: int):
	var upgrade = upgrades[idx]
	var btn_node = get_node(upgrade.item_btn)
	
	if Global.score >= upgrade.item_cost:
		Global.score -= upgrade.item_cost
		Global[upgrade.item_property] = true
		upgrade.item_cost += upgrade.item_cost_increase_rate
		btn_node.text = upgrade.item_name + "\n(%d Pts)" % upgrade.item_cost
		
		if idx == 0 and Global.autoclose_timer_wait_time >= 0.5:
			Global.autoclose_timer_wait_time -= 0.5
			Events.autoclose_wait_time_changed.emit()
	else:
		print_rich("[color=tomato]Not Enough Points![/color]")

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
