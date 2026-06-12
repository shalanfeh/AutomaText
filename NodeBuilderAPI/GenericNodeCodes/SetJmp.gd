extends GenericCodeNode


#Needs to take in an execution pointer object for updating
#Context contains thread related variables and stack
#SaveData contains the parameters and variable changed for this node
func Run(Context: BotThread, Pointer: ExecutionPointer, SaveData: SavedCodeNode) -> void:
	var JmpName: String = "Jump_" + str(SaveData.GetParam("JumpName"))
	var snapshot: Array[ExecutionPointer] = []
	for ptr in Context.Stack:
		snapshot.append(ptr.Clone())
	Context.Heap[JmpName] = snapshot

#takes in a savedNode to build the node with customized parameters
func Create(Modifications: SavedCodeNode = null) -> NodeUI:
	var CreatedNode: NodeUI = NodeBuilderAPI.NewNode(Modifications)
	CreatedNode.SaveData.Name = Name
	
	var Title: Label = NodeBuilderAPI.InsertTitle(CreatedNode)
	Title.text = "Set Jump"
	
	NodeBuilderAPI.InsertParameter(
		CreatedNode, "JumpName", "", ParameterHandler.Modes.LINE, true)
	
	return CreatedNode

func _init() -> void:
	Name = "Set Jump"
	Category = Categories.CODE
	super()
