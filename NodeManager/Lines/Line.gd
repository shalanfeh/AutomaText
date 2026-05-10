extends Line2D
class_name VisLine

func _ready() -> void:
	default_color = Color.BLACK
	width = 8
	joint_mode = Line2D.LINE_JOINT_ROUND
	begin_cap_mode = Line2D.LINE_CAP_ROUND
	end_cap_mode = Line2D.LINE_CAP_ROUND
	z_index = -10
	pass

func SetPoints(pA: Vector2, pB: Vector2) -> void:
	add_point(pA)
	add_point(Vector2(pA.x, pB.y))
	add_point(pB)

func Clear() -> void:
	clear_points()
