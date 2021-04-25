extends KinematicBody

onready var player = null

const MAX_DISTANCE = 10


func _ready():
	player = get_tree().get_root().get_node("Level").get_node("Player")


func _physics_process(delta):
	if player and player.bait and is_instance_valid(player.bait):
		var distance = player.bait.transform.origin.distance_to(self.transform.origin)
		if distance <=  MAX_DISTANCE:
			var velocity = Vector3(player.bait.transform.origin - self.transform.origin).normalized()*2;
			velocity.y = 0
			velocity = move_and_slide(velocity);
			if distance <= 1.1:
				player.bait.enable_splash()
				player.bait.enable_dip(false)
				player.bait.has_target_in_reach_triggered = true
