extends CharacterBody3D

var PLAYER = null

@export var SPEED = 4.0

@export var PLAYER_PATH : NodePath
@onready var nav_agent = $NavigationAgent3D


# Called when the node enters the scene tree for the first time.
func _ready():
	PLAYER = get_node(PLAYER_PATH)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = Vector3.ZERO
	
	nav_agent.set_target_position(PLAYER.global_transform.origin)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
	
	look_at(Vector3(PLAYER.global_position.x, global_position.y, PLAYER.global_position.z), Vector3.UP)
	
	move_and_slide()
