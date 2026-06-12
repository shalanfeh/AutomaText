extends GenericCodeNode


#Needs to take in an execution pointer object for updating
#Context contains thread related variables and stack
#SaveData contains the parameters and variable changed for this node
func Run(Context: BotThread, Pointer: ExecutionPointer, SaveData: SavedCodeNode) -> void:
	var raw1: String = str(SaveData.GetParam("Param1"))
	var raw2: String = str(SaveData.GetParam("Param2"))
	var op: ConditionalOperatorSelector.Operators = SaveData.GetParam("Condition")
	
	var val1: Variant = TryParseNumber(raw1)
	var val2: Variant = TryParseNumber(raw2)
	
	# If one is numeric and the other isn't, coerce both to string so
	# comparisons stay well-defined (e.g. "5" == 5 would otherwise be false).
	if typeof(val1) != typeof(val2):
		val1 = str(val1)
		val2 = str(val2)
	
	var passed: bool = EvaluateCondition(val1, val2, op)
	
	if passed:
		Pointer.leaf = SaveData.GetParam("Connections").Upper[0]
	else:
		Pointer.leaf = SaveData.GetParam("Connections").Lower[0]
	Pointer.index = 0

#takes in a savedNode to build the node with customized parameters
func Create(Modifications: SavedCodeNode = null) -> NodeUI:
	var CreatedNode: NodeUI = NodeBuilderAPI.NewNode(Modifications)
	CreatedNode.SaveData.Name = Name
	
	if !(CreatedNode.SaveData.Parameters.has("Connections")):
		CreatedNode.SaveData.Parameters["Connections"] = Connections.new(1, 1)
		var Conn: Connections = CreatedNode.SaveData.GetParam("Connections")
		Conn.UpperNames[0] = "Pass"
		Conn.LowerNames[0] = "Fail"
	
	var Title: Label = NodeBuilderAPI.InsertTitle(CreatedNode)
	Title.text = "If"
	
	NodeBuilderAPI.InsertParameter(
		CreatedNode, "Param1", "", ParameterHandler.Modes.LINE, true)
	
	NodeBuilderAPI.InsertConditionalOperator(CreatedNode, "Condition")
	
	NodeBuilderAPI.InsertParameter(
		CreatedNode, "Param2", "", ParameterHandler.Modes.LINE, true)
	
	return CreatedNode

func _init() -> void:
	Name = "If Then"
	Category = Categories.ENDING
	
	super()

# Returns a float if the string parses as a number, otherwise the original string.
func TryParseNumber(value: String) -> Variant:
	if value.is_valid_float():
		return value.to_float()
	return value

func EvaluateCondition(a: Variant, b: Variant, op: int) -> bool:
	match op:
		ConditionalOperatorSelector.Operators.EQUAL:         return a == b
		ConditionalOperatorSelector.Operators.UNEQUAL:       return a != b
		ConditionalOperatorSelector.Operators.LESSER:        return a < b
		ConditionalOperatorSelector.Operators.GREATER:       return a > b
		ConditionalOperatorSelector.Operators.LESSER_EQUAL:  return a <= b
		ConditionalOperatorSelector.Operators.GREATER_EQUAL: return a >= b
	return false
