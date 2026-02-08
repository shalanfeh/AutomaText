class_name ModifiedCodeNode
extends Resource

var Name : String

@export var Parameters : Dictionary[String, Variant] = {}

func GetParam(DictKey: String) -> Variant:
	if Parameters.has(DictKey):
		return Parameters[DictKey]
	return null
