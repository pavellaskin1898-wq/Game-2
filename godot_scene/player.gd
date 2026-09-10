extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5

var can_interact: bool = false
var current_interactable: Node3D = null

func _physics_process(delta: float) -> void:
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	# Handle movement
	var input_dir := Input.get_vector("move_left", "move_right", Vector2.ZERO.y, Vector2.ZERO.x)
	
	if input_dir != Vector2.ZERO:
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()
	
	# Check for interaction
	if Input.is_action_just_pressed("interact") and can_interact and current_interactable:
		interact_with_object(current_interactable)

func interact_with_object(object: Node3D) -> void:
	if object.has_method("interact"):
		object.interact()
	elif object is Area3D:
		print("Interacting with door")

func _on_interaction_area_body_entered(body: Node3D) -> void:
	if body == self and body.has_node("InteractionPoint"):
		can_interact = true
		current_interactable = body.get_node("InteractionPoint").get_parent()

func _on_interaction_area_body_exited(body: Node3D) -> void:
	if body == self:
		can_interact = false
		current_interactable = null
