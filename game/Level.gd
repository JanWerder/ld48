extends Spatial

onready var spawn_points = $SpawnPoints

var fish = null
var is_done = false
var amount_fished = 0

const WINNING_AMOUNT = 3

func _ready():
	OS.window_fullscreen = true
	spawn_fish()

func _input(event):
	if event.is_action_pressed("quit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()


func spawn_fish():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var i = rng.randi_range(0, spawn_points.get_children().size()-1)
	var spawn_point = spawn_points.get_children()[i]
	
	if fish and fish.is_still_decoy():
		fish.queue_free()	
		
	fish = preload("res://scenes/Fish.tscn").instance()
	fish.global_transform.origin = spawn_point.global_transform.origin
	add_child(fish)
		
func is_winner_fish():
	return !amount_fished < WINNING_AMOUNT
