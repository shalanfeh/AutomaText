class_name SequenceData
extends Resource

var LeafUIDCounter: int = 0

var TriggerNode: SavedCodeNode

var LeafDict: Dictionary[int, LeafData] = {}

#used to assign UID's to leaf's
func GetLeafUID() -> int:
	LeafUIDCounter += 1
	return LeafUIDCounter

#inserts a new leaf into the dictionary.
#returns Leaf UID
func CreateLeaf() -> int:
	#get the UID
	var UID = GetLeafUID()
	
	#Create the leaf resource
	var Data = LeafData.new()
	Data.UID = UID
	
	#put it in the dictionary
	LeafDict[UID] = Data
	
	return UID

#set TriggerNode
func SetTriggerNode(NewNode: SavedCodeNode) -> bool:
	var GenericCode: GenericCodeNode = GenericNodeList.GenericList.get(NewNode.Name)
	
	#check if the NewNode is in category "trigger"
	if GenericCode != null:
		if GenericCode.Category != GenericCode.Categories.TRIGGER:
			push_warning(NewNode.Name, " Is not a trigger node")
			return false #failed, not a trigger node
	else:
		push_warning(NewNode.Name, " doesn't have a generic node in GenericList")
		return false #failed, no GenericCode
	
	#update the variable
	TriggerNode = NewNode
	
	return true

func _init() -> void:
	CreateLeaf()
