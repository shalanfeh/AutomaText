#Works within the context of a sequence. Holds leaf and array position.
class_name ExecutionPointer

#the sequence the exeuction pointer is for.
#The bot class will hold a dictionary[string, sequence].
#The json handler will need to be string keys
var Sequence: String

#leaf, position

#null for now, leaf class not created
var leaf = null

#index within leaf. 0 = line.0. end of line + 1 = ending of leaf
var index: int = 0
