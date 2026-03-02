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
	pass

#will take in a string that points to a sequence (bot dictionary[string, seq])
func Pop(Sequence: String) -> void:
	pass

#presumed run function
#pops a sequence off the stack when 
#	executionpointer points to (null, 0) or something
#Pushes a sequence to the stack when node.run returns a string
