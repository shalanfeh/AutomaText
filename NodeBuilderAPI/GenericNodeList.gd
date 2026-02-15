extends Node

var GenericNodeDirectoryPath: String = "res://NodeBuilderAPI/GenericNodeCodes/"

#global way of accessing generic node uid's through strings
var GenericList: Dictionary[String, GenericCodeNode]

#inserts generic nodes into the list. Called from generic _init
func Insert(Name: String, Generic: GenericCodeNode):
	if GenericList.find_key(Name):
		push_warning("Found duplicate of key: " + Name + " in GenericNodeList.
		Removed 1 for the other.")
	GenericList[Name] = Generic


#loads all the generic nodes in the folder "GenericNodeCodes"
func LoadAllGenerics(path: String) -> void:
	var Directory: DirAccess = DirAccess.open(path)
	if Directory:
		Directory.list_dir_begin()
		var FileName = Directory.get_next()
		while FileName != "":
			if Directory.current_is_dir():
				continue
			ResourceLoader.load(path + FileName)
			FileName = Directory.get_next()
	else:
		push_error("Invalid file path for GenericNodeDirectoryPath: " + path)

func _ready() -> void:
	LoadAllGenerics(GenericNodeDirectoryPath)
