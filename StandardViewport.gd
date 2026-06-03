extends Control
class_name StandardViewport

@export var MessageContainer: PackedScene = preload("uid://p0fbbv8um5w1")

@export var TextEntry: LineEdit
@export var MessageHolder: VBoxContainer
@export var ScrollHolder: ScrollContainer

signal TextEntered(EnteredText: String)

func _ready() -> void:
	TextEntry.text_submitted.connect(EnterPressed)

func EnterPressed(submitted_text: String) -> void:
	TextEntered.emit(submitted_text)
	TextEntry.clear()

func CreateMsg(Sender: String, Content: String) -> void:
	var NewMsg: MsgContainer = MessageContainer.instantiate()
	NewMsg.SetContent(Sender, Content)
	MessageHolder.add_child(NewMsg)
	ScrollHolder.set_deferred("scroll_vertical", ScrollHolder.get_v_scroll_bar().max_value)

func ClearMessages() -> void:
	for child in MessageHolder.get_children():
		child.queue_free()
