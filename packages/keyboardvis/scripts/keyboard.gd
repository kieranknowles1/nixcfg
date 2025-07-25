class_name Keyboard extends Node

@onready var config: Config = $"../Config"

const KEY = preload("res://prefabs/key.tscn")

const LOWER: Array[String] = ["1234567890-=", "qwertyuiop[]", "asdfghjkl;'#", "\\zxcvbnm,./"]
const UPPER: Array[String] = ['!"£$%^&*()_+', "QWERTYUIOP{}", "ASDFGHJKL:@~", "|ZXCVBNM<>?"]

# Keys that have different names to their label
const ALTERNATE_NAMES: Dictionary = {"/": "slash"}

const PADDING = [0, 10, 32, 0]

@export var keys: Array[KeyNode] = []


func new_row(pad: int = 0):
	var row = HBoxContainer.new()
	if pad > 0:
		var padding = Control.new()
		padding.custom_minimum_size.x = pad
		row.add_child(padding)

	add_child(row)
	return row


func _ready():
	# Load all modifiers
	var cfg = config.load_json(config.get_config_path())
	if cfg == null:
		get_tree().quit(1)

	for i in range(0, LOWER.size()):
		var lower = LOWER[i]
		var upper = UPPER[i]

		var row = new_row(PADDING[i])
		for key in range(0, lower.length()):
			var instance: KeyNode = KEY.instantiate()
			instance.data = KeyData.new()
			instance.data.lower = lower.substr(key, 1)
			instance.data.upper = upper.substr(key, 1)
			instance.data.code = OS.find_keycode_from_string(instance.data.lower)

			row.add_child(instance)
			keys.append(instance)

	# Include pre-set keys
	for instance in keys:
		var code = (
			ALTERNATE_NAMES[instance.data.lower]
			if instance.data.lower in ALTERNATE_NAMES
			else instance.data.lower
		)
		if code in cfg:
			instance.hotkeys = cfg[code]


func _input(_event: InputEvent) -> void:
	var mod = Data.get_modifiers()
	for key in keys:
		key.set_modifiers(mod)

	# Quit is slow, so use excessive force. Let the OS clean up for us
	if Input.is_action_pressed("Quit"):
		OS.kill(OS.get_process_id())
