extends GenericCodeNode

func Run(Context: BotThread, Pointer: ExecutionPointer, SaveData: SavedCodeNode) -> void:
	var raw1: String = str(SaveData.GetParam("Param1"))
	var raw2: String = str(SaveData.GetParam("Param2"))
	var op: MathOperationSelector.Operators = SaveData.GetParam("Operator")
	
	if not SaveData.IsVariable("SaveInto"):
		return
	var TargetVar: String = SaveData.VarParameters.get("SaveInto")
	
	var VarInBot: BotVariable = Prg.CurrentSession.Variables.get(TargetVar)
	if VarInBot == null:
		push_error("Math node: variable '%s' not found" % TargetVar)
		return
	
	var result: Variant = EvaluateMath(raw1, raw2, op)
	
	match VarInBot.Type:
		BotGlobal.VARTYPES.INT:
			VarInBot.Value = int(_to_number(result))
		BotGlobal.VARTYPES.FLOAT:
			VarInBot.Value = float(_to_number(result))
		BotGlobal.VARTYPES.STRING:
			VarInBot.Value = str(result)

# Coerce a result (which might be int, float, or string) to a number.
# Strings that aren't valid numbers become 0.
func _to_number(value: Variant) -> float:
	match typeof(value):
		TYPE_INT, TYPE_FLOAT:
			return value
		TYPE_STRING:
			if value.is_valid_float():
				return value.to_float()
			return 0.0
	return 0.0

func Create(Modifications: SavedCodeNode = null) -> NodeUI:
	var CreatedNode: NodeUI = NodeBuilderAPI.NewNode(Modifications)
	CreatedNode.SaveData.Name = Name
	
	var Title: Label = NodeBuilderAPI.InsertTitle(CreatedNode)
	Title.text = "Math"
	
	NodeBuilderAPI.InsertParameter(
		CreatedNode, "Param1", "", ParameterHandler.Modes.LINE, true)
	
	NodeBuilderAPI.InsertMathOperator(CreatedNode, "Operator")
	
	NodeBuilderAPI.InsertParameter(
		CreatedNode, "Param2", "", ParameterHandler.Modes.LINE, true)
	
	NodeBuilderAPI.InsertParameter(
		CreatedNode, "SaveInto", "", ParameterHandler.Modes.VAR_ONLY, true)
	
	return CreatedNode

func _init() -> void:
	Name = "Math"
	Category = Categories.CODE
	super()

# Parses a string as an int if possible, else a float, else returns the original string.
func TryParseNumber(value: String) -> Variant:
	if value.is_valid_int():
		return value.to_int()
	if value.is_valid_float():
		return value.to_float()
	return value

func EvaluateMath(raw_a: String, raw_b: String, op: int) -> Variant:
	# ADD is special: if either side isn't a number, do string concatenation.
	if op == MathOperationSelector.Operators.ADD:
		var pa: Variant = TryParseNumber(raw_a)
		var pb: Variant = TryParseNumber(raw_b)
		if pa is String or pb is String:
			return raw_a + raw_b
		return pa + pb
	
	# All other operators require numbers.
	var a: Variant = ParseNumberOrZero(raw_a)
	var b: Variant = ParseNumberOrZero(raw_b)
	
	match op:
		MathOperationSelector.Operators.SUBTRACT: return a - b
		MathOperationSelector.Operators.MULTIPLY: return a * b
		MathOperationSelector.Operators.DIVIDE:
			if b == 0:
				push_error("Math node: division by zero")
				return 0
			if typeof(a) == TYPE_INT and typeof(b) == TYPE_INT:
				return a / b
			return float(a) / float(b)
	return 0

# Same as TryParseNumber but warns and returns 0 if not a number.
func ParseNumberOrZero(value: String) -> Variant:
	if value.is_valid_int():
		return value.to_int()
	if value.is_valid_float():
		return value.to_float()
	push_warning("Math node: '%s' is not a valid number, treating as 0" % value)
	return 0
