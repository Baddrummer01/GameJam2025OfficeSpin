extends CharacterBody2D

class_name Player

const SPEED = 300.0
@onready var chair_player: AnimatedSprite2D = $ChairPlayer
@onready var spin_timer: Timer = $SpinTimer
@onready var attack_timer: Timer = $AttackTimer
@onready var rotation_bar: TextureProgressBar = $"../PlayerHealthbars/RotationBar"
@onready var end_boost_timer: Timer = $EndBoostTimer
@onready var stamina_bar_timer: Timer = $StaminaBarTimer
@onready var invuln_frames: Timer = $InvulnFrames
@onready var mainbar_health: TextureProgressBar = $"../PlayerHealthbars/Mainbar+health"


var spinState = 0
var last_input_vector = Vector2.ZERO
var isSpinning = false

func _physics_process(_delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	#should enter if boost has just ended for ramping down speed
	if !end_boost_timer.is_stopped():
		velocity = last_input_vector * SPEED
	#should enter if player releases in the last state OR if the attack timer is still going
	elif (spinState == 3 && !Input.is_action_pressed("spin_player")) || !attack_timer.is_stopped():
		spin_timer.stop()
		if (attack_timer.is_stopped()):
			attack_timer.start()
		chair_player.animation = "boost_mode"
			
		# Use the last input vector for continuous movement
		if last_input_vector != Vector2.ZERO:
			# Adjust direction with A and D keys
			var lateral_offset = Vector2.ZERO
			if Input.is_action_pressed("move_left"):
				lateral_offset = last_input_vector.rotated(-PI / 24).normalized() # Move left
			elif Input.is_action_pressed("move_right"):
				lateral_offset = last_input_vector.rotated(PI / 24).normalized() # Move right
			velocity = (last_input_vector + lateral_offset).normalized() * (SPEED + (spinState * 200))
			last_input_vector = (last_input_vector + lateral_offset).normalized()
		else:
			velocity = Vector2.ZERO
		
	else:
		#Animations
		if invuln_frames.is_stopped():
			if Input.is_action_pressed("spin_player"):
				if spin_timer.is_stopped():
					spin_timer.start()
				if spinState == 0:
					chair_player.animation = "spin_low"
				elif spinState == 1:
					chair_player.animation = "spin_med"
				elif spinState == 2:
					chair_player.animation = "spin_almost"
				else:
					chair_player.animation = "spin_high"
			elif velocity.x < 0:
				chair_player.animation = "move_left"
			elif velocity.x > 0:
				chair_player.animation = "move_right"
			elif velocity.y < 0:
				chair_player.animation = "move_up"
			else:
				chair_player.animation = "default"
		
		if not Input.is_action_pressed("spin_player"):
			spinState = 0
			spin_timer.stop()
			rotation_bar.value = 0
			rotation_bar.tint_progress = Color(0, 255, 0)
		
		var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		# spinState * 100 adds speed when the spinState escalates
		if input_vector != Vector2.ZERO:
			last_input_vector = input_vector  # Update the last input vector
		velocity = input_vector * (SPEED + (spinState * 100))
	move_and_slide()


func _on_spin_timer_timeout() -> void:
	if spinState == 0:
		spinState = 1
		# rotation_bar.value = 33
	elif spinState == 1:
		spinState = 2
		# rotation_bar.value = 66
	elif spinState == 2:
		spinState = 3
		rotation_bar.value = 100
		rotation_bar.tint_progress = Color(255, 165, 0)


func _on_attack_timer_timeout() -> void:
	chair_player.animation = "spin_low"
	spinState = 0
	rotation_bar.value = 0
	rotation_bar.tint_progress = Color(255, 255, 255)
	end_boost_timer.start()


func _on_end_boost_timer_timeout() -> void:
	chair_player.animation = "default"

func _on_stamina_bar_timer_timeout() -> void:
	if spin_timer.is_stopped() && rotation_bar.value > 0:
		rotation_bar.value -= 1
	elif !spin_timer.is_stopped() && rotation_bar.value < 100:
		rotation_bar.value += 1
	else:
		pass
		


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if invuln_frames.is_stopped() && attack_timer.is_stopped():
		mainbar_health.value -= 1 # reduces health
		invuln_frames.start()
		spin_timer.stop() # resets the spin
		rotation_bar.value = 0
		chair_player.animation = "damage_taken"


func _on_invuln_frames_timeout() -> void:
	chair_player.animation = "default"
