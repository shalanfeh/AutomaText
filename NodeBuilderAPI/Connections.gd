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


static func from_dict(data: Dictionary) -> Connections:
	var max_upper: int = int(data.get("MaxUpper", 0))
	var max_lower: int = int(data.get("MaxLower", 0))

	# _init resizes + fills with defaults; we overwrite below.
	var conn := Connections.new(max_upper, max_lower)

	conn.Upper      = _to_int_array(data.get("Upper", []))
	conn.Lower      = _to_int_array(data.get("Lower", []))
	conn.UpperNames = _to_string_array(data.get("UpperNames", []))
	conn.LowerNames = _to_string_array(data.get("LowerNames", []))

	return conn


static func _to_int_array(source: Array) -> Array[int]:
	var result: Array[int] = []
	for v in source:
		result.append(int(v))
	return result


static func _to_string_array(source: Array) -> Array[String]:
	var result: Array[String] = []
	for v in source:
		result.append(str(v))
	return result
