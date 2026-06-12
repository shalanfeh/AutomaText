extends OptionButton
class_name ConditionalOperatorSelector

enum Operators {EQUAL, UNEQUAL, LESSER, GREATER, LESSER_EQUAL, GREATER_EQUAL}

signal OperatorChanged(Operator: Operators)

func _ready() -> void:
	item_selected.connect(func(idx: int): OperatorChanged.emit(idx as Operators))
