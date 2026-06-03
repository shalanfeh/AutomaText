extends Node
class_name Program

signal ProgramStarted
signal ProgramEnded

var CodeToRun: BotData
var CurrentSession: Session

var CreatedViewport: ProgramWindow = null

var Running: bool = false

#if no current session, make new session from current bot
func StartProgram() -> void:
	if CodeToRun == null:
		push_error("Tried to run nothing")
		return
	
	var CreatedNewSession: bool = false
	
	if CurrentSession == null:
		CreatedNewSession = true
		CurrentSession = Session.new()
		CurrentSession.Name = CodeToRun.Name
		CurrentSession.Variables = CodeToRun.Variables.duplicate(true)
		CurrentSession.ViewPort = preload("uid://bf14qlesj1c63").instantiate()
	
	RunTime.ActiveThreads = CurrentSession.ActiveThreads
	RunTime.ThreadsToAdd = CurrentSession.ThreadsToAdd
	RunTime.ThreadsToRemove = CurrentSession.ThreadsToRemove
	
	if CreatedNewSession:
		for SeqKey: String in CodeToRun.Sequences:
			var SNC: SavedCodeNode = CodeToRun.Sequences[SeqKey].TriggerNode
			if SNC == null:
				continue
			
			var GNC: GenericCodeNode = GenericNodeList.GenericList.get(SNC.Name)
			if GNC == null:
				push_error("Could not find SavedNodeCode name in GenericCode: ", SNC.Name)
			else:
				GNC.OnProgramStart(SeqKey)
	
	CreatedViewport = preload("uid://e5164m1to1xg").instantiate()
	CreatedViewport.add_child(CurrentSession.ViewPort)
	get_tree().current_scene.add_child(CreatedViewport)
	
	Running = true
	ProgramStarted.emit()

func EndProgram() -> void:
	CreatedViewport.CloseWindow()
	CreatedViewport.queue_free()
	CreatedViewport = null
	
	Running = false
	ProgramEnded.emit()

func _physics_process(_delta: float) -> void:
	if Running:
		RunTime.DoCycle()

#session and file handling
func SaveSession(FilePath: String) -> void:
	var Success: bool = ForgeJSONGD.store_json_file(FilePath, ForgeJSONGD.class_to_json(CurrentSession))
	if !Success:
		push_error("Failed to save data")

#session and file handling
func LoadSession(FilePath: String) -> void:
	var ImportedData: Session = ForgeJSONGD.json_file_to_class(Session, FilePath)
	if ImportedData:
		CurrentSession = ImportedData
	else:
		push_error("Failed to load data")
