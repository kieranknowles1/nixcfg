class_name Key extends Panel


class KeyData:
	var code: int
	var lower: String
	var upper: String


class HotKey:
	var modifiers: Data.ModCombo
	var description: String
	var icon: Texture2D


var data: KeyData
var hotkeys: Array

@onready var label: Label = $Label
@onready var texture_rect: TextureRect = $TextureRect
@onready var description: Label = $Description


func _ready():
	label.text = data.lower


func find_hotkey(modifiers: Data.ModCombo) -> HotKey:
	for hk in hotkeys:
		if hk.modifiers == modifiers:
			return hk
	return null


func set_modifiers(modifiers: Data.ModCombo):
	var hk = find_hotkey(modifiers)
	if hk:
		texture_rect.texture = hk.icon
		label.visible = false
		description.text = hk.description
		description.visible = true
		texture_rect.visible = true
	else:
		label.text = data.upper if modifiers & Data.ModCombo.Shift else data.lower
		label.visible = true
		description.visible = false
		texture_rect.visible = false
