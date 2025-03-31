extends WorldGenProcess

@onready var viewport = get_node('SubViewport')
@onready var rect = viewport.get_child(0)


var wc = WorldConfiguration.new()
var tex_size = wc.heightmap_texture_size
var texture 
var mat: ShaderMaterial

func _ready():
	viewport.size = Vector2(tex_size, tex_size)
	texture = viewport.get_texture()
	
	mat = rect.material
	var noise = mat.get_shader_parameter('noise')
	mat.set_shader_parameter("current_tile", Vector2(0, 0))
	mat.set_shader_parameter("tile_count", wc.tile_count)
	
	noise.height = tex_size
	noise.width = tex_size
	noise.noise.frequency = wc.rainfall_noise_frequency
	
	await RenderingServer.frame_post_draw
	generate_rainfall_map()

	
func generate_rainfall_map():
	#For tiling - Iterate through each tile, and save the image
	var images = []
	for x in range(wc.tile_count):
		for y in range(wc.tile_count):
			var current_tile = Vector2(x, y)
			mat.set_shader_parameter("current_tile", current_tile)
			
			texture = viewport.get_texture()
			await RenderingServer.frame_post_draw
			
			var img = texture.get_image()
			images.append(img)


	var images_array = Texture2DArray.new()
	images_array.create_from_images(images)
	
	var path = 'res://Images/RainfallMaps.tres'
	
	ResourceSaver.save(images_array, path)
	print('Saved RainfallMaps.tres')
	emit_signal('process_complete')
	
	
