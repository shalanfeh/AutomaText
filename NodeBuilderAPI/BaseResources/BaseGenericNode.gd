@abstract 
class_name GenericCodeNode
extends Resource

enum Categories {CODE, ENDING, TRIGGER}

#name equivalent in GenericNodeList
@export var Name : String
@export var Category : Categories = Categories.CODE

@export var Parameters : Dictionary[String, Variant] = {}

#Needs to take in an execution pointer object for updating
#Context contains thread related variables and stack
#SaveData contains the parameters and variable changed for this node
@abstract func Run(Context: BotThread, Pointer: ExecutionPointer, SaveData: SavedCodeNode) -> void

#takes in a savedNode to build the node with customized parameters
@abstract func Create(Modifications: SavedCodeNode = null) -> NodeUI

#adds resource into GenericNodeList
func _init() -> void:
	GenericNodeList.Insert(Name, self)
