extends Node

#Holds a list of paths to NodeUIDHolder resources, identified by name
@export var GenericUIDlists: Dictionary[String, String] = {
	"Base" = "uid://bul3yfp5hlm3o"
}

#global way of accessing generic node uid's through strings
var GenericList: Dictionary[String, GenericCodeNode]

#inserts generic nodes into the list. Called from generic _init
func Insert(Name: String, Generic: GenericCodeNode):
	if GenericList.has(Name):
		push_warning("Found duplicate of key: " + Name + " in GenericNodeList.
		Removed 1 for the other.")
	GenericList[Name] = Generic


#Loads a generic node from a file. Returns success or failure
func LoadGenericFromFile(path: String) -> bool: 
	var ResourceFromFile: Resource = load(path)
	if ResourceFromFile == null:
		push_error("Failed to load resource from file - " + path)
		return false
	
	ResourceFromFile.new()
	return true


func LoadGenericFromLists():
	for key in GenericUIDlists:
		var list_path = GenericUIDlists[key]
		
		if list_path == "":
			push_warning("Skipping empty path for key: " + key)
			continue
		
		var list = load(list_path)
		if list == null:
			push_warning("Failed to load list resource for key: " + key)
			continue
		
		for uid in list.UIDList:
			if not LoadGenericFromFile(uid):
				push_warning("Failed to load generic from: " + uid)


func _ready() -> void:
	LoadGenericFromLists()

#DEPRECIATED - Does not work on exported versions :(
#loads all the generic nodes in the folder "GenericNodeCodes"
#func LoadAllGenerics(path: String) -> void:
	#var Directory: DirAccess = DirAccess.open(path)
	#if Directory:
		#Directory.list_dir_begin()
		#var FileName = Directory.get_next()
		#while FileName != "":
			#if Directory.current_is_dir():
				#FileName = Directory.get_next()
				#continue
			##uid files
			#if FileName.ends_with(".gd"):
				#load(path + FileName).new()
			#
			#FileName = Directory.get_next()
	#else:
		#push_error("Invalid file path for GenericNodeDirectoryPath: " + path)
