#Global
extends Node
class_name BotHandler

#=== enums ===
enum VARTYPES {STRING, INT, FLOAT, BOOLEAN}

#=== variables ===
var DataHolder: BotData = BotData.new()

#=== signals ===
signal Refresh

signal VariableAdded(VarName: String)
signal VariableRemoved(VarName: String)
signal VariableRenamed(Target: String, NewName: String)

signal SequenceAdded(SeqName: String)
signal SequenceRemoved(SeqName: String)
signal SequenceRenamed(Target: String, NewName: String)

#=== functions ===
#Adds a variable to the dataholder
func AddVariable(VarName: String, VarType: VARTYPES) -> void:
	#check if variable already exists
	if DataHolder.Variables.has(VarName):
		return
	
	#add variable to dataholder variables dictionary
	var NewVar: BotVariable = BotVariable.new()
	NewVar.Type = VarType
	NewVar.Value = GetDefaultValue(VarType)
	DataHolder.Variables[VarName] = NewVar
	
	#emit variableadded signal
	VariableAdded.emit(VarName)


#removes a variable from the dataholder
func RemoveVariable(VarName: String) -> void:
	#check if variable exists, if not return
	if not DataHolder.Variables.has(VarName):
		return
		
	#remove variable from dataholder variables dictionary
	DataHolder.Variables.erase(VarName)
	
	#emit variableremoved signal
	VariableRemoved.emit(VarName)


#renames a variable in the dataholder
func RenameVariable(VarName: String, NewVarName: String) -> void:
	#check if variable exists, if not return
	if not DataHolder.Variables.has(VarName):
		return
		
	#check if new name is already taken, if so return
	if DataHolder.Variables.has(NewVarName):
		return
	
	#move variable to new key and erase the old one
	DataHolder.Variables[NewVarName] = DataHolder.Variables[VarName]
	DataHolder.Variables.erase(VarName)
	
	#emit variablerenamed signal
	VariableRenamed.emit(VarName, NewVarName)


#adds a sequence in the dataholder
func AddSequence(SeqName: String) -> void:
	#check if sequence already exists, if so return
	if DataHolder.Sequences.has(SeqName):
		return
	
	#add sequence to dataholder sequences dictionary
	DataHolder.Sequences[SeqName] = SequenceData.new()
	
	#emit sequenceadded signal
	SequenceAdded.emit(SeqName)


#removes a sequence in the dataholder
func RemoveSequence(SeqName: String) -> void:
	#check if sequence exists, if not return
	if not DataHolder.Sequences.has(SeqName):
		return
	
	#remove sequence from dataholder sequences dictionary
	DataHolder.Sequences.erase(SeqName)
	
	#emit sequenceremoved signal
	SequenceRemoved.emit(SeqName)


#renames a sequence in the dataholder
func RenameSequence(SeqName: String, NewSeqName: String) -> void:
	print(SeqName, "...")
	#check if sequence exists, if not return
	if not DataHolder.Sequences.has(SeqName):
		return
	
	#check if new name is already taken, if so return
	if DataHolder.Sequences.has(NewSeqName):
		return
	
	#move sequence to new key and erase the old one
	DataHolder.Sequences[NewSeqName] = DataHolder.Sequences[SeqName]
	DataHolder.Sequences.erase(SeqName)
	
	#emit sequencerenamed signal
	SequenceRenamed.emit(SeqName, NewSeqName)


#=== JSON Handling ===
func Import() -> void:
	Refresh.emit()
	pass

func Export() -> void:
	Refresh.emit()
	pass


#=== helper functions ===

func PrintContents() -> void:
	print(ForgeJSONGD.class_to_json_string(DataHolder))
	print("==============")
	
	print("~~ Variables ~~ ")
	for Variable: String in DataHolder.Variables:
		print(Variable, ": ", DataHolder.Variables[Variable].Value, " - ", DataHolder.Variables[Variable].Type)
	
	print("\n\n~~ Sequences ~~ ")
	for Sequence: String in DataHolder.Sequences:
		print("-", Sequence)
		
		if DataHolder.Sequences[Sequence].TriggerNode == null:
			print("--Trigger: null")
		else:
			print("--Trigger: ", DataHolder.Sequences[Sequence].TriggerNode.Name)
		
		print("--Leafs")
		var Leafs: Dictionary[int, LeafData] = DataHolder.Sequences[Sequence].LeafDict
		for Leaf: int in Leafs:
			print("---", Leaf)
			
			if Leafs[Leaf].EndingNode == null:
				print("----Ending: null")
			else:
				print("----Ending: ", Leafs[Leaf].EndingNode.Name)
			
			print("----LineData")
			for SCN: SavedCodeNode in Leafs[Leaf].LineNodes.NodeSaveList:
				print("-----Node: ", SCN.Name)
		print("\n")
	
	print("==============")
	pass

#returns the default value for a given variable type
func GetDefaultValue(VarType: VARTYPES) -> Variant:
	match VarType:
		VARTYPES.STRING:
			return ""
		VARTYPES.INT:
			return 0
		VARTYPES.FLOAT:
			return 0.0
		VARTYPES.BOOLEAN:
			return false
	return null
