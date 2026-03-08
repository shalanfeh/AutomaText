extends Camera2D
class_name PanningCamera2D

const MIN_ZOOM: float = 0.4
const MAX_ZOOM: float = 1.3
const ZOOM_RATE: float = 8.0
const ZOOM_INCREMENT: float = 0.025

var _target_zoom: float = 1

#Handles camera movement with relation to zooming
func _physics_process(delta: float) -> void:
	#Get current mouse position
	var mouse_pos := get_global_mouse_position()
	
	#do the zoom
	zoom = lerp(zoom, _target_zoom * Vector2.ONE, ZOOM_RATE * delta)
	
	#Get the new mouses position AFTER zoom (mouse in world)
	var new_mouse_pos := get_global_mouse_position()
	position += mouse_pos - new_mouse_pos
	
	#clamp position so it doesn't go out of bounds
	position = ClampPosition(position)
	
	#stop doing camera movement
	set_physics_process(not is_equal_approx(zoom.x, _target_zoom))


func ZoomHandler(event: InputEvent) -> void:
	if event is InputEventMagnifyGesture:
		if event.factor > 1:
			zoom_out()
		elif event.factor < 1:
			zoom_in()
		return
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_in()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_out()


func _unhandled_input(event: InputEvent) -> void:
	ZoomHandler(event)
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.double_click:
				focus_position(get_global_mouse_position())
	if event is InputEventMouseMotion and DragHandler.Dragging == false:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			position -= event.relative / zoom
			position = ClampPosition(position)


func zoom_out() -> void:
	_target_zoom = max(_target_zoom - ZOOM_INCREMENT, MIN_ZOOM)
	set_physics_process(true)


func zoom_in() -> void:
	_target_zoom = min(_target_zoom + ZOOM_INCREMENT, MAX_ZOOM)
	set_physics_process(true)

func ClampPosition(TargetPos: Vector2) -> Vector2:
	var Result: Vector2 = Vector2(
		clamp(TargetPos.x, 
			limit_left+get_viewport_rect().size.x/2,limit_right-get_viewport_rect().size.x/2),
		clamp(TargetPos.y, 
			limit_top+get_viewport_rect().size.y/2,limit_bottom-get_viewport_rect().size.y/2)
	)
	return Result

func focus_position(target_position: Vector2) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", ClampPosition(target_position), 0.2)
