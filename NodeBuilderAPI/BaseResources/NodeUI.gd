extends Node2D
class_name NodeUI

#container that holds node items (labels, variable inputs, etc)
@export var NodeItemContainer: Container = null

#must keep track of the data its related to.
@export var SaveData: SavedCodeNode = null
