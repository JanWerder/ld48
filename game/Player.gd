extends KinematicBody

onready var player_model = $PlayerModel
onready var player = $Player
onready var camera_base = $CameraBase
onready var animation_tree = $AnimationTree
onready var camera_rot = camera_base.get_node(@"CameraRot")
onready var camera_spring_arm = camera_rot.get_node(@"SpringArm")
onready var camera_camera = camera_spring_arm.get_node(@"Camera")

var orientation = Transform()
var root_motion = Transform()
var motion = Vector2()
var velocity = Vector3()

const CAMERA_MOUSE_ROTATION_SPEED = 0.001
const CAMERA_CONTROLLER_ROTATION_SPEED = 3.0
const MOTION_INTERPOLATE_SPEED = 10
const CAMERA_X_ROT_MIN = -40
const CAMERA_X_ROT_MAX = 30
const ROTATION_INTERPOLATE_SPEED = 10
const SPEED = 5

onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")
var camera_x_rot = 0.0

var is_fishing = false

func _init():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _ready():
	orientation = player_model.global_transform
	orientation.origin = Vector3()

func _physics_process(delta):
	var camera_move = Vector2(
			Input.get_action_strength("view_right") - Input.get_action_strength("view_left"),
			Input.get_action_strength("view_up") - Input.get_action_strength("view_down"))
	var camera_speed_this_frame = delta * CAMERA_CONTROLLER_ROTATION_SPEED
	
	rotate_camera(camera_move * camera_speed_this_frame)
	
	var motion_target = Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_back") - Input.get_action_strength("move_forward"))
	motion = motion.linear_interpolate(motion_target, MOTION_INTERPOLATE_SPEED * delta)

	var camera_basis = camera_rot.global_transform.basis
	var camera_z = camera_basis.z
	var camera_x = camera_basis.x

	camera_z.y = 0
	camera_z = camera_z.normalized()
	camera_x.y = 0
	camera_x = camera_x.normalized()
	

	var target = camera_x * motion.x + camera_z * motion.y
	if target.length() > 0.001:
		var q_from = orientation.basis.get_rotation_quat()
		var q_to = Transform().looking_at(target, Vector3.UP).basis.get_rotation_quat()
		# Interpolate current rotation with desired one.
		orientation.basis = Basis(q_from.slerp(q_to, delta * ROTATION_INTERPOLATE_SPEED))
	
	#var h_velocity = Transform.IDENTITY.origin / delta
	velocity.x = -motion.x * SPEED
	velocity.z = -motion.y * SPEED
	velocity += gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP)
	
	root_motion = animation_tree.get_root_motion_transform()
	orientation *= root_motion
	
	orientation.origin = Vector3() # Clear accumulated root motion displacement (was applied to speed).	
	orientation = orientation.orthonormalized() # Orthonormalize orientation.

	player_model.global_transform.basis = orientation.basis
	
	if not is_fishing and Input.is_action_just_pressed("fish"):
		var shoot_origin = player_model.global_transform.origin
		var ray_from = camera_camera.project_ray_origin(Vector2(0,0))
		var ray_dir = camera_camera.project_ray_normal(Vector2(0,0))
		
		var shoot_target
		var col = get_world().direct_space_state.intersect_ray(ray_from, ray_from + ray_dir * 1000, [self], 0b11)
		if col.empty():
			shoot_target = ray_from + ray_dir * 1000
		else:
			shoot_target = col.position
		var shoot_dir = (shoot_target - shoot_origin).normalized()
		
		var bullet = preload("res://scenes/Bait.tscn").instance()				
		bullet.global_transform.origin = shoot_origin + Vector3(0,3,0)
		var dvel = velocity + Vector3(0,2,0)
		print("vel", dvel)
		bullet.shoot_dir = dvel
		get_parent().add_child(bullet)
		bullet.look_at(dvel, Vector3.UP) #shoot_origin + shoot_dir
		bullet.add_collision_exception_with(player)

func rotate_camera(move):
	camera_base.rotate_y(-move.x)
	camera_base.orthonormalize()
	camera_x_rot += move.y
	camera_x_rot = clamp(camera_x_rot, deg2rad(CAMERA_X_ROT_MIN), deg2rad(CAMERA_X_ROT_MAX))
	camera_rot.rotation.x = camera_x_rot
