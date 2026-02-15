class_name SavedCodeNode
extends Resource

#name of the genericNode. Lines up with genericNodeList
var Name : String

@export var Parameters : Dictionary[String, Variant] = {}

func GetParam(DictKey: String) -> Variant:
	if Parameters.has(DictKey):
		return Parameters[DictKey]
	return null
