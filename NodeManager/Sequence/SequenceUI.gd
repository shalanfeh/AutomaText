extends Node
class_name SequenceUI

@export var DataHolder: SequenceData
@export var LeafScene: PackedScene = preload("uid://dno4iwdrkcg8r")

var TriggerNodeUI: NodeUI

#uid key
var LeafUI: Dictionary[int, LeafContainer]

var CenterLocation: Vector2 = Vector2(0, 150)
var LineHeight: int = 100
var HorizontalSpacing: int = 25

#create UI elements from data and place them in dictionary/variables
func _ready() -> void:
	#trigger Node
	if DataHolder.TriggerNode == null:
		#case where trigger node doesn't exist
		var TempGenericCode: GenericCodeNode = GenericNodeList.GenericList.get("PlaceHolderTrigger")
		if TempGenericCode == null:
			push_error("Couldn't find ", TempGenericCode.Name, " in GenericList")
			return
		TriggerNodeUI = TempGenericCode.Create(null)
	else:
		#case where trigger node exists
		var TempGenericCode: GenericCodeNode = GenericNodeList.GenericList.get(DataHolder.TriggerNode.Name)
		if TempGenericCode == null:
			push_error("Couldn't find ", TempGenericCode.Name, " in GenericList")
			return
		TriggerNodeUI = TempGenericCode.Create(DataHolder.TriggerNode)
	
	#Leafs
	for ID: int in DataHolder.LeafDict:
		#create the Leaf Container Scene
		var NewScene: LeafContainer = LeafScene.instantiate()
		NewScene.DataHolder = DataHolder.LeafDict[ID]
		NewScene.LoadFromData()
		
		#Add it to the dictionary for tracking
		LeafUI[ID] = NewScene
	
	
	BuildTree()

enum TARGET {UPPER, LOWER}
func ReserveSpace(LeafID: int, Wanted: TARGET) -> int:
	var LeafInfo: LeafData = DataHolder.LeafDict.get(LeafID)
	
	#case where leafID is bad
	if LeafInfo == null:
		return 0
	
	#case where there is no ending node
	if LeafInfo.EndingNode == null:
		return 1
	
	var Connector: Connections = LeafInfo.EndingNode.GetParam("Connections")
	if Connector == null:
		push_error("Couldn't get connections for ending node ", LeafInfo.EndingNode)
		return 1
	
	var ChildReservations: int = 0
	
	if Wanted == TARGET.UPPER:
		for ID in Connector.Upper:
			ChildReservations += ReserveSpace(ID, TARGET.UPPER)
		return ChildReservations
	
	for ID in Connector.Lower:
		ChildReservations += ReserveSpace(ID, TARGET.LOWER)
	return ChildReservations

func PlaceLeaf(LeafID: int, X: int, Y: int):
	var ParentLeaf: LeafContainer = LeafUI.get(LeafID)
	
	#Case where LeafID is nonsense
	if ParentLeaf == null:
		return
	
	#Set the leaf's position
	ParentLeaf.set_position(Vector2(X, Y))
	ParentLeaf.offset_bottom = 0
	
	#Check if the leaf has children
	if ParentLeaf.DataHolder.EndingNode == null:
		return
	
	#Check if it has connections
	var Connector: Connections = ParentLeaf.DataHolder.EndingNode.GetParam("Connections")
	if Connector == null:
		push_error("Connector doesn't have connections in ending node ", ParentLeaf.DataHolder.EndingNode.Name)
		return
	
	for ID in Connector.Upper:
		PlaceLeaf(ID, 
		ParentLeaf.size.x + HorizontalSpacing + X, 
		Y + (ReserveSpace(ID, TARGET.LOWER) * LineHeight)
		)
	
	for ID in Connector.Lower:
		PlaceLeaf(ID, 
		ParentLeaf.size.x + HorizontalSpacing + X, 
		Y - (ReserveSpace(ID, TARGET.UPPER) * LineHeight)
		)
	
	pass

#function that creates UI elements when necessary and places them in the world
func BuildTree() -> void:
	#add all related scenes into the world
	add_child(TriggerNodeUI)
	
	TriggerNodeUI.set_global_position(CenterLocation)
	TriggerNodeUI.offset_bottom = 0
	
	#Leafs
	for ID: int in DataHolder.LeafDict:
		add_child(LeafUI[ID]) #fails if already added
	
	#Place Leafs recursively into world
	#Start from root ID 1
	PlaceLeaf(1, CenterLocation.x + TriggerNodeUI.size.x + HorizontalSpacing, CenterLocation.y)
	
	pass

#for testing purposes
func _init() -> void:
	DataHolder = SequenceData.new()
	
	#SavedCodeNode resource. These will be individual and not shared in
	#an actual scenario. This is a test to see if the UI works
	var PrintNode = SavedCodeNode.new()
	PrintNode.Name = "PrintCode"
	
	var EndingNode = SavedCodeNode.new()
	EndingNode.Name = "RandomizedEnding"
	
	var EndingConnects: Connections = Connections.new(1, 1)
	EndingConnects.Upper[0] = 2
	EndingConnects.Lower[0] = 3
	
	EndingNode.Parameters["Connections"] = EndingConnects
	
	#root leaf
	var Root = DataHolder.CreateLeaf()
	print(Root)
	DataHolder.LeafDict[Root].LineNodes = LineData.new()
	
	DataHolder.CreateLeaf()
	DataHolder.LeafDict[2].LineNodes = LineData.new()
	
	DataHolder.CreateLeaf()
	DataHolder.LeafDict[3].LineNodes = LineData.new()
	
	DataHolder.LeafDict[Root].LineNodes.Insert(PrintNode)
	DataHolder.LeafDict[Root].EndingNode = EndingNode
	
	DataHolder.LeafDict[2].LineNodes.Insert(PrintNode)
	DataHolder.LeafDict[2].LineNodes.Insert(PrintNode)
	DataHolder.LeafDict[2].LineNodes.Insert(PrintNode)
	
	DataHolder.LeafDict[3].LineNodes.Insert(PrintNode)
