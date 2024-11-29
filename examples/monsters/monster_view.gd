extends MarginContainer
class_name MonsterView

@export var monster_data : Monster :
	set(v):
		monster_data = v
		%Description.text = monster_data.monster_description
		%Name.text = monster_data.monster_name
		%PowerLevel.text = str(monster_data.power_level)
		%Affinity.text = monster_data.elements
		if multiplayer.is_server():
			sync_to_client.rpc(monster_data.to_json())

@rpc("authority", "call_remote", "reliable")
func sync_to_client(as_json : Dictionary):
	var new_m = Monster.new()
	new_m.set_from_json(as_json)
	self.monster_data = new_m
	
