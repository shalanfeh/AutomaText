extends HBoxContainer
class_name VarEditor

@export var VarName: String

@export var TypeLabel: Label

@export var TextEntry: LineEdit
@export var NumberEntry: SpinBox
@export var BoolEntry: CheckButton

enum LISTENING_TO {NONE, TEXT, NUMBER, BOOL}
var CurrentConnection: LISTENING_TO = LISTENING_TO.NONE

func SetVar(Target: String) -> void:
	if !BotGlobal.DataHolder.Variables.has(Target):
		push_error("Variable '", Target, "' Does not exist")
	VarName = Target
	UpdateMode()
	

func ListenTo(Target: LISTENING_TO) -> void:
	#disconnect any listening signals
	if CurrentConnection == LISTENING_TO.TEXT:
		TextEntry.text_changed.disconnect(UpdateVar)
	elif CurrentConnection == LISTENING_TO.NUMBER:
		NumberEntry.value_changed.disconnect(UpdateVar)
	elif CurrentConnection == LISTENING_TO.BOOL:
		BoolEntry.pressed.disconnect(UpdateVar)
	
	#declare new listening target
	CurrentConnection = Target
	
	#connect to new signal
	match Target:
		LISTENING_TO.TEXT:
			TextEntry.text_changed.connect(UpdateVar.unbind(1))
		LISTENING_TO.NUMBER:
			NumberEntry.value_changed.connect(UpdateVar.unbind(1))
		LISTENING_TO.BOOL:
			BoolEntry.pressed.connect(UpdateVar)

func UpdateMode() -> void:
	#clean
	TypeLabel.text = ""
	TextEntry.hide()
	NumberEntry.hide()
	BoolEntry.hide()
	
	#figure out mode
	var BotVar: BotVariable = BotGlobal.DataHolder.Variables.get(VarName)
	if BotVar == null:
		push_error("Variable '", VarName, "' Does not exist")
		return
	
	if BotVar.Type == BotGlobal.VARTYPES.STRING:
		TextEntry.text = BotVar.Value
		ListenTo(LISTENING_TO.TEXT)
		TextEntry.show()
	elif BotVar.Type == BotGlobal.VARTYPES.INT or BotVar.Type == BotGlobal.VARTYPES.FLOAT:
		if BotVar.Type == BotGlobal.VARTYPES.INT:
			TypeLabel.text = "Int"
			NumberEntry.rounded = true
			NumberEntry.step = 1.0
		else:
			TypeLabel.text = "Float"
			NumberEntry.rounded = false
			NumberEntry.step = 0.0
		NumberEntry.value = BotVar.Value
		ListenTo(LISTENING_TO.NUMBER)
		NumberEntry.show()
	elif BotVar.Type == BotGlobal.VARTYPES.BOOLEAN:
		BoolEntry.button_pressed = BotVar.Value
		ListenTo(LISTENING_TO.BOOL)
		BoolEntry.show()

func UpdateVar() -> void:
	var BotVar: BotVariable = BotGlobal.DataHolder.Variables.get(VarName)
	if BotVar == null:
		push_error("Variable '", VarName, "' Does not exist")
		return
	
	match CurrentConnection:
		LISTENING_TO.TEXT:
			BotVar.Value = TextEntry.text
		LISTENING_TO.NUMBER:
			BotVar.Value = NumberEntry.value
		LISTENING_TO.BOOL:
			BotVar.Value = BoolEntry.button_pressed
