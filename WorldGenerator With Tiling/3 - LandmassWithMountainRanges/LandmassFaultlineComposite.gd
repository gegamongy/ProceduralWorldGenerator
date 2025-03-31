extends WorldGenProcess

var wc = WorldConfiguration.new()

@onready var viewport = get_node('SubViewport')
@onready var rect = get_node("SubViewport/ColorRect")

var landmass 
var faultline
var mountains
var hills

var tex_size = wc.heightmap_texture_size

var tex
var material: ShaderMaterial 

func _ready():
	landmass = load('res://Images/LandmassMaps.tres')
	faultline = load("res://Images/FaultlineMaps.tres")
	mountains = load("res://3 - LandmassWithMountainRanges/mountain_biome_noise_texture.tres")
	hills = load("res://3 - LandmassWithMountainRanges/rolling_hills_noise_texture.tres")

	#set viewport size
	viewport.size = Vector2(tex_size, tex_size)
	
	material = rect.material
	
	material.set_shader_parameter("landmass_map", landmass)
	material.set_shader_parameter("faultline_map", faultline)
	material.set_shader_parameter("mountain_range_texture", mountains)
	material.set_shader_parameter("rolling_hills_texture", hills)
	
	material.set_shader_parameter('mountain_amplitude', wc.mountain_amplitude / wc.max_terrain_height)
	material.set_shader_parameter('hills_amplitude', wc.hills_amplitude / wc.max_terrain_height)
	
	material.set_shader_parameter("current_tile", Vector2(0, 0))
	material.set_shader_parameter("tile_count", wc.tile_count)
	
	mountains.height = tex_size
	mountains.width = tex_size
	hills.height = tex_size
	hills.width = tex_size
	
	mountains.noise.frequency = wc.mountain_range_noise_frequency
	hills.noise.frequency = wc.rolling_hills_noise_frequency
	
	tex = viewport.get_texture()
	
	await RenderingServer.frame_post_draw
	generateLandmassMap()
	




func generateLandmassMap():
	
	#For tiling - Iterate through each tile, and save the image
	var images = []
	
	for x in range(wc.tile_count):
		for y in range(wc.tile_count):
			var current_tile = Vector2(x, y)
			material.set_shader_parameter("current_tile", current_tile)
			
			tex = viewport.get_texture()
			await RenderingServer.frame_post_draw
			
			var img = tex.get_image()
			images.append(img)


	var images_array = Texture2DArray.new()
	images_array.create_from_images(images)
	
	var path = 'res://Images/LandmassesWithFaultlineDetail.tres'
	
	ResourceSaver.save(images_array, path)
	print('Saved LandmassesWithFaultlineDetail.tres')
	emit_signal('process_complete')
