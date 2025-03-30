extends Node
class_name OnDeathComponent

@export var hp_component : HpComponent
@export var parent : Node2D
@export var amm : int = 1
var spawned = 0
#TODO expand to do multiple types of things
func _ready():
	hp_component.on_death.connect(_on_death)

func _on_death():
	while spawned < amm:
		spawned += 1
		#ItemFactory.create_phys_obj(parent.global_position, 
									#"res://Assets/Sprites/Objects/copper_ore.png", 
									#Vector2(randf_range(-1,1),randi_range(-1,0)).normalized(),
									#2)
		
	#await get_tree().create_timer(0.05).timeout
	parent.call_deferred("queue_free")
	#parent.queue_free()
	pass	
