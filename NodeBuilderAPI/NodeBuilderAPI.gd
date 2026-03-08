extends Node

#CodeNode.tscn
var BaseNode : PackedScene = preload("uid://dfosuh8726bvi")


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
	
