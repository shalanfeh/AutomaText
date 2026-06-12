extends GenericCodeNode

#Needs to take in an execution pointer object for updating
#Context contains thread related variables and stack
#SaveData contains the parameters and variable changed for this node
func Run(Context: BotThread, Pointer: ExecutionPointer, SaveData: SavedCodeNode) -> void:
	var TargetVar: String = ""
	if SaveData.IsVariable("Target"):
		TargetVar = SaveData.VarParameters.get("Target")
	else:
		return
	
	var VarInBot: BotVariable = Prg.CurrentSession.Variables.get(TargetVar)
	if VarInBot:
		if VarInBot.Type == BotGlobal.VARTYPES.STRING:
			VarInBot.Value = Context.Heap.get("InitialInput")

func OnProgramStart(SeqName: String) -> void:
	Prg.CurrentSession.ViewPort.TextEntered.connect(
		func(TextInput: String):
			var NewThread: BotThread = BotThread.new()
			NewThread.Heap["InitialInput"] = TextInput
			NewThread.Push(SeqName)
			RunTime.AddThread(NewThread)
	)

#takes in a savedNode to build the node with customized parameters
func Create(Modifications: SavedCodeNode = null) -> NodeUI:
	var CreatedNode: NodeUI = NodeBuilderAPI.NewNode(Modifications)
	CreatedNode.SaveData.Name = Name
	
	var Title: Label = NodeBuilderAPI.InsertTitle(CreatedNode)
	Title.text = "Input Entered"
	
	NodeBuilderAPI.InsertParameter(
		CreatedNode, "Target", "", ParameterHandler.Modes.VAR_ONLY, true)
	
	return CreatedNode

func _init() -> void:
	Name = "Input Entered"
	Category = Categories.TRIGGER
	
	super()
