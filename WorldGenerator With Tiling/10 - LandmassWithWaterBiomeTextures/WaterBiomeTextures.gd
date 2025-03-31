extends WorldGenProcess

var wc = WorldConfiguration.new()

@onready var viewport = get_node('SubViewports').get_children()[0]

var tex_size = wc.heightmap_texture_size
var tex

var heightmap
var lake_depth_mask
var swamp_mask
var wetland_mask
var swamp_texture
var wetland_texture

var mat: ShaderMaterial

func _ready():
	
	heightmap = load('res://Images/LandmassesWithFlatWaterBiomes.tres')
	lake_depth_mask = load("res://Images/LakeDepthMasks.tres")
	swamp_mask = load("res://Images/SwampMasks.tres")
	wetland_mask = load("res://Images/WetlandMasks.tres")
	swamp_texture = load("res://10 - LandmassWithWaterBiomeTextures/swamp_noise_texture.tres")
	wetland_texture = load("res://10 - LandmassWithWaterBiomeTextures/wetland_noise_texture.tres")
	
	viewport.size = Vector2(tex_size, tex_size)
	
	setupShader()
	generateLandmassMap()
	
func setupShader():
	var rect = viewport.get_child(0)
	mat = rect.material
	
	mat.set_shader_parameter("heightmap", heightmap)
	mat.set_shader_parameter("lake_depth_mask", lake_depth_mask)
	mat.set_shader_parameter("swamp_mask", swamp_mask)
	mat.set_shader_parameter("wetland_mask", wetland_mask)
	mat.set_shader_parameter("swamp_texture", swamp_texture)
	mat.set_shader_parameter("wetland_texture", wetland_texture)
	
	#Starting Tile count and current tile
	mat.set_shader_parameter("tile_count", wc.tile_count)
	mat.set_shader_parameter("current_tile", Vector2(0, 0))

func generateLandmassMap():
	#For tiling - Iterate through each tile, and save the image
	var images = []
	for x in range(wc.tile_count):
		for y in range(wc.tile_count):
			var current_tile = Vector2(x, y)
			mat.set_shader_parameter("current_tile", current_tile)
			
			tex = viewport.get_texture()
			await RenderingServer.frame_post_draw
			
			var img = tex.get_image()
			images.append(img)
			#img.save_png('res://Images/%s.png' % img)
	
	var images_array = Texture2DArray.new()
	images_array.create_from_images(images)
	
	var path = 'res://Images/LandmassesWithWaterBiomeDetail.tres'
	ResourceSaver.save(images_array, path)
	print('Saved Water Biome Details')
	emit_signal("process_complete")
