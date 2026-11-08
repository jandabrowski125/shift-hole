extends Node2D
#
@export var target: Node2D

var offset: float = 40.0
var viewport: Rect2
var t_pos: Vector2
var closest_edge_dir: Vector2
var closest_edge_start_node: Vector2
var v_c: Vector2
var pointer_pos: Vector2
var distance: float
var intersection: Vector2
var vp_nodes: Array
var target_angle: float

func _ready():
	hide_pointer()
	#initialize variables
	viewport = target.get_viewport_rect()
	v_c = viewport.get_center()
	vp_nodes = [
		viewport.position, #(0,0)
		Vector2.RIGHT * viewport.size, #(vp.size.x, 0)
		viewport.size, #(size.x, size.y)
		Vector2.DOWN * viewport.size #(0, vp.size.y)
		]
	pass

func _process(delta):
	if is_target_outside_viewport():
		show_pointer()
		intersection = update_pointer_position()
		update_pointer_rotation()
		update_distance_label(intersection)
		return
	hide_pointer()
#
func is_target_outside_viewport() -> bool:
	return not viewport.has_point(target.global_position)
#
func show_pointer():
	visible = true
#
func hide_pointer():
	visible = false
#
func update_pointer_position() -> Vector2:
	t_pos = target.global_position
	target_angle = (target.position-v_c).angle()
	
	#below probably can be optimised, works for now
	if abs(target_angle) > abs((vp_nodes[0] - v_c).angle()):
		#target behind the left edge (defined as topleft corner, going down)
		closest_edge_start_node = vp_nodes[0]
		closest_edge_dir = Vector2.DOWN
	elif target_angle < (vp_nodes[1] - v_c).angle():
		#target behind top edge (topright corner, going right)
		closest_edge_start_node = vp_nodes[1]
		closest_edge_dir = Vector2.RIGHT
	elif target_angle < (vp_nodes[2] - v_c).angle():
		#target behind right edge (bottomright corner, going down)
		closest_edge_start_node = vp_nodes[2]
		closest_edge_dir = Vector2.DOWN
	else:
		#target behind bottom edge (bottomleft corner, going right
		closest_edge_start_node = vp_nodes[3]
		closest_edge_dir = Vector2.RIGHT
	
	pointer_pos = Geometry2D.line_intersects_line(
		v_c, #1st line goes from center 
		t_pos - v_c, #to target (relative to center)
		closest_edge_start_node, #2nd line goes from this node
		closest_edge_dir #in this direction
		)
	self.global_position = pointer_pos.clamp(Vector2(offset,offset), viewport.size - Vector2(offset,offset))
	return pointer_pos
func update_pointer_rotation():
	self.rotate(get_angle_to(target.global_position) - PI)
	
func update_distance_label(intersection: Vector2):
	distance = intersection.distance_to(target.global_position)
	$Label.text = str(int(distance))
