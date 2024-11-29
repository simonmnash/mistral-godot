extends HTTPRequest
class_name LLMSubSystem

signal new_resources(object : Array[SubsystemResource])
var system_prompt_suffix : String

@export var resource_template : SubsystemResource
# Mistral offers a lot of models - some open - some closed.
# I like ministral-3b-latest because it is open, and a little incoherent.
@export var model_name : String
# Drop as much world lore as you'd like in this prompt. Ramble and introduce concepts, characters,
# and ideas that you'd like to sample from. The more you add to the world lore the less boring
# the model output will be.
@export var lore_prompt : String 
# What do you want this system to generate? Be very specific about the type of input you will provide,
# and the resources you want in your output json.
@export var system_prompt_prefix : String
# Make a few examples of very specific things thaat this subsystem could generate given certain inputs.
# For getting a specific tone - write in that tone in these examples instead of instructing the model
# to use a specific tone.
@export var few_shot_examples : Array[SubsystemResource]

# Generate more options than we need.
@export var n_to_generate : int = 10

@export var temp : float = 1.0

@export var filter_key : String
@export var dedupe_key : String

var system_prompt : String = "Please return the response as JSON including the following keys: "
var api_key : String

func _ready() -> void:
	var few_shot_string = ""
	var ex
	for f in few_shot_examples:
		few_shot_string += JSON.stringify(f.to_json())
		few_shot_string += "/n"
		ex = f
	system_prompt_suffix = system_prompt_suffix + ", ".join(ex.required_keys)
	system_prompt = system_prompt_prefix + few_shot_string + system_prompt_suffix
	print(system_prompt)

func invoke(input, n_generations: int = 5):
	self.api_call(JSON.stringify(input), n_generations)

func api_call(prompt: String, n_generations: int):
	var body = {
		"model": model_name,
		"temperature": temp,
		"messages": [
			{ 
				"role": "system",
				"content": lore_prompt
			},
			{
				"role": "system",
				"content": system_prompt
			},
			{
				"role": "user",
				"content": prompt
			}
		],
		"response_format": {
			"type": "json_object"
		},
		"n": self.n_to_generate
	}
	
	var headers = [
		"Content-Type: application/json",
		"Accept: application/json",
		"Authorization: Bearer " + GlobalData.api_key
	]

	var res = request(
		"https://api.mistral.ai/v1/chat/completions",
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(body)
	)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		var valid_choices : Array[Dictionary] = []
		for c in json['choices']:
			var new_r : SubsystemResource = resource_template.duplicate()
			var m : String = c["message"]["content"]
			var m_as_json = JSON.parse_string(m)
			if m_as_json != null:
				if m_as_json is Dictionary:
					if new_r.valid_json(m_as_json):
						valid_choices.append(m_as_json)
		sort_and_return_reslts(valid_choices)

func sort_and_return_reslts(valid_options : Array[Dictionary]) -> void:
	# TODO add some dynamic ways to sort and filter resources.
	# For now just return all of the valid generated resources
	# deduplicated by primary name
	var resources_to_return : Array[SubsystemResource] = []
	var keys : Array[String]
	for o : Dictionary in valid_options:
		var new_r : SubsystemResource = resource_template.duplicate()
		new_r.set_from_json(o)
		if len(dedupe_key) > 0:
			if new_r.get(dedupe_key) in keys:
				pass
			else:
				keys.append(new_r.get(dedupe_key))
				resources_to_return.append(new_r)
		else:
			resources_to_return.append(new_r)
	emit_signal("new_resources", resources_to_return)
