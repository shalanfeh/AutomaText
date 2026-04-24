class_name Connections

#int = LeafID
var Upper: Array[int] = []
var Lower: Array[int] = []

var UpperNames: Array[String] = []
var LowerNames: Array[String] = []

#How many possible connections.
#Will show on tree
var MaxUpper: int
var MaxLower: int

#constructor
func _init(UpperLimit: int, LowerLimit: int):
	MaxUpper = UpperLimit
	MaxLower = LowerLimit
	
	Upper.resize(MaxUpper)
	Lower.resize(MaxLower)
	
	Upper.fill(-1)
	Lower.fill(-1)
	
	UpperNames.resize(MaxUpper)
	LowerNames.resize(MaxLower)
	
	UpperNames.fill("Default")
	LowerNames.fill("Default")
