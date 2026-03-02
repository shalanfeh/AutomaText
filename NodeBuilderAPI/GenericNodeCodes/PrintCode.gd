extends GenericCodeNode


#Needs to take in an execution pointer object for updating
#Context contains thread related variables and stack
#SaveData contains the parameters and variable changed for this node
func Run(Context: BotThread, Pointer: ExecutionPointer, SaveData: SavedCodeNode) -> void:
	print("Ran Print")

#takes in a savedNode to build the node with customized parameters
func Create(Modifications: SavedCodeNode = null) -> NodeUI:
	var CreatedNode: NodeUI = NodeBuilderAPI.NewNode(Modifications)
	
	var Title: Label = NodeBuilderAPI.InsertTitle(CreatedNode)
	Title.text = "Print"
	
	return CreatedNode

func _init() -> void:
	Name = "PrintCode"
	Category = Categories.CODE
	super()
