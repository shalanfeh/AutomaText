extends SubViewport
class_name WorldSubviewPort

@export var Camera: Camera2D
@export var SeqContainer: SequenceUI

var CurrentlyShowing: String = ""

func _ready() -> void:
	EventBus.TabSelected.connect(TabOpened)
	EventBus.TabClosed.connect(TabClosed)
	pass

func TabOpened(SeqName: String) -> void:
	if BotGlobal.DataHolder.Sequences.has(SeqName):
		SeqContainer.SetUp(SeqName)
		CurrentlyShowing = SeqName
	pass

func TabClosed(NewTab: String) -> void:
	if NewTab == CurrentlyShowing:
		return
	TabOpened(NewTab)
