class_name LineData
extends Resource

var NodeSaveList : Array[SavedCodeNode] = []

func Insert(NewNode: SavedCodeNode, Index: int = -1) -> void:
	#Add at back of line
	if Index <= -1:
		NodeSaveList.append(NewNode)
		return
	
	#Add at specific position of line
	NodeSaveList.insert(Index, NewNode)

func Remove(TargetNode: SavedCodeNode) -> void:
	var Idx: int = NodeSaveList.find(TargetNode)
	if Idx != -1:
		NodeSaveList.remove_at(Idx)
