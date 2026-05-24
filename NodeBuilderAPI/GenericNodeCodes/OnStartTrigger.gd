extends GenericCodeNode

#Needs to take in an execution pointer object for updating
#Context contains thread related variables and stack
#SaveData contains the parameters and variable changed for this node
func Run(Context: BotThread, Pointer: ExecutionPointer, SaveData: SavedCodeNode) -> void:
	print("Ran OnStart Trigger")

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
	Title.text = "On Start"
	
	return CreatedNode

func _init() -> void:
	Name = "OnStartTrigger"
	Category = Categories.TRIGGER
	
	super()
