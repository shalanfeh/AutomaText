@abstract 
class_name GenericCodeNode
extends Resource

enum Categories {CODE, ENDING, TRIGGER}
enum DragOnBehaviors {DEFAULT, PLACE, REPLACE}

#name equivalent in GenericNodeList
@export var Name : String

#Behavioral variables
@export var Category : Categories = Categories.CODE
@export var DragOnOverride : DragOnBehaviors = DragOnBehaviors.DEFAULT

@export var Parameters : Dictionary[String, Variant] = {}

#Needs to take in an execution pointer object for updating
#Context contains thread related variables and stack
#SaveData contains the parameters and variable changed for this node
@abstract func Run(Context: BotThread, Pointer: ExecutionPointer, SaveData: SavedCodeNode) -> void

#takes in a savedNode to build the node with customized parameters
@abstract func Create(Modifications: SavedCodeNode = null) -> NodeUI

#fired by the program upon start
func OnProgramStart(SeqName: String) -> void:
	pass

#Returns drag-on behavior. Required to handle default behavior
func GetDragOnBehavior() -> DragOnBehaviors:
	if DragOnOverride == DragOnBehaviors.DEFAULT:
		if Category == Categories.CODE:
			return DragOnBehaviors.PLACE
		else:
			return DragOnBehaviors.REPLACE
	
	return DragOnOverride

#adds resource into GenericNodeList
func _init() -> void:
	GenericNodeList.Insert(Name, self)
	
	#category specific default parameters
	#this causes a cyclic error lmfao
	if Category == Categories.ENDING:
		if Parameters.get("Connections") == null:
			Parameters["Connections"] = Connections.new(0, 0)
