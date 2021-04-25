extends RigidBody

const BULLET_VELOCITY = 0.1
const OFFSET = 0.3

var time_alive = 5
var hit = false
var shoot_dir = Vector3()
var dip_timer = null
var reset_timer = null
var has_target_in_reach_triggered = false
var has_pulled = false
var is_dipped_down = false

signal wrong_surface

onready var splash_particles = $SplashParticles
onready var camera_camera = get_tree().get_root().get_node("Level").get_node("Player/CameraBase/CameraRot/SpringArm/Camera")
	
func _ready():
	var vel = shoot_dir * 2
	self.apply_impulse(transform.origin, vel)
	
func _physics_process(delta):	
	var bodies = get_colliding_bodies()
	for body in bodies:
		if body.get_name() == "WaterBody":
			#self.set_axis_lock(1, true)
			#self.set_axis_lock(3, true)
			self.mode = MODE_STATIC
			#self.set_linear_velocity(Vector3.ZERO)
			linear_velocity = Vector3.ZERO;
			angular_velocity = Vector3.ZERO;
		else:			
			emit_signal("wrong_surface")
			
			camera_camera.add_trauma(0.4)

func enable_splash():
	if not has_target_in_reach_triggered:
		if not splash_particles.emitting:
			splash_particles.emitting = true
		
func enable_dip(override):
	if not has_target_in_reach_triggered or override:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var i = rng.randf_range(2, 6)
		
		dip_timer = Timer.new()
		dip_timer.connect("timeout",self,"on_timer_timeout") 
		dip_timer.set_wait_time(i)
		add_child(dip_timer)
		dip_timer.start() 
	

func on_timer_timeout():
	if not dip_timer.is_stopped():
		print("dip_down")
		is_dipped_down = true
		
		dip_timer.stop()
		self.translate(Vector3(0,-OFFSET,0))		
		
		splash_particles.emitting = false
		
		reset_timer = Timer.new()
		reset_timer.connect("timeout",self,"on_timer_timeout_reset") 
		reset_timer.set_wait_time(1.5)
		add_child(reset_timer)
		reset_timer.start() 

func on_timer_timeout_reset():
	if not reset_timer.is_stopped():
		is_dipped_down = false
		print("dip_up")
		
		reset_timer.stop()
		self.translate(Vector3(0,OFFSET,0))
		
		if not has_pulled:
			enable_dip(true)
			splash_particles.emitting = true
