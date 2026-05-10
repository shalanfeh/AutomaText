extends HBoxContainer
class_name SequenceButton

@export_category("Child Nodes")
@export var MainButton: Button
@export var SideButton: Button
@export var PopUp: SSPopUp

var Target: String = ""

func _ready() -> void:
	PopUp.UpdateTarget(Target)
	SideButton.pressed.connect(ToggleSSPopUp)
	EventBus.CloseAllPopUps.connect(ReleasePopUp)
	
	MainButton.pressed.connect(RequestTab)

func RequestTab() -> void:
	EventBus.CreateSequenceTab.emit(Target)
	pass

func ToggleSSPopUp() -> void:
	var TempHolder: bool = SideButton.button_pressed
	EventBus.CloseAllPopUps.emit()
	
	#take popup slot (or release)
	if TempHolder == true:
		SideButton.set_pressed_no_signal(true)
		PopUp.show()
		return
	SideButton.set_pressed_no_signal(false)
	PopUp.hide()

func ReleasePopUp() -> void:
	if SideButton.button_pressed == true:
		SideButton.set_pressed_no_signal(false)
		PopUp.hide()

func ChangeName(NewName: String) -> void:
	Target = NewName
	MainButton.text = Target
	PopUp.UpdateTarget(Target)
