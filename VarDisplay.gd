extends Panel
class_name VarDnD

@export var NameLabel: Label
@export var VarEdit: VarEditor
@export var SideButton: Button
@export var PopUp: VarPopUp

var Target = ""


func ReadyUp() -> void:
	ChangeName(Target)
	BotGlobal.VariableRenamed.connect(UpdateIfNeeded)
	
	SideButton.pressed.connect(ToggleVarSettingsPopUp)
	EventBus.CloseAllPopUps.connect(ReleasePopUp)

func UpdateIfNeeded(Targetted: String, New: String) -> void:
	if Target != Targetted:
		return
	ChangeName(New)

func ToggleVarSettingsPopUp() -> void:
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
	NameLabel.text = Target
	PopUp.UpdateTarget(Target)
	VarEdit.SetVar(Target)
