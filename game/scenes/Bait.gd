extends RigidBody

const BULLET_VELOCITY = 0.1

var time_alive = 5
var hit = false
var shoot_dir = Vector3()

onready var camera_base = get_node("/root/root/Player/CameraBase/CameraRot/SpringArm/Camera")
onready var node = get_node("DebugOverlay/DebugControl")

onready var collision_shape = $CollisionShape
onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")

#func _draw():
#	var color = Color(0, 1, 0)
#	var start = camera_base.unproject_position(self.global_transform.origin)#
#	var end = camera_base.unproject_position(self.global_transform.origin + shoot_dir)
#	node.draw_line(start,end, color, 5)
	
	
func _ready():
	var vel = shoot_dir * 2
	self.apply_impulse(transform.origin, vel)
	print(vel)

#func _fixed_process(delta):
	
	
func _physics_process(delta):	
	var bodies = get_colliding_bodies()
	for body in bodies:
		if body.get_name() == "WaterBody":
			self.mode = MODE_STATIC
	#if hit:
	#	return
	#time_alive -= delta
	#if time_alive < 0:
	#	hit = true
		#animation_player.play("explode")	
	#var velocity = ( gravity * 0.2 ) * delta * shoot_dir
	#look_at(transform.origin + velocity.normalized(), Vector3.UP)
	#var col = move_and_collide(velocity)
	#if not col:
	#	print(velocity)
	#if col:
	#	if col.collider and col.collider.has_method("hit"):
	#		col.collider.hit()
	#	collision_shape.disabled = true
	#	#animation_player.play("explode")
	#	hit = true
