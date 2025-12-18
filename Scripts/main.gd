extends Node3D

var score:int = 0
var min_balloons:int = 10
var max_balloons:int = 20
var languages:Array = ["en", "de", "cs", "sk"]

@export var score_label:Label

@onready var balloon_scene:PackedScene = preload("res://Scenes/balon.tscn")
@onready var balloon_parent: Node = $Balloonsy
@onready var starting_screen:CanvasLayer = $StartingScreen

func _ready() -> void:
	set_up_balloons(random_count(), random_coords())
	TranslationServer.set_locale("en")

func random_count() -> int:
	return randi_range(min_balloons,max_balloons)

func random_coords() -> Vector3:
	var minmax:Dictionary = {
		"min_x": -4,
		"max_x": 4,
		"min_y": -3,
		"max_y": 1,
		"min_z": -6,
		"max_z": 2
	}
	var random_x:int = randi_range(minmax["min_x"], minmax["max_x"])
	var random_y:int = randi_range(minmax["min_y"], minmax["max_y"])
	var random_z:int = randi_range(minmax["min_z"], minmax["max_z"])
	return Vector3(random_x,random_y,random_z)

func set_up_balloons(balloon_count:int, coords:Vector3):
	for i in balloon_count:
		var new_balloon:Area3D = balloon_scene.instantiate()
		balloon_parent.add_child(new_balloon)
		new_balloon.connect("popped", on_balloon_popped)
		new_balloon.position = coords
		new_balloon.setup_material()
		if i > 0:
			for existing_balloon in balloon_parent.get_children():
				if existing_balloon.position == coords:
					var new_coords:Vector3 = random_coords()
					while new_coords == coords: # moze sie teoretycznie losowac w nieskonczonosc ://
						new_coords = random_coords()
					new_balloon.position = new_coords

func on_balloon_popped(balloon_points:int):
	update_score(balloon_points)
	check_and_reload()

func update_score(points:int):
	score += points
	score_label.text = str(": ",score)

func check_and_reload():
	if balloon_parent.get_child_count() == 1:
		set_up_balloons(random_count(), random_coords())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		starting_screen.show()

func _on_play_button_pressed() -> void:
	starting_screen.hide()
	
func _on_language_button_pressed() -> void:
	var lang_length = languages.size()
	var current_lang_id = languages.find(TranslationServer.get_locale())
	var next_lang_id
	if current_lang_id == lang_length-1:
		next_lang_id = 0
	else:
		next_lang_id = current_lang_id + 1
	change_language(languages[next_lang_id])

func change_language(lang_code:String):
	TranslationServer.set_locale(lang_code)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
