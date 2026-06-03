extends CenterContainer
class_name VarStamp

@export var NameLabel: Label

@export var BgBlue: StyleBoxFlat = StyleBoxFlat.new()
@export var BGRed: StyleBoxFlat = StyleBoxFlat.new()
@export var BGOrange: StyleBoxFlat = StyleBoxFlat.new()
@export var BGGrey: StyleBoxFlat = StyleBoxFlat.new()

func SetVar(Target: String) -> void:
	if !BotGlobal.DataHolder.Variables.has(Target):
		push_error("Variable does not exist: ", Target)
		return
	
	NameLabel.text = Target
	var BotVar: BotVariable = BotGlobal.DataHolder.Variables.get(Target)
	match BotVar.Type:
		BotGlobal.VARTYPES.STRING:
			NameLabel.add_theme_stylebox_override("normal", BgBlue)
		BotGlobal.VARTYPES.INT:
			NameLabel.add_theme_stylebox_override("normal", BGRed)
		BotGlobal.VARTYPES.FLOAT:
			NameLabel.add_theme_stylebox_override("normal", BGOrange)
		BotGlobal.VARTYPES.BOOLEAN:
			NameLabel.add_theme_stylebox_override("normal", BGGrey)
