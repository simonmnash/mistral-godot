extends Resource
class_name SubsystemResource

var required_keys : Array[String]

func to_json() -> Dictionary:
	var j : Dictionary = {}
	var script_properties : Array[Dictionary] = self.get_property_list()
	for k : Dictionary in script_properties:
		if k.name in required_keys:
			j[k.name] = self.get(k.name)
	return j

func set_from_json(input_json : Dictionary) -> void:
	if valid_json(input_json):
		for k : String in required_keys:
			if input_json.get(k) != null:
				self.set(k, input_json.get(k))

func valid_json(input_json : Dictionary) -> bool:
	for k : String in required_keys:
		if input_json.get(k) == null:
			return false
	return true
