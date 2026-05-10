extends ScrollContainer
class_name SequenceList

@export_category("Child Nodes")
@export var ChildHolder: VBoxContainer

@export_category("Neccessary variables")
@export var SeqButtonScene: PackedScene = preload("uid://d3ohd6xceon41")

var Children: Dictionary[String, SequenceButton] = {}

func _ready() -> void:
	BotGlobal.SequenceAdded.connect(AddChild)
	BotGlobal.SequenceRemoved.connect(RemoveChild)
	BotGlobal.SequenceRenamed.connect(ChildRenamed)
	BotGlobal.Refresh.connect(OnRefresh)

func AddChild(SeqName: String) -> void:
	#prevent duplicates
	if Children.has(SeqName):
		return
	
	#instantiate SeqButtonScene
	var NewButton: SequenceButton = SeqButtonScene.instantiate()
	ChildHolder.add_child(NewButton)
	
	#add it to children dictionary
	Children[SeqName] = NewButton
	
	#set the button's display name
	NewButton.ChangeName(SeqName)

func RemoveChild(SeqName: String) -> void:
	#check if child exists, if not return
	if not Children.has(SeqName):
		return
	
	#queue_free the button and remove from dictionary
	Children[SeqName].queue_free()
	Children.erase(SeqName)

func ChildRenamed(SeqName: String, NewName: String) -> void:
	#check if child exists, if not return
	if not Children.has(SeqName):
		return
	
	#move the button to new key in dictionary
	var TargetButton: SequenceButton = Children[SeqName]
	Children.erase(SeqName)
	Children[NewName] = TargetButton
	
	#update the button's display name
	TargetButton.ChangeName(NewName)

func OnRefresh() -> void:
	#delete all children from dictionary
	for ChildKey in Children.keys():
		Children[ChildKey].queue_free()
	Children.clear()
	
	#loop through dataholder.sequences and add child for each one
	for SeqName in BotGlobal.DataHolder.Sequences.keys():
		AddChild(SeqName)
