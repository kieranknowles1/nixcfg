class_name Keyboard extends Node

const KEY = preload("res://prefabs/key.tscn")

const LOWER: Array[String] = ["1234567890-=", "qwertyuiop[]", "asdfghjkl;'#", "\\zxcvbnm,./"]
const UPPER: Array[String] = ['!"£$%^&*()_+', "QWERTYUIOP{}", "ASDFGHJKL:@~", "|ZXCVBNM<>?"]

# TODO: Rest of the keyboard
#const LOWER = "qwertyuiop[] asdfghjkl;'# \\zxcvbnm<>/"
#const UPPER = "QWERTYUIOP{} ASDFGHJKL:@~ qwertyuiop[]|asdfghjkl;'#|\\zxcvbnm<>/"
const PADDING = [0, 10, 42, 0]

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
	for i in range(0, LOWER.size()):
		var lower = LOWER[i]
		var upper = UPPER[i]
		
		var row = new_row(PADDING[i])
		for key in range(0, lower.length()):
			#var code = OS.find_keycode_from_string(key)
			var instance: Key = KEY.instantiate()
			instance.data = Key.KeyData.new()
			instance.data.lower = lower.substr(key, 1)
			instance.data.upper = upper.substr(key, 1)
			instance.data.code = OS.find_keycode_from_string(instance.data.lower)
			row.add_child(instance)
	#
			keys.append(instance)
	#var index = 0
	#var row = new_row(PADDING[0])
	#index += 1
	#for key in LAYOUT.split(""):
		#if key == '|':
			#row = new_row(PADDING[index])
			#index += 1
			#continue
#
		#var code = OS.find_keycode_from_string(key)
		#var instance: Key = KEY.instantiate()
#
		#instance.data = Key.KeyData.new()
		#instance.data.code = code
		#instance.data.lower = key
		#instance.data.upper = key.to_upper()
		#row.add_child(instance)
#
		#keys.append(instance)

func _input(_event: InputEvent) -> void:
	var mod = Data.get_modifiers()
	for key in keys:
		key.set_modifiers(mod)
	
	# Quit is slow, so use excessive force. Let the OS clean up for us
	if Input.is_action_pressed("Quit"):
		OS.kill(OS.get_process_id())
