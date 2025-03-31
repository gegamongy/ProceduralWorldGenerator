extends WorldGenProcess

var wc = WorldConfiguration.new()

@onready var viewport = get_node('SubViewport')
@onready var rect = get_node("SubViewport/ColorRect")

var noise
var tex_size = wc.heightmap_texture_size

var tex
var material: ShaderMaterial

func _ready():
	noise = load("res://2 - FaultlineMask/faultline_generator_noise_texture.tres")
	
	#set viewport size
	viewport.size = Vector2(tex_size, tex_size)
	
	initializeShader()
	
	tex = viewport.get_texture()
	
	await RenderingServer.frame_post_draw
	generateLandmassMap()
	
	


func initializeShader():
	
	#Set shader params
	material = rect.material
	
	#Set constants
	material.set_shader_parameter("noise", noise)
	
	#Set random faultline parameters
	material.set_shader_parameter('fault1_center', randf_range(-0.25, 0.25))
	material.set_shader_parameter('fault1_curve_factor', randf_range(-0.7, 0.7))
	material.set_shader_parameter('fault1_uv_rotation', randf_range(0.0, 2.0*PI))
	
	material.set_shader_parameter('fault2_center', randf_range(-0.25, 0.25))
	material.set_shader_parameter('fault2_curve_factor', randf_range(-0.7, 0.7))
	material.set_shader_parameter('fault2_uv_rotation', randf_range(0.0, 2.0*PI))
	
	material.set_shader_parameter('current_tile', Vector2(0, 0))
	material.set_shader_parameter('tile_count', wc.tile_count)
	
	noise.height = tex_size
	noise.width = tex_size
	noise.noise.frequency = wc.faultline_noise_frequency
	
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
	
	var path = 'res://Images/FaultlineMaps.tres'
	
	ResourceSaver.save(images_array, path)
	print('Saved FaultlineMaps.tres')
	emit_signal('process_complete')
