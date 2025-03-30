extends Node
class_name GameController_

@export var world_2d : Node2D
@export var gui : Control

@export var starting_2d_scene : String
@export var starting_gui_scene : String

@export var shader_pattern : ColorRect
@export var scene_fade_anim : AnimationPlayer

var current_2d_scene
var running_2d_scene : Dictionary = {}
var current_gui_scene
var valid_gui_scenes : Dictionary = {}

func _ready():
	#Globals.game_controller = self
	change_gui_scene(starting_gui_scene)
	change_2d_scene(starting_2d_scene, true, false, true)

func _process(delta):
	if Input.is_action_just_pressed("activate_shader"):
		change_2d_scene("res://Scenes/Levels/MilitaryCamp.tscn",true,false,true)

func change_gui_scene(new_scene : String, delete : bool = true, keep_running : bool = false)->void:
	var new = load(new_scene)
	## Checks if path to scene is valid
	if not new:
		push_error("Scene name invalid")
		return
	var inst = new.instantiate()
	## Handles removal / hiding of previous scene
	if current_gui_scene != null:
		if delete:
			valid_gui_scenes.erase(current_gui_scene.name)
			current_gui_scene.call_deferred("queue_free")
		elif keep_running:
			current_gui_scene.visible = false
		else:
			valid_gui_scenes[current_gui_scene.name] = [current_gui_scene,false]
			gui.remove_child(current_gui_scene)
	
	## Handles adding / reloading of old scene
	if valid_gui_scenes.has(inst.name):
		var gui_scene = valid_gui_scenes.get(inst.name)
		if gui_scene[1]:
			gui_scene[0].visible = true
		else:
			gui.add_child(gui_scene[0])
			valid_gui_scenes[inst.name] = [gui_scene[0],true]
		current_gui_scene = gui_scene[0]
	else:
		gui.add_child(inst)
		valid_gui_scenes[inst.name] = [inst,true]
		current_gui_scene = inst

func change_2d_scene(new_scene : String, delete : bool = true, keep_running : bool = false, skip_fade : bool = false)->void:
	if not skip_fade:
		scene_fade_anim.play("ShaderFade")
		await scene_fade_anim.animation_finished
		#shader_pattern.material.set_shader_parameter("inverted", true)
		scene_fade_anim.play_backwards("ShaderFade")
	#scene_fade_anim.play("ShaderFade")
	var new = load(new_scene)
	## Checks if path to scene is valid
	if not new:
		push_error("Scene name invalid")
		return
	var inst = new.instantiate()
	## Handles removal / hiding of previous scene
	if current_2d_scene != null:
		if delete:
			running_2d_scene.erase(current_2d_scene.name)
			current_2d_scene.call_deferred("queue_free")
		elif keep_running:
			current_2d_scene.visible = false
		else:
			running_2d_scene[current_2d_scene.name] = [current_2d_scene,false]
			world_2d.remove_child(current_2d_scene)
	
	## Handles adding / reloading of old scene
	if running_2d_scene.has(inst.name):
		var scene_2d = running_2d_scene.get(inst.name)
		if scene_2d[1]:
			scene_2d[0].visible = true
		else:
			world_2d.add_child(scene_2d[0])
			running_2d_scene[inst.name] = [scene_2d[0],true]
		current_2d_scene = scene_2d[0]
	else:
		world_2d.add_child(inst)
		running_2d_scene[inst.name] = [inst,true]
		current_2d_scene = inst

func add_child_to_world(init):
	current_2d_scene.add_child(init)
