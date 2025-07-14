class_name Data

# Bit mask that denotes a combination of modifiers
enum ModCombo {
	None = 0,
	Shift = 1,
	Alt = 2,
	Ctrl = 4,
	AltShift = Alt | Shift,
	CtrlShift = Ctrl | Shift,
	CtrlAlt = Ctrl | Alt,
	CtrlAltShift = Ctrl | Alt | Shift,
}

class Hotkey:
	var modifiers: ModCombo

static func get_modifiers() -> ModCombo:
	var index = 0
	if Input.is_key_pressed(KEY_SHIFT):
		index |= ModCombo.Shift
	if Input.is_key_pressed(KEY_ALT):
		index |= ModCombo.Alt
	if Input.is_key_pressed(KEY_CTRL):
		index |= ModCombo.Ctrl

	return index as ModCombo
