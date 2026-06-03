extends GenericCodeNode


#Needs to take in an execution pointer object for updating
#Context contains thread related variables and stack
#SaveData contains the parameters and variable changed for this node
func Run(Context: BotThread, Pointer: ExecutionPointer, SaveData: SavedCodeNode) -> void:
	var SeqToRun: String = str(SaveData.GetParam("RunTarget"))
	if Prg.CodeToRun.Sequences.has(SeqToRun):
		Context.Push(SeqToRun)

func OnProgramStart(SeqName: String) -> void:
	print("Started from onStartTrigger")
	var NewThread: BotThread = BotThread.new()
	NewThread.Push(SeqName)
	RunTime.AddThread(NewThread)

#takes in a savedNode to build the node with customized parameters
func Create(Modifications: SavedCodeNode = null) -> NodeUI:
	var CreatedNode: NodeUI = NodeBuilderAPI.NewNode(Modifications)
	CreatedNode.SaveData.Name = Name
	
	var Title: Label = NodeBuilderAPI.InsertTitle(CreatedNode)
	Title.text = "Call Sequence"
	
	var InputParam: ParameterHandler = NodeBuilderAPI.InsertParameter(
		CreatedNode, "RunTarget", "", ParameterHandler.Modes.PARAGRAPH, true)
	
	return CreatedNode

func _init() -> void:
	Name = "Run Sequence"
	Category = Categories.CODE
	super()
