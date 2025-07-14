class_name Keyboard extends Node

const KEY = preload("res://prefabs/key.tscn")

# TODO: Rest of the keyboard
const LAYOUT = "qwertyuiop|asdfghjkl|zxcvbnm"
const PAD_PER_ROW = 32

var keys: Array[Key] = []

func new_row(pad: int = 0):
	var row = HBoxContainer.new()
	if pad > 0:
		var padding = Control.new()
		padding.custom_minimum_size.x = pad
		row.add_child(padding)

	add_child(row)
	return row

func _ready():
	var padding = 0
	var row = new_row(padding)
	for key in LAYOUT.split(""):
		if key == '|':
			padding += PAD_PER_ROW
			row = new_row(padding)
			continue

		var code = OS.find_keycode_from_string(key)
		var instance: Key = KEY.instantiate()

		instance.data = Key.KeyData.new()
		instance.data.code = code
		instance.data.lower = key
		instance.data.upper = key.to_upper()
		row.add_child(instance)

		keys.append(instance)

func _input(_event: InputEvent) -> void:
	var mod = Data.get_modifiers()
	for key in keys:
		key.set_modifiers(mod)
	
	# Quit is slow, so use excessive force. Let the OS clean up for us
	if Input.is_action_pressed("Quit"):
		OS.kill(OS.get_process_id())
