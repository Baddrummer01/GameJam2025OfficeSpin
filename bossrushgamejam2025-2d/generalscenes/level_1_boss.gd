extends RigidBody2D

@onready var texture_progress_bar: TextureProgressBar = $"../BossHealthbars/TextureProgressBar"
@onready var attack_timer: Timer = $"../chairPlayer/AttackTimer"
@onready var mainbar_health: TextureProgressBar = $"../PlayerHealthbars/Mainbar+health"
@onready var invuln_frames: Timer = $"../chairPlayer/InvulnFrames"
@onready var hit_cooldown: Timer = $HitCooldown

@onready var target_anim: AnimatedSprite2D = $TargetAnim

func _on_hitbox_area_entered(area: Area2D) -> void:
	if hit_cooldown.is_stopped() && !attack_timer.is_stopped():
		texture_progress_bar.value -= 5
		hit_cooldown.start()
		target_anim.animation = "damaged"
