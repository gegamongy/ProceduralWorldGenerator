extends CollisionShape3D

@export var Player: Node3D #Oops
@export var template_mesh: PlaneMesh

@onready var faces = template_mesh.get_faces()
@onready var heightmap = load('res://Images/LandmassesWithWaterBiomeDetail.tres').get_image()


var wc = WorldConfiguration.new()

var amplitude = wc.amplitude 
var terrain_snap_factor = 24

func _ready():
	update_collision_shape()
	
func _process(delta):
	
	var player_rounded_position = snapped(
		Player.global_position,
		Vector3(terrain_snap_factor, 0, terrain_snap_factor)
		) * Vector3(1, 0, 1)
		
	if global_position != player_rounded_position:
		global_position = player_rounded_position
		update_collision_shape()

func get_height(x, z):
	var height = heightmap.get_pixel(x, z).r * amplitude
	return height

func update_collision_shape():
	for i in faces.size():
		var vertex = faces[i]
		var global_vert = (vertex + global_position)
		var global_tex_coord = global_vert + Vector3(0.5 * wc.heightmap_texture_size, 0.0, 0.5 * wc.heightmap_texture_size)
		faces[i].y = get_height(global_tex_coord.x, global_tex_coord.z)
	shape.set_faces(faces)
