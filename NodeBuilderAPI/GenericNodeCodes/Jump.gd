extends GenericCodeNode


#Needs to take in an execution pointer object for updating
#Context contains thread related variables and stack
#SaveData contains the parameters and variable changed for this node
func Run(Context: BotThread, Pointer: ExecutionPointer, SaveData: SavedCodeNode) -> void:
	var JmpName: String = "Jump_" + str(SaveData.GetParam("JumpName"))
	if Context.Heap.has(JmpName):
		var saved: Array = Context.Heap[JmpName]
		var restored: Array[ExecutionPointer] = []
		for ptr in saved:
			restored.append(ptr.Clone())  # clone again so future jumps don't share state
		Context.Stack = restored
	
#takes in a savedNode to build the node with customized parameters
func Create(Modifications: SavedCodeNode = null) -> NodeUI:
	var CreatedNode: NodeUI = NodeBuilderAPI.NewNode(Modifications)
	CreatedNode.SaveData.Name = Name
	
	if !(CreatedNode.SaveData.Parameters.has("Connections")):
		CreatedNode.SaveData.Parameters["Connections"] = Connections.new(0, 1)
		var Conn: Connections = CreatedNode.SaveData.GetParam("Connections")
		Conn.LowerNames[0] = "No Jump Set"
		
	var Title: Label = NodeBuilderAPI.InsertTitle(CreatedNode)
	Title.text = "Jump"
	
	NodeBuilderAPI.InsertParameter(
		CreatedNode, "JumpName", "", ParameterHandler.Modes.LINE, true)
	
	return CreatedNode

func _init() -> void:
	Name = "Jump"
	Category = Categories.ENDING
	
	super()
