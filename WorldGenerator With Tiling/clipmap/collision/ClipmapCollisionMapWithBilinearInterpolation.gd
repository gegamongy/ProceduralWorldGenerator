extends CollisionShape3D

@export var Player: Node3D #Oops
@export var template_mesh: PlaneMesh
@onready var faces = template_mesh.get_faces()

var wc = WorldConfiguration.new()

var noise_tex = load('res://Images/LandmassesWithWaterBiomeDetail.tres')
var amplitude = wc.amplitude #Set from world config
var terrain_scale = wc.terrain_scale_factor

var size
var row_size
var terrain_snap_factor = 10 * terrain_scale
var images = noise_tex._images

func _ready():
	size = noise_tex._images[0].get_width()
	row_size = sqrt(len(noise_tex._images))
	
	update_collision_shape()
	
func _physics_process(delta):
	if noise_tex == null:
		return
	
	var player_rounded_position = snapped(
		Player.global_position,
		Vector3(terrain_snap_factor, 0, terrain_snap_factor)
		) * Vector3(1, 0, 1)

	if global_position != player_rounded_position:
		global_position = player_rounded_position
		update_collision_shape()

func update_collision_shape():
	self.scale = Vector3(terrain_scale, 1.0, terrain_scale)
	
	for i in faces.size():
		var vertex = faces[i]
		var global_vert = (vertex * terrain_scale + global_position ) / (terrain_scale)
		faces[i].y = get_height(global_vert.x, global_vert.z)
	shape.set_faces(faces)


func get_height(x, z):

	#Get global texture position from world vertex position
	var tex_pos = get_global_texture_coords(x, z)
	
	#From global tex_coords get array_tex_pos by getting correct index layer and local uv coords
	var array_tex_pos = get_array_tex_pos(tex_pos)
	var layer: int = array_tex_pos.z
	var image: Image = images[layer]

	#var height = (image.get_pixel(array_tex_pos.x, array_tex_pos.y).r ) * amplitude * terrain_scale
	var height = bilinear_interpolate(tex_pos) * amplitude * terrain_scale

	return height

func get_layer_index(uv: Vector2):
	var tile_index: Vector2i = uv / Vector2(size,size)
	tile_index = clamp(tile_index, Vector2i.ZERO, Vector2i(row_size - 1, row_size - 1))
	var layer_index: int = tile_index.x * row_size + tile_index.y
	
	return layer_index

func get_array_tex_pos(uv: Vector2):
	var layer_index = get_layer_index(uv)
	var local_uv: Vector2 = get_local_uv(uv)
	
	return Vector3(local_uv.x, local_uv.y, layer_index)

func get_local_uv(uv: Vector2):
	var local_uv: Vector2 = Vector2(fposmod(uv.x / size, 1.0) * size, fposmod(uv.y / size, 1.0) * size) #Multiply by size again to get pixel coords instead of uv coords normalized
	return local_uv

func get_global_texture_coords(x, z):
	var tex_pos = Vector2(x + (0.5 * (size * row_size)), z + (0.5 * (size * row_size)))
	return tex_pos

func bilinear_interpolate(uv: Vector2):

	var row: int = floor(uv.x)
	var col: int = floor(uv.y)
	
	var remainderX: float = uv.x - row
	var remainderY: float = uv.y - col
	
	var x1_uvw = get_array_tex_pos(Vector2(row, col))
	var x2_uvw = get_array_tex_pos(Vector2(row + 1, col))
	var y1_uvw = get_array_tex_pos(Vector2(row, col + 1))
	var y2_uvw = get_array_tex_pos(Vector2(row + 1, col + 1))
	
	var x1: float = images[x1_uvw.z].get_pixel(x1_uvw.x, x1_uvw.y).r
	var x2: float = images[x2_uvw.z].get_pixel(x2_uvw.x, x2_uvw.y).r
	var y1: float = images[y1_uvw.z].get_pixel(y1_uvw.x, y1_uvw.y).r
	var y2: float = images[y2_uvw.z].get_pixel(y2_uvw.x, y2_uvw.y).r

	return lerp(lerp(x1, x2, remainderX), lerp(y1, y2, remainderX), remainderY);
