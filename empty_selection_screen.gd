extends Panel
class_name HomeMenu

func _ready() -> void:
	EventBus.OpenHomeScreen.connect(ShowSelf)
	EventBus.TabSelected.connect(HideSelf.unbind(1))

func HideSelf() -> void:
	EventBus.HomeShowing = false
	hide()

func ShowSelf() -> void:
	EventBus.HomeShowing = true
	show()
