extends WorldGenProcess

var wc = WorldConfiguration.new()

@onready var viewport = get_node('SubViewport')
@onready var rect = get_node("SubViewport/ColorRect")

var tex_size = wc.heightmap_texture_size
var tex
var material: ShaderMaterial

var continent_noise
var island_noise 
var continent_falloff
var island_outer_falloff
var island_inner_falloff


func _ready():
	continent_noise = load("res://1 - LandmassMap/continent_noise_texture.tres")
	island_noise = load("res://1 - LandmassMap/island_noise_texture.tres")
	continent_falloff = load("res://1 - LandmassMap/continent_falloff_gradient.tres")
	island_outer_falloff = load('res://1 - LandmassMap/island_outer_falloff_gradient.tres')
	island_inner_falloff = load('res://1 - LandmassMap/island_inner_falloff_gradient.tres')
	
	#set viewport size
	viewport.size = Vector2(tex_size, tex_size)

	initializeLandmassShader()
	
	tex = viewport.get_texture()
	
	await RenderingServer.frame_post_draw
	generateLandmassMap()
	

func initializeLandmassShader():
	
	#Set shader params
	material = rect.material
	
	#Set shader resources
	material.set_shader_parameter('continent_noise', continent_noise)
	material.set_shader_parameter('island_noise', island_noise)
	material.set_shader_parameter('continent_falloff', continent_falloff)
	material.set_shader_parameter('island_outer_falloff', island_outer_falloff)
	material.set_shader_parameter('island_inner_falloff', island_inner_falloff)
	
	#Set continent and island amplitudes
	material.set('shader_parameter/continent_amplitude', wc.continent_amplitude/wc.max_terrain_height)
	material.set('shader_parameter/island_amplitude', wc.island_amplitude / wc.max_terrain_height)
	
	#The only noise parameters we change are seed, based on random value.
	var continent_noise: NoiseTexture2D = material.get('shader_parameter/continent_noise')
	var island_noise: NoiseTexture2D = material.get('shader_parameter/island_noise')
	
	continent_noise.width = tex_size
	continent_noise.height = tex_size
	island_noise.width = tex_size
	island_noise.height = tex_size
	
	continent_noise.noise.seed = randi()
	island_noise.noise.seed = randi()
	
	continent_noise.noise.frequency = wc.continent_noise_frequency
	island_noise.noise.frequency = wc.island_noise_frequency
	
	#Starting Tile count and current tile
	material.set_shader_parameter("tile_count", wc.tile_count)
	material.set_shader_parameter("current_tile", Vector2(0, 0))
	
	pass

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
	
	var path = 'res://Images/LandmassMaps.tres'
	ResourceSaver.save(images_array, path)
	
	print('Saved LandmassMaps.tres')
	emit_signal('process_complete')
