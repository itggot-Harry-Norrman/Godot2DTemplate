extends Node2D
class_name HpComponent
@export var root_node : Node2D
@export var maxHp = 3
@export var death_effect : Array[PackedScene]
@export var hit_sound : AudioStreamPlayer
@export var playerAnim : Node2D
@export var freeable = true
var spawnedDeathEffect = false
#var hit_flash : HitAnimator
@export var invincibleTime : float = 0.0
var invincibleTimer : float = 0.0
var invincible = false
var hp = 0 

signal on_death
#@export var hurtbox : HurtBoxComponent
# Called when the node enters the scene tree for the first time.
func _ready():
	hp = maxHp
	#if playerAnim != null:
	
	#hit_flash = root_node.get_node("HitAnimator")
	#print("hit flash", hit_flash)
	#hit_flash = playerAnim.hitAnimator

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if hp <= 0:
		#print("hp: ", hp)
		if death_effect != null and not spawnedDeathEffect:
			spawnedDeathEffect = true
			for death_effect_singular in death_effect:
				var instantiated = death_effect_singular.instantiate()
				## Should probably be moved out for better code health
				var ignore_hurtbox : HurtBoxComponent
				if root_node.has_method("_get_hurtbox"):
					ignore_hurtbox = root_node.get_hurtbox()
				if ignore_hurtbox and instantiated.has_method("_get_hurtbox"):
					var hb : HurtBoxComponent =instantiated.get_hurtbox()
					## some standard standard group
					#hb._add_ignore_group("root_node")
				instantiated.position = self.global_position
				Globals.game_controller.add_child_to_world(instantiated)
		on_death.emit()
		#await get_tree().create_timer(0.2).timeout
		#if root_node == null and freeable:
		#	get_parent().queue_free()
		#elif freeable:
		#	root_node.queue_free()
	if invincible: 
		invincibleTimer += delta
		if invincibleTimer > invincibleTime:
			invincible = false
			invincibleTimer = 0.0
func damage(dmg : int):
	#print(dmg)
	if not invincible:
		hp -= dmg
		invincible = true
		if hit_sound != null && dmg > 0:
			hit_sound.play()
		#if hit_flash != null && dmg > 0:
		#	hit_flash.hit()
