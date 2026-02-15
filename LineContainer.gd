extends PanelContainer
class_name LineContainer

#the array is the children of the HBoxContainer
@export var HContainer: HBoxContainer

var DataHolder: LineData

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
	
	# Give child brand new home
	HContainer.add_child(Child) #in farthest index
	
	# Move child to specific location
	if index > -1:
		move_child(Child, index)
	

#converts LineData into a full lineUI. Assumes LineContainer is empty!
func DataToUi() -> void:
	for SavedNode: SavedCodeNode in DataHolder.NodeSaveList:
		InsertChild(GenericNodeList.GenericList[SavedNode.Name].Create(SavedNode))
