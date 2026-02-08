@abstract 
class_name GenericCodeNode
extends Resource

@export var Name : String

@export var Parameters : Dictionary[String, Variant] = {}

@abstract func Run() -> void
@abstract func Create(Modifications: ModifiedCodeNode = null) -> PanelContainer
