extends Node
class_name LinePool

var Lines: Array[VisLine] = []
var Pointer: int = 0

func _ready() -> void:
	expand(8)

#double in size per expansion if not manually specified
func expand(Amount: int = -1) -> void:
	if Amount > 0:
		for i in range(Amount):
			var NewLine = VisLine.new()
			Lines.append(NewLine)
			add_child(NewLine)
	else:
		for i in range(Lines.size()):
			var NewLine = VisLine.new()
			Lines.append(NewLine)
			add_child(NewLine)

func RequestLine(pA: Vector2, pB: Vector2) -> void:
	#Are there any free lines?
	if (Pointer == Lines.size()):
		expand()
	
	#Take a free line
	var TakenLine = Pointer
	Pointer += 1
	
	#Do something with taken line
	Lines[TakenLine].SetPoints(pA, pB)

func ClearLines() -> void:
	for idx in Lines:
		Lines[idx].Clear()
	Pointer = 0
