extends PanelContainer
class_name LeafContainer

@export var HBox: HBoxContainer
@export var LineUI:  LineContainer
var EndingUI: NodeUI

@export var DataHolder: LeafData

#loads leaf data into the UI
func LoadFromData():
	#Create ending node scene
	if DataHolder.EndingNode == null:
		#case where Ending node doesn't exist
		var TempGenericCode: GenericCodeNode = GenericNodeList.GenericList.get("PlaceHolderEnding")
		if TempGenericCode == null:
			push_error("Couldn't find ", TempGenericCode.Name, " in GenericList")
			return
		EndingUI = TempGenericCode.Create(null)
	else:
		#case where Ending node exists
		var TempGenericCode: GenericCodeNode = GenericNodeList.GenericList.get(DataHolder.EndingNode.Name)
		if TempGenericCode == null:
			push_error("Couldn't find ", TempGenericCode.Name, " in GenericList")
			return
		EndingUI = TempGenericCode.Create(DataHolder.EndingNode)
	
	#add ending node to container
	HBox.add_child(EndingUI)
	
	#Align LineUI to the correct data
	LineUI.DataHolder = DataHolder.LineNodes
	
	#load the LineUI using the data
	LineUI.DataToUi()
	pass

#--- post poned until testing is possible ---
#handle the setting of the ending node through UI interaction

#handle the drag and drop behavior with respect to the ending node

#handle deletion
