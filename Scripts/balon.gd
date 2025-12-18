extends Area3D

signal popped

@export var max_clicks:int = 4
@export var points:int = 1
@export var pump_val:float = 0.2

var tween:Tween

@onready var kula_mesh: MeshInstance3D = $KulaMesh
@onready var collision: CollisionShape3D = $Collision
@onready var blow_sfx: AudioStreamPlayer = $BlowSFX
@onready var pop_sfx: AudioStreamPlayer = $PopSFX

func setup_material():
	kula_mesh.mesh = kula_mesh.mesh.duplicate(true) #duplicating makes the mesh (and therefore material) unique recursively! :>
	var metallics_val:float = 0.35
	var roughness_val:float = 0.2
	var rims_val:float = 0.5
	var new_material:StandardMaterial3D = StandardMaterial3D.new()
	
	new_material.albedo_color = Color.from_hsv(randf_range(0,1), 0.75, 1)
	new_material.metallic = metallics_val
	new_material.metallic_specular = metallics_val
	new_material.roughness = roughness_val
	new_material.rim_enabled = true
	new_material.rim = rims_val
	new_material.rim_tint = rims_val
	
	kula_mesh.mesh.material = new_material

func _on_input_event(_camera: Node, _event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if _event is InputEventMouseButton and _event.button_index == MOUSE_BUTTON_LEFT and _event.is_pressed():
		max_clicks -= 1
		
		var scale_amplified:Vector3 = scale + Vector3.ONE * pump_val
		tween = get_tree().create_tween()
		tween.tween_property(self, "scale", scale_amplified, 0.1)
		blow_sfx.pitch_scale += 0.02
		check_balloon_life()

func check_balloon_life():
	if max_clicks == 0:
		pop_balloon()
	else:
		blow_sfx.play()

func pop_balloon():
	popped.emit(points)
	visible = false
	collision.disabled = true
	pop_sfx.play()
	await pop_sfx.finished
	queue_free()
