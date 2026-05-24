extends Node
class_name Program

signal ProgramStarted
signal ProgramEnded

var CodeToRun: BotData
var CurrentSession: Session

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
	
	Running = true
	ProgramStarted.emit()

func EndProgram() -> void:
	Running = false
	ProgramEnded.emit()

func _physics_process(_delta: float) -> void:
	if Running:
		RunTime.DoCycle()

#session and file handling
func SaveSession() -> void:
	pass

#session and file handling
func LoadSession() -> void:
	pass
