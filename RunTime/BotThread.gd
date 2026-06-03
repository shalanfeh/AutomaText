#works within the context of the project. Can run multiple sequences.
#A sequence can be called like a function!
class_name BotThread

#Stores global data. Nodes have access to this.
var Heap: Dictionary[Variant, Variant]

#holds array of ExecutionPointers. An executionPointer points to a sequence
var Stack: Array[ExecutionPointer]

#will take in a string that points to a sequence (bot dictionary[string, seq])
#edge-case: cyclic calling -- update: thats a stack overflow
func Push(Sequence: String) -> void:
	Stack.append(ExecutionPointer.new(Sequence))

#Removes the top ExecutionPointer from the stack
func Pop() -> void:
	Stack.pop_back()

func Clear() -> void:
	Heap.clear()
	RunTime.RemoveThread(self)

#presumed run function
#pops a sequence off the stack when 
#executionpointer points to (null, 0) or something
#Pushes a sequence to the stack when node.run returns a string
func Run() -> void:
	#if stack is empty, remove self from scheduler
	if Stack.size() == 0:
		Clear()
		return
	
	#take ptr ontop of stack
	var Target: ExecutionPointer = Stack.back()
	
	#if ptr points to non-existent sequence, pop
	var Sequence: SequenceData = Prg.CodeToRun.Sequences.get(Target.Sequence)
	while Sequence == null:
		push_error("Couldn't not find sequence named: ", Target.Sequence)
		
		Pop()
		if Stack.size() == 0:
			Clear()
			return
		
		Target = Stack.back()
		Sequence = Prg.CodeToRun.Sequences.get(Target.Sequence)
	
	
	#if ptr points to non-existent leaf in sequence, pop
	var Leaf: LeafData = Sequence.LeafDict.get(Target.leaf)
	if Leaf == null:
		push_error("Couldn't not find leaf (", Target.leaf,
		 ") in sequence named: ", Target.Sequence)
		
		Pop()
		if Stack.size() == 0:
			Clear()
			return
	
	
	var SNC: SavedCodeNode = null
	
	#run the trigger if need be
	if Target.RanTrigger == false:
		SNC = Sequence.TriggerNode
		Target.RanTrigger = true
	else:
		SNC = Leaf.GetNodeFromIndex(Target.index)
		Target.index += 1
	
	#if the returned savednodecode is null, pop
	if SNC == null:
		Pop()
		if Stack.size() == 0:
			Clear()
		return
	
	#valid savednodecode atp
	#get the genericcode and run()
	var GNC: GenericCodeNode = GenericNodeList.GenericList.get(SNC.Name)
	if GNC == null:
		push_error("Could not find SavedNodeCode name in GenericCode: ", SNC.Name)
	else:
		GNC.Run(self, Target, SNC)
