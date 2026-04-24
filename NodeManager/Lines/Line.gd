extends Line2D
class_name VisLine

func _ready() -> void:
	pass

func SetPoints(pA: Vector2, pB: Vector2) -> void:
	add_point(pA)
	add_point(Vector2(pA.x, pB.y))
	add_point(pB)

func Clear() -> void:
	clear_points()
