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
	var icon: Image


static func bool_to_modifiers(shift: bool, alt: bool, ctrl: bool) -> ModCombo:
	return (
		(ModCombo.Alt if alt else 0)
		| (ModCombo.Shift if shift else 0)
		| (ModCombo.Ctrl if ctrl else 0)
	)


static func get_modifiers() -> ModCombo:
	return bool_to_modifiers(
		Input.is_key_pressed(KEY_SHIFT),
		Input.is_key_pressed(KEY_ALT),
		Input.is_key_pressed(KEY_CTRL)
	)
