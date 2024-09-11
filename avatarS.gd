extends CharacterBody3D

@export var admin: bool = true
@export var deathLimit = -20
@export var gmWorldHeigth = -40
@export var initPosition : Vector3 = Vector3(10, 10, 10)
const BaseSPEED = 7.0
var SPEED
const JUMP_VELOCITY = 4.5
@export var GRAB_SPEED = 10
@export var RunSPEED = 15
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
# Get the gravity from the project settings to be synced with RigidBody nodes.
func _ready():
	pass
	

@onready var cou := $Cou
@onready var camera = $Cou/Camera3D

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			cou.rotate_y(-event.relative.x * 0.01)
			camera.rotate_x(-event.relative.y * 0.01)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor() && !is_on_wall():
		velocity.y -= gravity * delta
	
	if is_on_floor():
		velocity.y = 0

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("gauche", "droite", "devant", "derriere")
	var up_down = Input.get_action_strength("haut") - Input.get_action_strength("bas")
	var direction = (cou.transform.basis * Vector3(input_dir.x, up_down, input_dir.y)).normalized()
	if Input.get_action_strength("courrir"):
		SPEED = RunSPEED
	else:
		SPEED = BaseSPEED
	if direction:
		if !is_on_wall() || is_on_floor():
			velocity.z = direction.z * SPEED
		velocity.x = direction.x * SPEED
		if admin:
			velocity.y = direction.y * SPEED
		if is_on_wall():
			velocity.y = -input_dir.y * GRAB_SPEED
			velocity.y = up_down * GRAB_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if admin || is_on_wall():
			velocity.y = move_toward(velocity.y, 0, SPEED)
	move_and_slide()

func _process(delta):
	if Input.get_action_strength("ResetPos"):
		position = initPosition
	if Input.get_action_strength("GMkey"):
		if admin == false:
			admin = true
		elif admin == true:
			admin = false
	if is_on_floor():
		admin = false
	if position.y < deathLimit && !admin && position.y > gmWorldHeigth:
		position = initPosition
		print("reset")
