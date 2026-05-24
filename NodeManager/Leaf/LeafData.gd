class_name LeafData
extends Resource

var LineNodes: LineData
var EndingNode: SavedCodeNode

#recognizer in JSON. Assigned by sequence
var UID: int

#set endingNode
func SetEndingNode(NewNode: SavedCodeNode) -> bool:
	var GenericCode: GenericCodeNode = GenericNodeList.GenericList.get(NewNode.Name)
	
	#check if the NewNode is in category "ending"
	if GenericCode != null:
		if GenericCode.Category != GenericCode.Categories.ENDING:
			push_error(NewNode.Name, " Is not an ending node")
			return false #failed, not an ending node
	else:
		push_error(NewNode.Name, " doesn't have a generic node in GenericList")
		return false #failed, no GenericCode
	
	#update the variable
	EndingNode = NewNode
	
	return true

func _init() -> void:
	LineNodes = LineData.new()

func GetNodeFromIndex(idx: int) -> SavedCodeNode:
	if idx >= 0 and idx < LineNodes.NodeSaveList.size():
		return LineNodes.NodeSaveList[idx]
	
	if idx == LineNodes.NodeSaveList.size():
		return EndingNode
	
	return null
