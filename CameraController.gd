extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var camera = $Camera

const speed = .2
const ray_length = 500
var velocity = Vector3(0,0,0)
var environ_collision_mask = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#base camera controls
	# Zoom in and out
	if Input.is_action_just_released("ui_zoom_in"):
		camera.translate(Vector3(0,0,-1))
	
	if Input.is_action_just_released("ui_zoom_out"):
		camera.translate(Vector3(0,0,1))
	
	# Pan around
	if Input.is_action_pressed("ui_up"):
		velocity.z -= speed
	
	if Input.is_action_pressed("ui_down"):
		velocity.z += speed
	
	if Input.is_action_pressed("ui_right"):
		velocity.x += speed
		
	if Input.is_action_pressed("ui_left"):
		velocity.x -= speed
	
	global_translate(velocity)
	velocity.x = 0
	velocity.z= 0

func _physics_process(delta):
	
	if Input.is_action_just_pressed("ui_move_click"):
		var mouse_pos : Vector2 = get_viewport().get_mouse_position()
		move_all_units(mouse_pos)
			
#		print("clicked position %s" % clicked_pos )
		


func get_mouse_raycast_collision_coords(mouse_pos, collision_mask):
	var space_state = get_world().direct_space_state
	var ray = raycast_from_mouse(mouse_pos)
	var ray_start = ray[0]
	var ray_end = ray[1]
	
	var result: Dictionary = space_state.intersect_ray(ray_start, ray_end,
							[self], collision_mask)
	
	if result.size() > 0: #catch nonmap click
		return result["position"]
	else:
		return null

"""
Performs a raycast from mouse position.
Returns an array of [start_ray position, end_ray_position]
"""
func raycast_from_mouse(mouse_pos: Vector2) -> Array:
	var ray_origin: Vector3 = camera.project_ray_origin(mouse_pos)
	var ray_end: Vector3 = ray_origin + camera.project_ray_normal(mouse_pos) * ray_length 
	
	return [ray_origin, ray_end]
	
func move_all_units(mouse_pos: Vector2):
	var clicked_pos = get_mouse_raycast_collision_coords(mouse_pos, environ_collision_mask)
	if clicked_pos == null:
		#invalid click
		return
	print("clicked position ", clicked_pos)
	get_tree().call_group("units","move_to", clicked_pos)
#
