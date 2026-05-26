extends VBoxContainer

@export var VarDisplayScene: PackedScene = preload("uid://cpa1fp1f6pwv6")

var DisplayedVars: Dictionary[String, VarDnD] = {}

func _ready() -> void:
	BotGlobal.Refresh.connect(Refreshed)
	BotGlobal.VariableAdded.connect(AddVarDisplay)
	BotGlobal.VariableRemoved.connect(RemoveVarDisplay)
	BotGlobal.VariableRenamed.connect(VarRenamed)

func AddVarDisplay(Target: String) -> void:
	if DisplayedVars.has(Target):
		push_warning("Tried to add displayVar that already exists")
		return
	
	var NewDnD: VarDnD = VarDisplayScene.instantiate()
	NewDnD.Target = Target
	NewDnD.ReadyUp()
	
	DisplayedVars[Target] = NewDnD
	add_child(NewDnD)

func RemoveVarDisplay(Target: String) -> void:
	if !DisplayedVars.has(Target):
		push_warning("Tried to remove displayVar that doesn't exist")
		return
	
	var TargetScene: VarDnD = DisplayedVars.get(Target)
	remove_child(TargetScene)
	DisplayedVars.erase(Target)
	
	TargetScene.queue_free()

func Refreshed() -> void:
	#delete currently existing
	for VarKey: String in DisplayedVars:
		RemoveVarDisplay(VarKey)
	
	#add all that exists in botglobal.dataholder.variables
	for VarKey: String in BotGlobal.DataHolder.Variables:
		AddVarDisplay(VarKey)

func VarRenamed(Target: String, NewName: String) -> void:
	if !DisplayedVars.has(Target):
		push_warning("Renamed Variable doesn't exist in sidebar")
		return
	
	DisplayedVars[NewName] = DisplayedVars[Target]
	DisplayedVars.erase(Target)
	
	DisplayedVars[NewName].ChangeName(NewName)
