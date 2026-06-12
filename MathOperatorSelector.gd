extends OptionButton
class_name MathOperationSelector

enum Operators {ADD, SUBTRACT, MULTIPLY, DIVIDE}

signal OperatorChanged(Operator: Operators)

func _ready() -> void:
	item_selected.connect(func(idx: int): OperatorChanged.emit(idx as Operators))
