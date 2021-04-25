extends KinematicBody

onready var player = null
onready var dummy_body = get_node("DummyBody")
onready var real_body = get_node("RealBodies")
onready var winning_particle = get_node("WinningParticle")
onready var level = get_tree().get_root().get_node("Level")

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
			self.look_at(player.bait.transform.origin, Vector3.UP)
			velocity = move_and_slide(velocity);
			if distance <= 1.1:
				player.bait.enable_splash()
				player.bait.enable_dip(false)
				player.bait.has_target_in_reach_triggered = true

func on_pullout_fish():
	self.in_water = false
	var hold_position = player.get_node("PlayerModel").get_node("Armature/Skeleton/BoneAttachment2/HoldPosition")
	self.global_transform.origin = hold_position.global_transform.origin
	self.dummy_body.visible = false
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	if not level.is_winner_fish():	
		self.winning_particle.visible = true
		var maxCount = self.real_body.get_child_count()
		var index = rng.randi_range(0, maxCount-2)
		self.real_body.visible = true
		self.real_body.get_children()[index].visible = true
	else:
		self.winning_particle.visible = true
		self.real_body.get_children()[self.real_body.get_child_count()-1].visible = true
		yield(get_tree().create_timer(3), "timeout")
		level.show_thanks()
	
	level.amount_fished += 1
	
	if not level.is_done:
		level.spawn_fish()
	
	print(self.global_transform.origin)
	yield(get_tree().create_timer(3), "timeout")
	self.queue_free()

func is_still_decoy():
	return in_water
