extends PanelContainer
class_name LineContainer

#the array is the children of the HBoxContainer
@export var HContainer: HBoxContainer

var DataHolder: LineData

#inserts data into the data holder and UI
func Insert(NewNode: ModifiedCodeNode, Index: int = -1) -> void:
	#make sure the modifiedCodeNode actually points to a real generic node
	var CodeName = NewNode.Name
	if not GenericNodeList.GenericList.has(CodeName):
		push_warning("Unable to add ModifiedCodeNode to list with node name: ", CodeName)
		return
	
	#Add to LineData
	DataHolder.Insert(NewNode, Index)
	
	#Instantiate the real thing and add it to line UI
	var GenericResource: GenericCodeNode = GenericNodeList.GenericList.get(CodeName)
	var InstantiatedNode: PanelContainer = GenericResource.Create(NewNode)
	InsertChild(InstantiatedNode, Index)

#inserts a node UI element to the line UI element
func InsertChild(Child: PanelContainer, index: int = -1) -> void:
	# Make sure the child is kinda homeless
	if Child.get_parent():
		Child.get_parent().remove_child(Child)
	
	# Give child brand new home
	HContainer.add_child(Child) #in farthest index
	
	# Move child to specific location
	if index > -1:
		move_child(Child, index)
	

#loads data into the UI
func DataToUi() -> void:
	
	pass
