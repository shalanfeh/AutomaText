extends Node

#CodeNode.tscn
var BaseNode : PackedScene = preload("uid://dfosuh8726bvi")

#title.tscn
var TitleScene : PackedScene = preload("uid://cbqb204tp0cgu")


func NewNode(SaveData: SavedCodeNode) -> NodeUI:
	var Instance: NodeUI = BaseNode.instantiate()
	
	#assigning saveData properly, creating if no data is provided
	if SaveData == null:
		Instance.SaveData = SavedCodeNode.new()
	else:
		Instance.SaveData = SaveData
	
	return Instance
	
func InsertTitle(VictimNode: NodeUI) -> Label:
	#couldn't find VBox
	if VictimNode.NodeItemContainer == null:
		push_warning(VictimNode, ".NodeItemContainer == null!")
		return null
	
	var NewLabel = TitleScene.instantiate()
	if not NewLabel.is_class("Label"):
		push_warning(TitleScene, " PackedScene does not return scene of root label")
	return NewLabel
