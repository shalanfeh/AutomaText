extends Node

#CodeNode.tscn
var BaseNode : PackedScene = preload("uid://dfosuh8726bvi")
const ParamHandlerScene: PackedScene = preload("uid://dboyros5s3h3i")
const ConditionalHandlerScene: PackedScene = preload("uid://cvgmtlnie18c0")
const MathHandlerScene: PackedScene = preload("uid://m3v67rk2w0g3")

func NewNode(SaveData: SavedCodeNode) -> NodeUI:
	var Instance: NodeUI = BaseNode.instantiate()
	
	#assigning saveData properly, creating if no data is provided
	if SaveData == null:
		Instance.SaveData = SavedCodeNode.new()
	else:
		Instance.SaveData = SaveData
	
	var GenericNode: GenericCodeNode = GenericNodeList.GenericList.get(Instance.SaveData.Name)
	if GenericNode:
		if GenericNode.Category == GenericNode.Categories.ENDING:
			Instance.set_theme_type_variation("EndNode")
	
	return Instance

func InsertTitle(VictimNode: NodeUI) -> Label:
	#couldn't find VBox
	if VictimNode.NodeItemContainer == null:
		push_warning(VictimNode, ".NodeItemContainer == null!")
		return null
	
	var NewLabel = Label.new()
	VictimNode.NodeItemContainer.add_child(NewLabel)
	
	return NewLabel

func InsertImage(VictimNode: NodeUI, FilePath: String) -> TextureRect:
	#couldn't find VBox
	if VictimNode.NodeItemContainer == null:
		push_warning(VictimNode, ".NodeItemContainer == null!")
		return null
	
	var NewImageRect: TextureRect = TextureRect.new()
	
	NewImageRect.texture = load(FilePath)
	VictimNode.NodeItemContainer.add_child(NewImageRect)
	
	return NewImageRect
	

func InsertParameter(VictimNode: NodeUI, ParamName: String,
DefaultParam: Variant, SetMode: ParameterHandler.Modes, VarAllowed: bool) -> ParameterHandler:
	#couldn't find VBox
	if VictimNode.NodeItemContainer == null:
		push_warning(VictimNode, ".NodeItemContainer == null!")
		return null
	
	var SNC = VictimNode.SaveData
	if SNC.Parameters.get(ParamName) == null:
		SNC.Parameters[ParamName] = DefaultParam
	
	var NewParam: ParameterHandler = ParamHandlerScene.instantiate()
	if VictimNode.SaveData.IsVariable(ParamName):
		NewParam.Initialize(SetMode, SNC.Parameters.get(ParamName), VarAllowed, 
		VictimNode.SaveData.VarParameters.get(ParamName))
	else:
		NewParam.Initialize(SetMode, SNC.Parameters.get(ParamName), VarAllowed)
	
	NewParam.ValueUpdated.connect(
		func(NewValue: Variant, IsVar: bool): 
		_ParamEdited(VictimNode, ParamName, NewValue, IsVar)
		)
	
	VictimNode.NodeItemContainer.add_child(NewParam)
	
	return NewParam

func InsertConditionalOperator(VictimNode: NodeUI, ParamName: String) -> ConditionalOperatorSelector:
	if VictimNode.NodeItemContainer == null:
		push_warning(VictimNode, ".NodeItemContainer == null!")
		return null
	
	var SNC = VictimNode.SaveData
	if SNC.Parameters.get(ParamName) == null:
		SNC.Parameters[ParamName] = 0
	
	var NewConditional: ConditionalOperatorSelector = ConditionalHandlerScene.instantiate()
	NewConditional.OperatorChanged.connect(func(idx): SNC.Parameters[ParamName] = idx)
	
	VictimNode.NodeItemContainer.add_child(NewConditional)
	
	return NewConditional

func InsertMathOperator(VictimNode: NodeUI, ParamName: String) -> MathOperationSelector:
	if VictimNode.NodeItemContainer == null:
		push_warning(VictimNode, ".NodeItemContainer == null!")
		return null
	
	var SNC = VictimNode.SaveData
	if SNC.Parameters.get(ParamName) == null:
		SNC.Parameters[ParamName] = 0
	
	var NewOperation: MathOperationSelector = MathHandlerScene.instantiate()
	NewOperation.OperatorChanged.connect(func(idx): SNC.Parameters[ParamName] = idx)
	
	VictimNode.NodeItemContainer.add_child(NewOperation)
	
	return NewOperation

#== private ==

func _ParamEdited(VictimNode: NodeUI, ParamName: String, NewValue: Variant, isVar: bool) -> void:
	var SNC: SavedCodeNode = VictimNode.SaveData
	#parameter is no longer variable
	if NewValue == null:
		SNC.VarParameters.erase(ParamName)
		return
	
	#parameter is a new variable
	if isVar:
		SNC.VarParameters[ParamName] = NewValue
		return
	
	#parameter is a local value
	SNC.Parameters[ParamName] = NewValue
