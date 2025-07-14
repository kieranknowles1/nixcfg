class_name Keyboard extends Node



const KEY = preload("res://prefabs/key.tscn")

# TODO: Rest of the keyboard
const LAYOUT = "qwertyuiop"

var keys: Array[Key] = []

func _ready():

	for key in LAYOUT.split(""):
		var code = OS.find_keycode_from_string(key)
		var instance: Key = KEY.instantiate()

		instance.data = Key.KeyData.new()
		instance.data.code = code
		instance.data.lower = key
		instance.data.upper = key.to_upper()
		add_child(instance)

		keys.append(instance)

func _input(_event: InputEvent) -> void:
	var mod = Data.get_modifiers()
	for key in keys:
		key.set_modifiers(mod)
