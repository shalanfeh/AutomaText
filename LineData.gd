class_name LineData
extends Resource

var NodeSaveList : Array[ModifiedCodeNode] = []

func Insert(NewNode: ModifiedCodeNode, Index: int = -1) -> void:
	#Add at back of line
	if Index <= -1:
		NodeSaveList.append(NewNode)
	
	#Add at specific position of line
	NodeSaveList.insert(Index, NewNode)
