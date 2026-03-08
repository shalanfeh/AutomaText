extends PanelContainer
class_name LineContainer

#the array is the children of the HBoxContainer
@export var HContainer: HBoxContainer

var DataHolder: LineData

func _ready() -> void:
	if DataHolder == null or DataHolder.NodeSaveList.size() == 0:
		var Generic: GenericCodeNode = GenericNodeList.GenericList.get("PlaceholderCode")
		if Generic:
			var Placeholder: NodeUI = Generic.Create(null)
			InsertChild(Placeholder)
		else:
			push_error("Could not find generic ", "PlaceholderCode")

#Used to resize self. Child containers resize themselves, 
#But because LineContainer is the root, must be handled manually
func Resize() -> void:
	size = Vector2(0,0)

#inserts data into the data holder and UI
#Used when creating new nodes
func Insert(NewNode: SavedCodeNode, Index: int = -1) -> void:
	#make sure the SavedCodeNode actually points to a real generic node
	var CodeName = NewNode.Name
	if not GenericNodeList.GenericList.has(CodeName):
		push_warning("Unable to add ModifiedCodeNode to list with node name: ", CodeName)
		return
	
	#Instantiate the real thing and add it to line UI
	var GenericResource: GenericCodeNode = GenericNodeList.GenericList.get(CodeName)
	var InstantiatedNode: NodeUI = GenericResource.Create(NewNode)
	InsertChild(InstantiatedNode, Index)
	
	#Add to LineData - through instantiatedNode for null saveCodeNode cases
	DataHolder.Insert(InstantiatedNode.SaveData, Index)

#inserts a NodeUI to the lineUI element
func InsertChild(Child: NodeUI, index: int = -1) -> void:
	# Make sure the child is kinda homeless
	if Child.get_parent():
		Child.get_parent().remove_child(Child)
	
	#Make a new home for child
	var CContainer: CenterContainer = CenterContainer.new()
	HContainer.add_child(CContainer)
	
	# Give child brand new home
	CContainer.add_child(Child) #in farthest index
	
	# Move child to specific location
	if index > -1:
		HContainer.move_child(CContainer, index)
	
	#connect to DragOn signal
	Child.DraggedOn.connect(DragRouter)

#converts LineData into a full lineUI. Assumes LineContainer is empty!
func DataToUi() -> void:
	for SavedNode: SavedCodeNode in DataHolder.NodeSaveList:
		InsertChild(GenericNodeList.GenericList[SavedNode.Name].Create(SavedNode))

#Remove a NodeUI (and corresponding data) from the line
func ExtractNode(Target: NodeUI) -> void:
	Target.DraggedOn.disconnect(DragRouter)
	
	var CContainer: CenterContainer = Target.get_parent()
	HContainer.remove_child(CContainer) 
	CContainer.remove_child(Target) #we MIGHT need the target
	CContainer.queue_free() #we don't need the center container anymore
	
	DataHolder.Remove(Target.SaveData) #remove from data for parity
	
	Resize() #Update self to keep size accurate

#handles the drag and drop behavior with respect to the line
func DragRouter(Caller: NodeUI, Dropped: NodeUI, LeftRight: bool):
	var Generic: GenericCodeNode = GenericNodeList.GenericList.get(Caller.SaveData.Name)
	if Generic == null:
		push_error("Could not find generic for node savedata: ", Caller.SaveData.Name)
		return
	
	if Generic.GetDragOnBehavior() == Generic.DragOnBehaviors.PLACE:
		DragPlace(Caller, Dropped, LeftRight)
		return
	
	DragReplace(Caller, Dropped)


func DragPlace(Caller: NodeUI, Dropped: NodeUI, LeftRight: bool):
	var Idx: int
	if LeftRight:
		#right
		Idx = Caller.get_parent().get_index() + 1
	else:
		#left
		Idx = Caller.get_parent().get_index()
	
	
	# Make sure the dropped is kinda homeless
	if Dropped.get_parent():
		Dropped.get_parent().remove_child(Dropped)
	
	
	#Add Dropped to Data
	DataHolder.Insert(Dropped.SaveData, Idx)
	
	#Add Dropped to UI
	InsertChild(Dropped, Idx)

func DragReplace(Caller: NodeUI, Dropped: NodeUI):
	var Idx: int = Caller.get_index()
	
	#Remove caller
	ExtractNode(Caller)
	Caller.queue_free() #caller is replaced, no need for it anymore
	
	#Add Dropped to Data
	DataHolder.Insert(Dropped.SaveData, Idx)
	
	#Add Dropped to UI
	InsertChild(Dropped, Idx)
