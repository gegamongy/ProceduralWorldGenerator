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
	landmass = load('res://Images/LandmassMap.tres')
	faultline = load("res://Images/FaultlineMap.tres")
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

	var img = tex.get_image()
	var image_texture = ImageTexture.create_from_image(img)
	
	img.save_png('res://Images/LandmassFaultlineDetail.png')
	
	var path = 'res://Images/LandmassesWithFaultlineDetail.tres'
	
	ResourceSaver.save(image_texture, path)
	print('Saved LandmassesWithFaultlineDetail.tres')
	emit_signal('process_complete')
