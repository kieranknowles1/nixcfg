class_name Key extends Panel

class KeyData:
	var code: int
	var lower: String
	var upper: String

var data: KeyData

@onready var label: Label = $Label

func _ready():
	label.text = data.lower

func set_modifiers(modifiers: Data.ModCombo):
	# TODO: Icon for shortcuts

	label.text = data.upper if modifiers & Data.ModCombo.Shift else data.lower

	pass
