extends Node
class_name SequenceUI

@export var DataHolder: SequenceData
@export var LeafScene: PackedScene = preload("uid://dno4iwdrkcg8r")
@export var TriggerNodeHolder: CenterContainer
@export var LineManager: LinePool

var TriggerNodeUI: NodeUI

#uid key
var LeafUI: Dictionary[int, LeafContainer]

var CenterLocation: Vector2 = Vector2(0, 0)
var HorizontalSpacing: int = 25
var NodeGap: float = 20.0

#create UI elements from data and place them in dictionary/variables 
func SetUp(SeqName: String) -> void:
	#== ready the environment ==
	if DataHolder != null:
		Clear()
	
	if BotGlobal.DataHolder.Sequences.get(SeqName) == null:
		push_warning("Could not find sequence with name: ", SeqName)
		return
	
	DataHolder = BotGlobal.DataHolder.Sequences.get(SeqName)
	
	#== Set the scene ==
	#trigger Node 
	if DataHolder.TriggerNode == null:
		CreateTriggerPlaceholder()
	else:
		#case where trigger node exists 
		var TempGenericCode: GenericCodeNode = GenericNodeList.GenericList.get(DataHolder.TriggerNode.Name)
		if TempGenericCode == null:
			push_error("Couldn't find ", TempGenericCode.Name, " in GenericList")
			return
		SetTrigger(TempGenericCode.Create(DataHolder.TriggerNode))
	
	#Leafs 
	for ID: int in DataHolder.LeafDict:
		CreateLeafScene(ID)
	
	LeafUI[1].LeafName.text = "Default"
	BuildTree()

#cleans sequenceUI to display a different sequence
func Clear() -> void:
	DataHolder = null
	
	TriggerNodeUI.queue_free()
	
	for leaf in LeafUI:
		LeafUI[leaf].queue_free()
	LeafUI.clear()
	
	LineManager.ClearLines()

#create placeholder trigger
func CreateTriggerPlaceholder() -> void:
	#check if trigger doesn't exist
	if DataHolder.TriggerNode == null:
		 #case where trigger node doesn't exist 
		var TempGenericCode: GenericCodeNode = GenericNodeList.GenericList.get("PlaceHolderTrigger")
		if TempGenericCode == null:
			push_error("Couldn't find ", TempGenericCode.Name, " in GenericList")
			return
		SetTrigger(TempGenericCode.Create(null))

#set trigger
func SetTrigger(NewTrigger: NodeUI) -> void:
	#add trigger to UI and data
	TriggerNodeUI = NewTrigger
	TriggerNodeHolder.add_child(TriggerNodeUI)
	
	DataHolder.SetTriggerNode(NewTrigger.SaveData)
	
	#connect dragged and dragOn signals
	TriggerNodeUI.Dragged.connect(TriggerDragged)
	TriggerNodeUI.DraggedOn.connect(TriggerDraggedOn)

#remove trigger
func RemoveTrigger() -> void:
	#Disconnect signals
	TriggerNodeUI.Dragged.disconnect(TriggerDragged)
	TriggerNodeUI.DraggedOn.disconnect(TriggerDraggedOn)
	
	#delete trigger from ui
	TriggerNodeUI.queue_free()
	TriggerNodeUI = null
	
	#delete trigger from data
	DataHolder.TriggerNode = null


#trigger dragged
func TriggerDragged(Caller: NodeUI) -> void:
	#remove trigger + create placeholder
	RemoveTrigger()
	CreateTriggerPlaceholder()
	
	await get_tree().process_frame
	TriggerNodeHolder.size = Vector2(0,0)
	
	BuildTree()

#trigger dragOn
func TriggerDraggedOn(Caller: NodeUI, Dropped: NodeUI, _LR: bool) -> void:
	#remove trigger + set trigger
	RemoveTrigger()
	SetTrigger(Dropped)
	
	await get_tree().process_frame
	TriggerNodeHolder.size = Vector2(0,0)
	
	BuildTree()

# --- Layout Algorithm ---

