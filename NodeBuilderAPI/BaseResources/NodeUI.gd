extends PanelContainer
class_name NodeUI

#LeftRight is for place logic. false = left, true = right
signal DraggedOn(Caller: NodeUI, Dropped: NodeUI, LeftRight: bool)

#Emitted when the node is dragged - Caller is self
signal Dragged(Caller: NodeUI)

#container that holds node items (labels, variable inputs, etc)
@export var NodeItemContainer: Container = null

#must keep track of the data its related to.
@export var SaveData: SavedCodeNode = null

#set its style to match its purpose
func _ready() -> void:
	var Generic: GenericCodeNode = GenericNodeList.GenericList.get(SaveData.Name)
	if Generic == null:
		push_error("Could not find generic for node savedata: ", SaveData.Name)
		return
	
	match Generic.Category:
		Generic.Categories.TRIGGER:
			set_theme_type_variation("TriggerNode")
		Generic.Categories.ENDING:
			set_theme_type_variation("EndNode")

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	#if data is not a NodeUI, can't drop.
	if not (data is NodeUI):
		return false
	
	#get the generics
	var Generic: GenericCodeNode = GenericNodeList.GenericList.get(SaveData.Name)
	var ForeignGeneric: GenericCodeNode = GenericNodeList.GenericList.get(data.SaveData.Name)
	
	if Generic == null:
		push_error("Could not find generic for node savedata: ", SaveData.Name)
		return false
	if ForeignGeneric == null:
		push_error("Could not find generic for node savedata: ", data.SaveData.Name)
		return false
	
	#drop-able if they are of the same category
	return (Generic.Category == ForeignGeneric.Category)

func _drop_data(at_position: Vector2, data: Variant) -> void:
	#Get the (foreign)generic
	var Generic: GenericCodeNode = GenericNodeList.GenericList.get(SaveData.Name)
	if Generic == null:
		push_error("Could not find generic for node savedata: ", SaveData.Name)
		return
	
	#find leftRight
	var LeftRight: bool = false
	if Generic.GetDragOnBehavior() == Generic.DragOnBehaviors.PLACE:
		var Mid: int = (position.x + size.x)/2
		if at_position.x > Mid:
			LeftRight = true
	
	#emit the signal
	DraggedOn.emit(self, data, LeftRight)

func _get_drag_data(at_position: Vector2) -> NodeUI:
	DragHandler.Dragging = true
	
	var NewNode: NodeUI = GenericNodeList.GenericList.get(SaveData.Name).Create(SaveData)
	var NicerPreview: CenterContainer = CenterContainer.new()
	NicerPreview.tree_exited.connect(func(): DragHandler.Dragging = false)
	
	NicerPreview.add_child(NewNode)
	
	set_drag_preview(NicerPreview)
	
	Dragged.emit(self)
	
	#Must create a new one here because the one used for the drag UI will be deleted
	#according to the documentation for set_drag_preview
	return GenericNodeList.GenericList.get(SaveData.Name).Create(SaveData)
