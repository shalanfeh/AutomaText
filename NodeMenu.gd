extends Tree

var BlackList: Array[String] = [
	"PlaceHolderTrigger", 
	"PlaceholderCode",
	"PlaceHolderEnding"]

func _ready() -> void:
	#Create the initial structure
	var Root: TreeItem = create_item()
	var Triggers: TreeItem = create_item(Root)
	var Code: TreeItem = create_item(Root)
	var Endings: TreeItem = create_item(Root)
	
	Triggers.set_text(0, "Triggers")
	Code.set_text(0, "Code")
	Endings.set_text(0, "Endings")
	
	Triggers.set_selectable(0, false)
	Code.set_selectable(0, false)
	Endings.set_selectable(0, false)
	
	#Populate the structure
	var Keys: Array[String] = GenericNodeList.GenericList.keys()
	Keys.sort()
	
	for key: String in Keys:
		#Whats the new entry for
		var Generic: GenericCodeNode = GenericNodeList.GenericList.get(key)
		
		#Find out where the new entry is going to go
		var EndParent: TreeItem
		match Generic.Category:
			Generic.Categories.TRIGGER:
				EndParent = Triggers
			Generic.Categories.CODE:
				EndParent = Code
			Generic.Categories.ENDING:
				EndParent = Endings
		
		#create the entry
		var NewEntry: TreeItem = EndParent.create_child()
		NewEntry.set_text(0, Generic.Name)
		

func _get_drag_data(at_position: Vector2) -> NodeUI:
	var Selected: TreeItem = get_selected()
	if Selected == null:
		return null
	
	DragHandler.Dragging = true
	
	var NewNode: NodeUI = GenericNodeList.GenericList.get(Selected.get_text(0)).Create(null)
	var NicerPreview: CenterContainer = CenterContainer.new()
	NicerPreview.tree_exited.connect(func(): DragHandler.Dragging = false)
	
	NicerPreview.add_child(NewNode)
	
	set_drag_preview(NicerPreview)
	
	#Must create a new one here because the one used for the drag UI will be deleted
	#according to the documentation for set_drag_preview
	return GenericNodeList.GenericList.get(Selected.get_text(0)).Create(null)