# Returns Vector2(upper_extent, lower_extent)
# upper_extent: how far above the node's center the subtree extends (positive value)
# lower_extent: how far below the node's center the subtree extends (positive value)
func _measure_extents(leaf_id: int) -> Vector2:
	var leaf: LeafContainer = LeafUI.get(leaf_id)
	if leaf == null:
		return Vector2(0, 0)
	
	var node_height: float = leaf.size.y if leaf.size.y > 0 else 50.0
	var half_height: float = node_height / 2.0
	
	var leaf_data: LeafData = DataHolder.LeafDict.get(leaf_id)
	if leaf_data == null or leaf_data.EndingNode == null:
		return Vector2(half_height, half_height)
	
	var connector: Connections = leaf_data.EndingNode.GetParam("Connections")
	if connector == null:
		return Vector2(half_height, half_height)
	
	# Calculate how far upper children extend above this node's center
	var upper_extent: float = half_height
	if not connector.Upper.is_empty():
		# Stack upper children above the node
		var cursor: float = half_height + NodeGap
		for i in range(connector.Upper.size() - 1, -1, -1):
			var child_extents: Vector2 = _measure_extents(connector.Upper[i])
			# The child's lower extent faces toward us
			cursor += child_extents.y
			# The child's upper extent faces away
			#var child_top: float = cursor + child_extents.x - child_extents.y
			cursor += child_extents.x
			if i > 0:
				cursor += NodeGap
		upper_extent = cursor - NodeGap + NodeGap  # simplify: just cursor
		# Recalculate properly:
		upper_extent = half_height + NodeGap
		for i in range(connector.Upper.size()):
			var child_extents: Vector2 = _measure_extents(connector.Upper[i])
			var child_total: float = child_extents.x + child_extents.y
			upper_extent += child_total
			if i < connector.Upper.size() - 1:
				upper_extent += NodeGap
	
	# Calculate how far lower children extend below this node's center
	var lower_extent: float = half_height
	if not connector.Lower.is_empty():
		lower_extent = half_height + NodeGap
		for i in range(connector.Lower.size()):
			var child_extents: Vector2 = _measure_extents(connector.Lower[i])
			var child_total: float = child_extents.x + child_extents.y
			lower_extent += child_total
			if i < connector.Lower.size() - 1:
				lower_extent += NodeGap
	
	return Vector2(upper_extent, lower_extent)


func _compute_positions(leaf_id: int, parent_right_x: float, center_y: float, positions: Dictionary) -> void:
	var leaf: LeafContainer = LeafUI.get(leaf_id)
	if leaf == null:
		return
	
	var node_width: float = leaf.size.x if leaf.size.x > 0 else 100.0
	var node_height: float = leaf.size.y if leaf.size.y > 0 else 50.0
	var my_x: float = parent_right_x + HorizontalSpacing
	
	positions[leaf_id] = Vector2(my_x, center_y)
	
	var leaf_data: LeafData = DataHolder.LeafDict.get(leaf_id)
	if leaf_data == null or leaf_data.EndingNode == null:
		return
	
	var connector: Connections = leaf_data.EndingNode.GetParam("Connections")
	if connector == null:
		return
	
	var my_right: float = my_x + node_width
	
	# Place upper children (stack upward from parent)
	if not connector.Upper.is_empty():
		var cursor_y: float = center_y - node_height / 2.0 - NodeGap
		for i in range(connector.Upper.size() - 1, -1, -1):
			var child_extents: Vector2 = _measure_extents(connector.Upper[i])
			# Child's lower extent faces the parent (toward center)
			var child_center: float = cursor_y - child_extents.y
			_compute_positions(connector.Upper[i], my_right, child_center, positions)
			# Move cursor up past the child's upper extent
			cursor_y = child_center - child_extents.x - NodeGap
	
	# Place lower children (stack downward from parent)
	if not connector.Lower.is_empty():
		var cursor_y: float = center_y + node_height / 2.0 + NodeGap
		for i in range(connector.Lower.size()):
			var child_extents: Vector2 = _measure_extents(connector.Lower[i])
			# Child's upper extent faces the parent (toward center)
			var child_center: float = cursor_y + child_extents.x
			_compute_positions(connector.Lower[i], my_right, child_center, positions)
			# Move cursor down past the child's lower extent
			cursor_y = child_center + child_extents.y + NodeGap


# --- Apply positions to UI ---

func _apply_positions(positions: Dictionary) -> void:
	for id: int in positions:
		var leaf: LeafContainer = LeafUI.get(id)
		if leaf == null:
			continue
		
		if leaf.get_parent() == null:
			add_child(leaf)
		
		var pos: Vector2 = positions[id]
		
		#== Snapping behavior ==
		#leaf.global_position = Vector2(
			#pos.x,
			#CenterLocation.y + pos.y - leaf.size.y / 2.0
		#)
		
		#== Tweening behavior ==
		#Get the new location
		var target: Vector2 = Vector2(
			pos.x,
			CenterLocation.y + pos.y - leaf.size.y / 2.0
		)
		
		#Make sure it's not moving already
		if leaf.has_meta("tween"):
			var old_tween = leaf.get_meta("tween")
			if old_tween.is_valid():
				old_tween.kill()
		
		#Move it
		var tween = create_tween()
		leaf.set_meta("tween", tween)
		tween.tween_property(leaf, "global_position", target, 0.3)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_CUBIC)


