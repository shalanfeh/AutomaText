class_name Connections

#int = LeafID
var Upper: Array[int] = []
var Lower: Array[int] = []

#How many possible connections.
#Will show on tree
var MaxUppper: int
var MaxLower: int

#constructor
func _init(UpperLimit: int, LowerLimit: int):
	MaxUppper = UpperLimit
	MaxLower = LowerLimit
	
	Upper.resize(MaxUppper)
	Lower.resize(MaxLower)
	
	Upper.fill(-1)
	Lower.fill(-1)
