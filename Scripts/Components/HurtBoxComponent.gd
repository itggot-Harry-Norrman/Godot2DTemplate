extends Area2D
class_name HurtBoxComponent

#const ENUM = preload("res://Scripts/Singletons/GlobalEnums.gd")
@export var root_node = get_parent()
@export var hp_component : HpComponent
@export var dmg = 0
@export var knockable = true
@export var damagable = true
@export var ignore_groups : Array[String]
@export var enabled := true
@export var static_hit_death = false
@export var wall_layer : int = 3
@export var dmg_time : float = 0.5
var dmg_timer : Timer

var damaged_area : HurtBoxComponent
var damaged_areas : Array[HurtBoxComponent] = []
# maybe true / false but this is expandable

signal on_damaged
signal on_hit
signal damage_done
signal on_knocked

func _ready():
	self.connect("area_entered", _on_area_entered)
	self.connect("area_exited", _on_area_exited)
	dmg_timer = Timer.new()
	dmg_timer.wait_time = dmg_time
	dmg_timer.autostart = true
	dmg_timer.timeout.connect(damage_overlapping)
	add_child(dmg_timer)
	if static_hit_death:
		self.set_collision_mask_value(wall_layer,true)
		self.connect("body_entered", _on_wall_hit)
	pass # Replace with function body.

func _enable():
	enabled = true

func _disable():
	enabled = false

func _add_ignore_group(ignore_group : String):
	ignore_groups.append(ignore_group)

func damage(dmg : int, pos : Vector2):
	#print(get_parent().name)
	if knockable:
		if root_node.knocked:
			return
	if enabled and damagable:
		if hp_component.invincible:
			return
		hp_component.damage(dmg)
		#print("dmg,",dmg)
		if dmg > 0:
			on_damaged.emit()
		if knockable and dmg > 0:
			var diffVector = (self.global_position - pos).normalized()
			#root_node.knocked = true
			#print(float(dmg)/3.0)
			var knock_dir = diffVector * float(dmg)/3.0
			#root_node.knock_dir = diffVector * float(dmg)/3.0
			on_knocked.emit(knock_dir)
			FloatingTextManager._create_dmg_dir(str(dmg),root_node.global_position+Vector2(0,-8),diffVector)
		elif dmg > 0:
			FloatingTextManager._create_dmg_num(str(dmg), root_node.global_position+Vector2(0,-8))

func damage_overlapping():
	#if damaged_area != null:
	for area in damaged_areas:
		print("damage overlapping ", area.root_node.name)
		on_hit.emit(area)
		damage_done.emit(dmg)
		area.damage(dmg, root_node.global_position)

func _on_area_entered(area):
	#print(root_node.name," area name:", area.name)
	var ignore_check : bool = false
	for ignore_group_singular in ignore_groups:
		if area is HurtBoxComponent:
			if area.root_node.is_in_group(ignore_group_singular):
				ignore_check = true
		if area.get_parent().is_in_group(ignore_group_singular):
			ignore_check = true
	if enabled and area.has_method("damage") and not ignore_check and dmg > 0:
		#_on_hit(hit_dir : Vector2, hit_node : Node2D):
		on_hit.emit(area)
		damage_done.emit(dmg)
		area.damage(dmg, root_node.global_position)
		damaged_area = area
		if not damaged_areas.find(area):
			damaged_areas.append(area)
		#if area.get_parent().name == "Player":
		#	state = ENUM.HurtboxState.RETREATING

func _on_area_exited(area):
	if area == damaged_area:
		damaged_area = null
		damaged_areas.erase(area)

func _on_wall_hit(body:Node2D):
	if body is TileMapLayer:
		hp_component.damage(hp_component.maxHp)
