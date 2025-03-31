extends WorldGenProcess

var wc = WorldConfiguration.new()

@onready var viewport = get_node('SubViewport')
@onready var rect = get_node("SubViewport/ColorRect")

var heightmap
var water_biome_mask
var water_biome_altitude

var tex_size = wc.heightmap_texture_size
var tex

var mat: ShaderMaterial 

func _ready():
	heightmap = load("res://Images/LandmassesWithFaultlineDetail.tres")
	water_biome_mask = load("res://Images/WaterBiomes.tres")
	water_biome_altitude = load("res://Images/WaterBiomesWithAltitude.tres")

	#set viewport size
	viewport.size = Vector2(tex_size, tex_size)
	setup_shader()
	
	tex = viewport.get_texture()
	await RenderingServer.frame_post_draw

	generateLandmassMap()
	

func setup_shader():
	mat = rect.material
	mat.set_shader_parameter("heightmaps", heightmap)
	mat.set_shader_parameter("water_biome_masks", water_biome_mask)
	mat.set_shader_parameter("water_biome_altitudes", water_biome_altitude)
	
	mat.set_shader_parameter("current_tile", Vector2(0, 0))
	mat.set_shader_parameter("tile_count", wc.tile_count)


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
	
	var path = 'res://Images/LandmassesWithFlatWaterBiomes.tres'
	
	ResourceSaver.save(images_array, path)
	print('Saved res://Images/LandmassesWithFlatWaterBiomes.tres')
	emit_signal('process_complete')
