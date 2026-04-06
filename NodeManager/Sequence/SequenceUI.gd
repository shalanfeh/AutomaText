extends Node
class_name SequenceUI

@export var DataHolder: SequenceData
@export var LeafScene: PackedScene = preload("uid://dno4iwdrkcg8r")
@export var TriggerNodeHolder: CenterContainer

var TriggerNodeUI: NodeUI

#uid key
var LeafUI: Dictionary[int, LeafContainer]

var CenterLocation: Vector2 = Vector2(0, 0)
var LineHeight: int = 200
var HorizontalSpacing: int = 25

#create UI elements from data and place them in dictionary/variables
func _ready() -> void:
	if DataHolder == null:
		DataHolder = SequenceData.new()
	
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
		CreateLeafScene(ID)
	
	
	BuildTree()


func PlaceLeaf(LeafID: int, X: int, Y: int):
	var ParentLeaf: LeafContainer = LeafUI.get(LeafID)
	
	#Case where LeafID is nonsense
	if ParentLeaf == null:
		return
	
	#Add leaf to world
	if ParentLeaf.get_parent() == null:
		add_child(ParentLeaf) #fails if already in world
	
	
	#Set the leaf's position
	#ParentLeaf.Resize()
	print("========")
	print("LeafID: ", LeafID)
	print("Supposed to be at: X(", X, "), Y(", Y, ")")
	ParentLeaf.global_position = Vector2(X, Y)
	print("Placed at: X(", ParentLeaf.position.x, "), Y(", ParentLeaf.position.y, ")")
	print("========")
	#ParentLeaf.offset_bottom = 0
	
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
	
	var ChildReservations: int = 1
	
	if Wanted == TARGET.UPPER:
		for ID in Connector.Upper:
			ChildReservations += ReserveSpace(ID, TARGET.UPPER)
		return ChildReservations
	
	for ID in Connector.Lower:
		ChildReservations += ReserveSpace(ID, TARGET.LOWER)
	return ChildReservations

#function that creates UI elements when necessary and places them in the world
func BuildTree() -> void:
	#add all related scenes into the world
	if TriggerNodeUI.get_parent() == null:
		TriggerNodeHolder.add_child(TriggerNodeUI)
	
	#Leafs - these are added into the world by place leaf
	#remove all of them from world as some could've become unneccessary
	for ID: int in DataHolder.LeafDict:
		if LeafUI[ID].get_parent() == self:
			remove_child(LeafUI[ID])
	
	#Place Leafs recursively into world
	#Start from root ID 1
	PlaceLeaf(1, CenterLocation.x + TriggerNodeUI.size.x + HorizontalSpacing, CenterLocation.y)
	
	pass

#create a new leaf for UI purposes
func CreateLeafScene(ID: int) -> LeafContainer:
	if LeafUI.has(ID):
		return LeafUI[ID]
	
	#create the scene
	var NewScene: LeafContainer = LeafScene.instantiate()
	NewScene.DataHolder = DataHolder.LeafDict[ID]
	
	#connect it to the propagator
	NewScene.RequestingLeafPropagation.connect(LeafPropagator)
	
	#connect it to the tree builder
	NewScene.RequestTreeRebuild.connect(BuildTree)
	
	#add it to dictionary for tracking
	LeafUI[ID] = NewScene
	
	#load the scene
	NewScene.LoadFromData()
	
	return NewScene

func LeafPropagator(Connector: Connections) -> void:
	for idx: int in range(Connector.Upper.size()):
		if Connector.Upper[idx] == -1:
			#create a new leaf in the data
			var NewID = DataHolder.CreateLeaf()
			Connector.Upper[idx] = NewID
			
			#load the new leaf in data
			CreateLeafScene(NewID)
	
	for idx: int in range(Connector.Lower.size()):
		if Connector.Lower[idx] == -1:
			var NewID = DataHolder.CreateLeaf()
			Connector.Lower[idx] = NewID
			
			#load the new leaf in data
			CreateLeafScene(NewID)
	
