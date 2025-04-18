class_name UpgradeItem
extends Resource

@export_group("Item Properties", "item_")
@export var item_name: String
@export var item_cost: int
@export var item_cost_increase_rate: int
@export var item_btn: NodePath

@export_group("Item Callbacks", "item_")
@export var item_property: String
@export var item_method: String
@export var item_method_group: String
