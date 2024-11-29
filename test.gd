extends Control

const monster_view : PackedScene = preload("res://examples/monsters/monster_view.tscn")

func _ready() -> void:
	pass

func _on_llm_subsystem_new_resources(object: Array[SubsystemResource]) -> void:
	for r in object:
		var m = monster_view.instantiate()
		$UnlimitedMonsters.add_child(m, true)
		m.monster_data = r



func _on_jam_connect_player_connected(pid: int, username: String) -> void:
	var vars : Array[String] = ["MISTRAL_API_KEY"]
	var res = await $JamConnect.server.callback_api.get_vars(vars)
	if res.errored:
		printerr(res.error_msg)
		return
	GlobalData.api_key = res.data["vars"]["MISTRAL_API_KEY"]
	$Loading.hide()
	$LLMSubsystem.invoke({"location": "Western Route 11", "rarity": "common", "peril": "low"})
