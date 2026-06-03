extends GenericCodeNode


#Needs to take in an execution pointer object for updating
#Context contains thread related variables and stack
#SaveData contains the parameters and variable changed for this node
func Run(Context: BotThread, Pointer: ExecutionPointer, SaveData: SavedCodeNode) -> void:
	var Sender: String = str(SaveData.GetParam("Sender"))
	var Content: String = str(SaveData.GetParam("Content"))
	Prg.CurrentSession.ViewPort.CreateMsg(Sender, Content)

#takes in a savedNode to build the node with customized parameters
func Create(Modifications: SavedCodeNode = null) -> NodeUI:
	var CreatedNode: NodeUI = NodeBuilderAPI.NewNode(Modifications)
	CreatedNode.SaveData.Name = Name
	
	var Title: Label = NodeBuilderAPI.InsertTitle(CreatedNode)
	Title.text = "Send Message"
	
	NodeBuilderAPI.InsertParameter(
		CreatedNode, "Sender", "Sender", ParameterHandler.Modes.LINE, true)
	
	NodeBuilderAPI.InsertParameter(
		CreatedNode, "Content", "", ParameterHandler.Modes.PARAGRAPH, true)
	
	return CreatedNode

func _init() -> void:
	Name = "SendMsg"
	Category = Categories.CODE
	super()
