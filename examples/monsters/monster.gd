extends SubsystemResource
class_name Monster

@export var monster_name : String = ""
@export var monster_description : String = ""
@export var power_level : int = 5
@export var elements : String
@export var rarity : String

func _init() -> void:
	required_keys = ["monster_name", "monster_description", "power_level", "elements", "rarity"]