# --- BuildTree ---

func BuildTree() -> void:
	#add all related scenes into the world
	if TriggerNodeUI.get_parent() == null:
		TriggerNodeHolder.add_child(TriggerNodeUI)
	
	#Leafs - these are added into the world by place leaf
	#remove all of them from world as some could've become unneccessary 
	for ID: int in DataHolder.LeafDict:
		if LeafUI.has(ID) and LeafUI[ID].get_parent() == self:
			remove_child(LeafUI[ID])
	
	#place leafs into world
	for ID: int in LeafUI:
		var leaf: LeafContainer = LeafUI[ID]
		if leaf.get_parent() == null:
			add_child(leaf)
	
	await get_tree().process_frame
	
	#remove leafs from world, we add and remove to force godot to calc leaf size
	for ID: int in LeafUI:
		var leaf: LeafContainer = LeafUI[ID]
		if leaf.get_parent() == self:
			remove_child(leaf)
	
	var root_x: float = CenterLocation.x + TriggerNodeUI.size.x
	
	var positions: Dictionary = {}
	_compute_positions(1, root_x, 0.0, positions)
	
	# DEBUG
	#for id: int in positions:
		#var leaf: LeafContainer = LeafUI.get(id)
		#var pos: Vector2 = positions[id]
		#if leaf != null:
			#var extents: Vector2 = _measure_extents(id)
			#print("ID:", id, " pos:", pos, " size:", leaf.size, " top:", pos.y - leaf.size.y/2.0, " bottom:", pos.y + leaf.size.y/2.0, " extents:", extents)
	#
	_apply_positions(positions)
	
	TriggerNodeHolder.global_position = Vector2(
		positions[1].x - TriggerNodeUI.size.x - 30,
		positions[1].y - (TriggerNodeUI.size.y/2) + LeafUI[1].LeafName.size.y/2)
	
	LineManager.ClearLines()
	ConnectLeafs(1, positions)

#goes through connections and sets leaf names and connects them via line
func ConnectLeafs(leaf: int, LeafPositions: Dictionary) -> void:
	#given leaf
	#update titles for connections
	#draw lines to connections
	var Connector: Connections = LeafUI[leaf].DataHolder.EndingNode.GetParam("Connections")
	if Connector == null:
		return
	
	for upper in Connector.Upper:
		LineManager.RequestLine(LeafPositions[leaf] + Vector2(LeafUI[leaf].size.x/2, 0), LeafPositions[upper])
		LeafUI[upper].LeafName.text = Connector.UpperNames[Connector.Upper.find(upper)]
		ConnectLeafs(upper, LeafPositions)
	
	for lower in Connector.Lower:
		LineManager.RequestLine(LeafPositions[leaf] + Vector2(LeafUI[leaf].size.x/2, 0), LeafPositions[lower])
		LeafUI[lower].LeafName.text = Connector.LowerNames[Connector.Lower.find(lower)]
		ConnectLeafs(lower, LeafPositions)
	
	#call function for each connection again
	pass

# --- Leaf creation ---

#create new leaf for UI
func CreateLeafScene(ID: int) -> LeafContainer:
	if LeafUI.has(ID):
		return LeafUI[ID]
	
	#create the scene
	var NewScene: LeafContainer = LeafScene.instantiate()
	NewScene.DataHolder = DataHolder.LeafDict[ID]
	
	#connect it to propagator
	NewScene.RequestingLeafPropagation.connect(LeafPropagator)
	
	#connect it to the tree builder
	NewScene.RequestTreeRebuild.connect(BuildTree)
	
	#add to dictionary for tracking
	LeafUI[ID] = NewScene
	
	#Load the scene
	NewScene.LoadFromData()
	
	return NewScene


func LeafPropagator(Connector: Connections) -> void:
	for idx: int in range(Connector.Upper.size()):
		if Connector.Upper[idx] == -1:
			#create new leaf in data
			var NewID = DataHolder.CreateLeaf()
			Connector.Upper[idx] = NewID
			
			#load the new leaf in data
			CreateLeafScene(NewID)
			#CreateLeafScene(NewID).LeafName.text = Connector.UpperNames[idx]
	
	for idx: int in range(Connector.Lower.size()):
		if Connector.Lower[idx] == -1:
			var NewID = DataHolder.CreateLeaf()
			Connector.Lower[idx] = NewID
			
			#load the new leaf in data
			CreateLeafScene(NewID)
			#CreateLeafScene(NewID).LeafName.text = Connector.LowerNames[idx]
