extends CenterContainer
class_name ParameterHandler

@export var TexEdit: TextEdit
@export var LinEdit: LineEdit
@export var SpiBox: SpinBox
@export var CheButton: CheckButton
@export var VStamp: VarStamp
@export var EmpVar: TextureRect

enum Modes {LINE, PARAGRAPH, INT, FLOAT, BOOL, VAR_ONLY}
@export var Mode: Modes = Modes.LINE

@export var CanHoldVar: bool = true
@export var ContainedVar: String
@export var HoldingVar: bool = false

#emitted when value is updated via this scene
signal ValueUpdated(NewValue: Variant, IsVar: bool)

func _ready() -> void:
	EventBus.DraggingVariable.connect(VariableIsDragging)
	EventBus.NoLongerDraggingVariable.connect(VariableNoLongerDragging)

#=== exposed functions ===

#sets up the UI according to mode, holdingvar, and containedvar
func Initialize(SetMode: Modes, InitialValue: Variant, VarAllowed: bool, CurrentlyHoldingVar: String = "") -> void:
	if CurrentlyHoldingVar == "":
		HoldingVar = false
	else:
		ContainedVar = CurrentlyHoldingVar
		HoldingVar = true
	
	Mode = SetMode
	CanHoldVar = VarAllowed
	InitializeValue(InitialValue)
	HandleLocalParamEdit()
 
func SetValue(Value: Variant) -> void:
	ValueUpdated.emit(Value, false)
	pass

#=== hidden functions ===
#do we care about the variable?
#if so, show area to drop it
var Dragging: bool = false
var DraggingVar: String = ""
func VariableIsDragging(VarName: String) -> void:
	Dragging = true
	DraggingVar = VarName
	if HoldingVar == false and CanHoldVar:
		if _can_drop_data(Vector2.ZERO, VarName):
			HideAll()
			EmpVar.show()

func VariableNoLongerDragging() -> void:
	Dragging = false
	HandleLocalParamEdit()

func InitializeValue(Value: Variant) -> void:
	if Mode == Modes.LINE:
		LinEdit.text = str(Value)
	elif Mode == Modes.PARAGRAPH:
		TexEdit.text = str(Value)
	elif Mode == Modes.INT or Mode == Modes.FLOAT:
		SpiBox.value = float(Value)
	elif Mode == Modes.BOOL:
		CheButton.button_pressed = bool(Value)

#connects and disconnects signals, hides and shows VStamp
func VarHandler() -> void:
	if CanHoldVar == false:
		return
	
	# == signal handling ==
	#variable renamed
	if BotGlobal.VariableRenamed.is_connected(VarRenamed):
		if HoldingVar == false:
			BotGlobal.VariableRenamed.disconnect(VarRenamed)
	else:
		if HoldingVar == true:
			BotGlobal.VariableRenamed.connect(VarRenamed)
	
	#variable removed
	if BotGlobal.VariableRemoved.is_connected(VarDeleted):
		if HoldingVar == false:
			BotGlobal.VariableRemoved.disconnect(VarDeleted)
	else:
		if HoldingVar == true:
			BotGlobal.VariableRemoved.connect(VarDeleted)
	
	# == Handling visuals ==
	if HoldingVar == true:
		VStamp.SetVar(ContainedVar)
		VStamp.show()
	else:
		VStamp.hide()

#called when var renamed
func VarRenamed(Target: String, NewName: String) -> void:
	if Target == ContainedVar:
		ContainedVar = NewName
		VStamp.SetVar(NewName)

#called when var deleted
func VarDeleted(VarName: String) -> void:
	if VarName == ContainedVar:
		HoldingVar = false
		ContainedVar = ""
		ValueUpdated.emit(null, false)
	if Dragging:
		VariableIsDragging(DraggingVar)
	else:
		VarHandler()
		HandleLocalParamEdit()

func HideAll() -> void:
	TexEdit.hide()
	LinEdit.hide()
	SpiBox.hide()
	CheButton.hide()
	VStamp.hide()
	EmpVar.hide()


#shows the appropriate variable UI
func HandleLocalParamEdit() -> void:
	HideAll()
	
	if HoldingVar == true:
		VarHandler()
		return
	
	match Mode:
		Modes.LINE:
			if not LinEdit.text_changed.is_connected(SetValue):
				LinEdit.text_changed.connect(SetValue)
			LinEdit.show()
		Modes.PARAGRAPH:
			if not TexEdit.text_changed.is_connected(_SetValueFromTexEdit):
				TexEdit.text_changed.connect(_SetValueFromTexEdit)
			TexEdit.show()
		Modes.INT:
			SpiBox.rounded = true
			if not SpiBox.value_changed.is_connected(SetValue):
				SpiBox.value_changed.connect(SetValue)
			SpiBox.show()
		Modes.FLOAT:
			SpiBox.rounded = false
			if not SpiBox.value_changed.is_connected(SetValue):
				SpiBox.value_changed.connect(SetValue)
			SpiBox.show()
		Modes.BOOL:
			if not CheButton.toggled.is_connected(SetValue):
				CheButton.toggled.connect(SetValue)
			CheButton.show()
		Modes.VAR_ONLY:
			EmpVar.show()

func _SetValueFromTexEdit() -> void:
	SetValue(TexEdit.text)

#can this scene take in the dragged variable?
func _can_drop_data(_at_position: Vector2, VarName: Variant) -> bool:
	if typeof(VarName) != TYPE_STRING:
		return false
	
	if CanHoldVar == false:
		return false
	
	var DroppedVar: BotVariable = BotGlobal.DataHolder.Variables.get(VarName)
	if DroppedVar == null:
		print("3")
		return false
	
	if Mode == Modes.VAR_ONLY:
		return true
	
	if Mode == Modes.LINE or Mode == Modes.PARAGRAPH:
		return true
	
	match DroppedVar.Type:
		BotGlobal.VARTYPES.INT:
			if Mode == Modes.INT or Mode == Modes.FLOAT:
				return true
			return false
		BotGlobal.VARTYPES.FLOAT:
			if Mode == Modes.FLOAT or Mode == Modes.INT:
				return true
			return false
		BotGlobal.VARTYPES.BOOLEAN:
			if Mode == Modes.BOOL:
				return true
			return false
	return false

#handle the dropped data
func _drop_data(_at_position: Vector2, VarName: Variant) -> void:
	#varname is always a string, thanks to _can_drop_data
	ContainedVar = VarName
	HoldingVar = true
	ValueUpdated.emit(VarName, true)

const VarStampScene: PackedScene = preload("uid://c2gbw1ppcvlvg")

#handle dragging
func _get_drag_data(_at_position: Vector2) -> String:
	if HoldingVar == false:
		return ""
	
	DragHandler.Dragging = true
	EventBus.DraggingVariable.emit(ContainedVar)
	
	var NewStamp: VarStamp = VarStampScene.instantiate()
	NewStamp.SetVar(ContainedVar)
	NewStamp.tree_exited.connect(func(): DragHandler.Dragging = false)
	NewStamp.tree_exited.connect(func(): EventBus.NoLongerDraggingVariable.emit())
	
	set_drag_preview(NewStamp)
	var NowDragging: String = ContainedVar
	
	VarDeleted(ContainedVar)
	
	return NowDragging
