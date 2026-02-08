extends Node

#CodeNode.tscn
var BaseNode : PackedScene = preload("uid://dfosuh8726bvi")
#title.tscn
var TitleScene : PackedScene = preload("uid://cbqb204tp0cgu")


func NewNode() -> PanelContainer:
	return BaseNode.instantiate()

func InsertTitle(VictimNode: PanelContainer) -> Label:
	var VBox: VBoxContainer = VictimNode.find_child("Container")
	
	#couldn't find VBox
	if not VBox:
		return
	
	var NewLabel = TitleScene.instantiate()
	if not NewLabel.is_class("Label"):
		push_warning(TitleScene, " PackedScene does not return scene of root label")
	return NewLabel
