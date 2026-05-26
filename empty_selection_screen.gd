extends Panel
class_name HomeMenu

@export var ImportButton: Button
@export var ExportButton: Button
@export var ImportPopUp: FileDialog
@export var ExportPopUp: FileDialog

func _ready() -> void:
	EventBus.OpenHomeScreen.connect(ShowSelf)
	EventBus.TabSelected.connect(HideSelf.unbind(1))
	ImportButton.pressed.connect(ToggleImport)
	ExportButton.pressed.connect(ToggleExport)
	ImportPopUp.file_selected.connect(BotGlobal.Import)
	ExportPopUp.file_selected.connect(BotGlobal.Export)

func HideSelf() -> void:
	EventBus.HomeShowing = false
	hide()

func ShowSelf() -> void:
	EventBus.HomeShowing = true
	show()

func ToggleImport() -> void:
	if ImportPopUp.visible:
		ImportPopUp.hide()
	else:
		ImportPopUp.show()

func ToggleExport() -> void:
	if ExportPopUp.visible:
		ExportPopUp.hide()
	else:
		ExportPopUp.show()
