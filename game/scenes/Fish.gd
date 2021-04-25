extends KinematicBody

onready var player = null
onready var dummy_body = get_node("DummyBody")
onready var real_body = get_node("RealBody")

const MAX_DISTANCE = 10

var in_water = true

func _ready():
	player = get_tree().get_root().get_node("Level").get_node("Player")
	player.connect("pullout_fish", self, "on_pullout_fish")

func _physics_process(delta):
	if player and player.bait and is_instance_valid(player.bait) and self.in_water:
		var distance = player.bait.transform.origin.distance_to(self.transform.origin)
		if distance <=  MAX_DISTANCE:
			var velocity = Vector3(player.bait.transform.origin - self.transform.origin).normalized()*2;
			velocity.y = 0
			velocity = move_and_slide(velocity);
			if distance <= 1.1:
				player.bait.enable_splash()
				player.bait.enable_dip(false)
				player.bait.has_target_in_reach_triggered = true


func on_pullout_fish():
	self.in_water = false
	var hold_position = player.get_node("CameraBase").get_node("HoldPosition")
	self.global_transform.origin = hold_position.global_transform.origin
	self.dummy_body.visible = false
	self.real_body.visible = true
