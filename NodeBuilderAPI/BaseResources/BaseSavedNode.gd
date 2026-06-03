class_name SavedCodeNode
extends Resource

#name of the genericNode. Lines up with genericNodeList
var Name : String

@export var Parameters : Dictionary[String, Variant] = {}
@export var VarParameters: Dictionary[String, String] = {}

func GetParam(DictKey: String) -> Variant:
	#check if it's pointing to a variable
	if VarParameters.has(DictKey):
		if Prg.CurrentSession.Variables.get(VarParameters[DictKey]):
			return Prg.CurrentSession.Variables.get(VarParameters[DictKey]).Value
	
	#check if it has it saved
	if Parameters.has(DictKey):
		return Parameters[DictKey]
	
	#if it's connections MAKE IT TO AVOID CYCLYC CALLING
	if DictKey == "Connections":
		#push_warning("Had to make connections to avoid circular calling in ", Name)
		Parameters["Connections"] = Connections.new(0, 0)
	
	#if not, get the generic one
	var Generic: GenericCodeNode = GenericNodeList.GenericList.get(Name)
	if Generic == null:
		push_error("Could not find ", Name, "In GenericNodeList")
	
	return Generic.Parameters.get(DictKey)

func IsVariable(DictKey: String) -> bool:
	return VarParameters.keys().has(DictKey)
