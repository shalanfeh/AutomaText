extends CenterContainer
class_name LeafContainer

#signal used when an ending is created/set
signal RequestingLeafPropagation(Connector: Connections)
signal RequestTreeRebuild

@export var HBox: HBoxContainer
@export var LineUI:  LineContainer
@export var EndingHolderUI: CenterContainer
@export var LeafName: Label

var EndingUI: NodeUI: set = SetEndingUI

@export var DataHolder: LeafData

func _ready() -> void:
	if DataHolder == null:
		DataHolder = LeafData.new()
	LineUI.RequestTreeRebuild.connect(OnLineRequest)

func OnLineRequest() -> void:
	RequestTreeRebuild.emit() 
	Resize()

#Used to resize self. Child containers resize themselves, 
#But because LineContainer is the root, must be handled manually
func Resize() -> void:
	size = Vector2(0,0)
	LeafName.position = Vector2(0, 0)

#for updating the drag signal
func SetEndingUI(value: NodeUI) -> void:
	if EndingUI != null:
		EndingUI.DraggedOn.disconnect(EndingDraggedOn)
		EndingUI.Dragged.disconnect(EndingDragged)
	
	if value != null:
		value.DraggedOn.connect(EndingDraggedOn)
		value.Dragged.connect(EndingDragged)
	
	EndingUI = value

func CreatePlaceholderEnding() -> bool:
	var TempGenericCode: GenericCodeNode = GenericNodeList.GenericList.get("PlaceHolderEnding")
	if TempGenericCode == null:
		push_error("Couldn't find ", TempGenericCode.Name, " in GenericList")
		return false
	
	if EndingUI:
		push_warning("EndingUI aleady exists, couldn't create placeholder")
		return false
	
	EndingUI = TempGenericCode.Create(null)
	EndingHolderUI.add_child(EndingUI)
	Resize()
	
	DataHolder.EndingNode = EndingUI.SaveData
	return true

#given just saveNodeData, updates data and UI - used in LoadFromData
func NewEndingNodeData(SaveData: SavedCodeNode) -> bool:
	#Get the generic
	var TempGenericCode: GenericCodeNode = GenericNodeList.GenericList.get(SaveData.Name)
	if TempGenericCode == null:
		push_error("Couldn't find ", SaveData.Name, " in GenericList")
		return false
	
	#make sure its an ending node
	if TempGenericCode.Category != TempGenericCode.Categories.ENDING:
		push_error("Node is not of category ending: ", TempGenericCode.Name)
		return false
	
	#it's an ending node
	#Handle case where EndingUI already exists
	if EndingUI:
		EndingHolderUI.remove_child(EndingUI)
		EndingUI.queue_free()
	
	#create ending UI
	EndingUI = TempGenericCode.Create(SaveData)
	EndingHolderUI.add_child(EndingUI)
	Resize()
	
	#parity with data
	DataHolder.SetEndingNode(SaveData)
	
	#Request sequence to update the tree
	RequestingLeafPropagation.emit(SaveData.GetParam("Connections"))
	RequestTreeRebuild.emit()
	return true

#given just NodeUI, update data and UI
func NewEndingNode(Target: NodeUI) -> void:
	#dont worry about other parent, nodeUI sends an extract signal to its old parent (will)
	NewEndingNodeData(Target.SaveData)
	Target.queue_free()

#loads leaf data into the UI
func LoadFromData():
	#Create ending node scene
	if DataHolder.EndingNode == null:
		if not CreatePlaceholderEnding():
			return
	else:
		if not NewEndingNodeData(DataHolder.EndingNode):
			if not CreatePlaceholderEnding():
				return
	
	#Align LineUI to the correct data
	LineUI.DataHolder = DataHolder.LineNodes
	
	#load the LineUI using the data
	LineUI.DataToUi()
	pass


func EndingDraggedOn(Caller: NodeUI, Dropped: NodeUI, _LR: bool) -> void:
	NewEndingNode(Dropped)

func EndingDragged(Caller: NodeUI) -> void:
	EndingHolderUI.remove_child(EndingUI)
	EndingUI.queue_free()
	
	EndingUI = null
	
	CreatePlaceholderEnding()
	
	RequestTreeRebuild.emit()

#--- postponed until testing is possible ---
#handle the setting of the ending node through UI interaction

#handle the drag and drop behavior with respect to the ending node

#handle deletion
