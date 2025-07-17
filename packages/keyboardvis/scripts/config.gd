class_name Config extends Node


static func read_optional(dict: Dictionary, key: String, default):
	return dict[key] if key in dict else default


class ConfigEntry:
	var key: String
	var hotkey: KeyNode.HotKey
	var ok: bool = false

	func _init(data: Dictionary):
		if "key" in data:
			key = data["key"]
		else:
			print("key is required")
			return

		var icon
		if "icon" in data and data["icon"] != null:
			var path = data["icon"]
			var image = Image.load_from_file(path)
			icon = ImageTexture.create_from_image(image)
		var modifiers = Data.bool_to_modifiers(
			Config.read_optional(data, "shift", false),
			Config.read_optional(data, "alt", false),
			Config.read_optional(data, "ctrl", false),
		)

		hotkey = KeyNode.HotKey.new()
		hotkey.modifiers = modifiers
		hotkey.icon = icon
		hotkey.description = Config.read_optional(data, "description", "")

		ok = true


func get_config_path():
	var cli = OS.get_cmdline_user_args()
	return cli[0] if cli.size() > 0 else "example.json"


func load_json(file: String):
	var f = FileAccess.open(file, FileAccess.READ)
	if f == null:
		print("Could not open config file", file)
		return null
	var data = JSON.parse_string(f.get_as_text())

	var result = {}

	for entry in data:
		var parse = ConfigEntry.new(entry)
		if not parse.ok:
			print("Failed to read entry", entry)
			continue

		if parse.key not in result:
			result[parse.key] = []
		result[parse.key].append(parse.hotkey)

	return result
