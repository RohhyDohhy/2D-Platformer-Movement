extends CharacterBody2D

@export var top_speed: float = 200.0
@export var acceleration: float = 7.0
@export var decceleration: float = 7.0
@export var velocity_power: float = 0.9
@export var dynamic_friction: float = 50
@export var jump_force: float = 700
@export var jump_cut_multiplier: float = 0.6
@export var fall_gravity_multiplier: float = 1.5

var direction: float = 0
var gravity: Vector2 = Vector2.ZERO

@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_movement(delta)
	_apply_friction(delta)
	_handle_jump_cut()
	_handle_jump()
	_handle_coyote_timer()
	_handle_jump_buffer_timer()
	
	move_and_slide()


func _apply_gravity(delta: float) -> void:
	if velocity.y > 0:
		gravity = get_gravity() * fall_gravity_multiplier
	else:
		gravity = get_gravity()
	if not is_on_floor():
		velocity += gravity * delta


func _handle_movement(delta: float) -> void:
	direction = Input.get_axis("move_left", "move_right")
	var target_speed: float = direction * top_speed
	var speed_difference: float = target_speed - velocity.x
	var acceleration_rate: float = acceleration if target_speed != 0 else decceleration
	var movement: float = pow(abs(speed_difference) * acceleration_rate, velocity_power) * sign(speed_difference)
	
	velocity.x += movement * delta


func _apply_friction(delta: float) -> void:
	if direction == 0 and is_on_floor():
		var friction: float = min(dynamic_friction, abs(velocity.x)) * sign(velocity.x)
		velocity.x += friction * delta


func _handle_jump() -> void:
	if coyote_timer.time_left > 0.0 and jump_buffer_timer.time_left > 0.0:
		velocity.y = -jump_force
		coyote_timer.stop()
		jump_buffer_timer.stop()


func _handle_coyote_timer() -> void:
	if is_on_floor():
		coyote_timer.start()
		

func _handle_jump_buffer_timer() -> void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start()


func _handle_jump_cut() -> void:
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= jump_cut_multiplier
