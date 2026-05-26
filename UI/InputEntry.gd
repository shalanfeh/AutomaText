extends HBoxContainer
class_name InputEntry

enum STATES {ADD, RENAME}
enum TARGET {SEQUENCE, VARIABLE}

@export_category("Child Nodes")
@export var EntryBar: LineEdit
@export var SubmitButton: Button
@export var VarOptionButton: OptionButton

@export_category("Values")
@export var State: STATES
@export var Target: TARGET

var RenameTarget: String = ""
var Submitable: bool = false

func _ready() -> void:
	Accepting()
	
	#update placeholder text AND refresh when needed
	if Target == TARGET.SEQUENCE:
		EntryBar.placeholder_text = "Sequence Name"
		BotGlobal.SequenceRemoved.connect(Accepting.unbind(1))
		BotGlobal.SequenceAdded.connect(Accepting.unbind(1))
		BotGlobal.SequenceRenamed.connect(Accepting.unbind(2))
	elif Target == TARGET.VARIABLE:
		EntryBar.placeholder_text = "Variable Name"
		BotGlobal.VariableRemoved.connect(Accepting.unbind(1))
		BotGlobal.VariableAdded.connect(Accepting.unbind(1))
		BotGlobal.VariableRenamed.connect(Accepting.unbind(2))
		
	
	#Hide variable type selector if necessary
	if Target == TARGET.VARIABLE and State != STATES.RENAME:
		for type in BotGlobal.VARTYPES:
			VarOptionButton.add_item(type)
		VarOptionButton.selected = 0
	else:
		VarOptionButton.hide()
	
	#If renaming, connect to signal to update rename target
	if State == STATES.RENAME:
		if Target == TARGET.SEQUENCE:
			BotGlobal.SequenceRenamed.connect(TargetRenamed)
		elif Target == TARGET.VARIABLE:
			BotGlobal.VariableRenamed.connect(TargetRenamed)
		
	#Are we accepting the input?
	EntryBar.text_changed.connect(Accepting.unbind(1))
	
	#submit listening
	SubmitButton.pressed.connect(Submit)
	EntryBar.text_submitted.connect(Submit.unbind(1))
	
	BotGlobal.Refresh.connect(Accepting)



func Accepting() -> void:
	#ban already existing or no entries
	var GivenText: String = EntryBar.text
	if GivenText == "":
		Deny()
		return
	
	match Target:
		TARGET.SEQUENCE:
			if BotGlobal.DataHolder.Sequences.has(GivenText):
				Deny()
				return
		TARGET.VARIABLE:
			if BotGlobal.DataHolder.Variables.has(GivenText):
				Deny()
				return
	
	Accept()


func Deny() -> void:
	Submitable = false
	SubmitButton.self_modulate = Color.LIGHT_CORAL
	pass


func Accept() -> void:
	Submitable = true
	SubmitButton.self_modulate = Color.LIGHT_GREEN
	pass


func Submit() -> void:
	if Submitable == false:
		return
	
	match State:
		STATES.ADD:
			Add()
		STATES.RENAME:
			Rename()
	
	Accepting()


func Add() -> void:
	var GivenText: String = EntryBar.text
	match Target:
		TARGET.SEQUENCE:
			BotGlobal.AddSequence(GivenText)
		TARGET.VARIABLE:
			BotGlobal.AddVariable(GivenText, VarOptionButton.selected)


func Rename() -> void:
	print("RN target: ", RenameTarget)
	var GivenText: String = EntryBar.text
	match Target:
		TARGET.SEQUENCE:
			BotGlobal.RenameSequence(RenameTarget, GivenText)
		TARGET.VARIABLE:
			BotGlobal.RenameVariable(RenameTarget, GivenText)


func TargetRenamed(_OldName: String, NewName: String) -> void:
	RenameTarget = NewName
	Accepting()
