extends PanelContainer
class_name MsgContainer

@export var SenderLabel: RichTextLabel
@export var ContentLabel: Label

func SetContent(Sender: String, Content: String) -> void:
	SenderLabel.text = "[b] " + Sender
	ContentLabel.text = Content
	pass
