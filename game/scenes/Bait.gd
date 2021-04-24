extends RigidBody

const BULLET_VELOCITY = 0.1

var time_alive = 5
var hit = false
var shoot_dir = Vector3()
	
func _ready():
	var vel = shoot_dir * 2
	self.apply_impulse(transform.origin, vel)
	#print(vel)

#func _fixed_process(delta):
	
	
func _physics_process(delta):	
	var bodies = get_colliding_bodies()
	for body in bodies:
		if body.get_name() == "WaterBody":
			#print(body.get_name())
			#self.set_axis_lock(1, true)
			#self.set_axis_lock(3, true)
			self.mode = MODE_STATIC
			#self.set_linear_velocity(Vector3.ZERO)
			linear_velocity = Vector3.ZERO;
			angular_velocity = Vector3.ZERO;
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
