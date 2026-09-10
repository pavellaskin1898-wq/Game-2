extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var gravity: float = 9.8

var can_interact: bool = false
var interactable_object: Node3D = null

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle jump (Space key)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	# Get input direction for left/right movement (A/D keys)
	var direction := Vector3.ZERO
	
	if Input.is_action_pressed("move_right"):
		direction.x += 1.0
	if Input.is_action_pressed("move_left"):
		direction.x -= 1.0
	
	direction = direction.normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()
	
	# Handle interaction (F key)
	if Input.is_action_just_pressed("interact"):
		if can_interact and interactable_object:
			interact_with_object(interactable_object)

func interact_with_object(obj: Node3D) -> void:
	print("Взаимодействие с объектом: ", obj.name)
	# Здесь можно добавить логику взаимодействия с дверями
	if obj.name.begins_with("Door"):
		print("Открываем дверь: ", obj.name)
		# Пример: можно сделать дверь проходимой или анимировать открытие

func _process(_delta: float) -> void:
	# Check for interactable objects in front of player
	var raycast: RayCast3D = $InteractionRayCast
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.name.begins_with("Door"):
			can_interact = true
			interactable_object = collider
		else:
			can_interact = false
			interactable_object = null
	else:
		can_interact = false
		interactable_object = null
