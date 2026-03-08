extends GenericCodeNode


#Needs to take in an execution pointer object for updating
#Context contains thread related variables and stack
#SaveData contains the parameters and variable changed for this node
func Run(Context: BotThread, Pointer: ExecutionPointer, SaveData: SavedCodeNode) -> void:
	print("Ran Placeholder")

#takes in a savedNode to build the node with customized parameters
func Create(Modifications: SavedCodeNode = null) -> NodeUI:
	var CreatedNode: NodeUI = NodeBuilderAPI.NewNode(Modifications)
	CreatedNode.SaveData.Name = Name
	
	var ImgRect: TextureRect = NodeBuilderAPI.InsertImage(CreatedNode, "uid://d31qji6n8202u")
	ImgRect.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	ImgRect.set_size(Vector2(100, 100))
	
	return CreatedNode

func _init() -> void:
	Name = "PlaceholderCode"
	Category = Categories.CODE
	DragOnOverride = DragOnBehaviors.REPLACE
	super()
