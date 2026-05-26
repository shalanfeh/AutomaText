extends PanelContainer
class_name VarPopUp

@export var EntryInput: InputEntry
@export var DeleteButton: Button
@export var Target: String = ""

func _ready() -> void:
	DeleteButton.pressed.connect(DeleteClicked)

func DeleteClicked() -> void:
	BotGlobal.RemoveVariable(Target)

func UpdateTarget(NewTarget: String) -> void:
	Target = NewTarget
	EntryInput.RenameTarget = Target
