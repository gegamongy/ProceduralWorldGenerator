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
	
	noise.height = tex_size
	noise.width = tex_size
	noise.noise.frequency = wc.rainfall_noise_frequency
	
	await RenderingServer.frame_post_draw
	generate_rainfall_map()

	
func generate_rainfall_map():

	var img = texture.get_image()

	img.save_png('res://Images/RainfallMap.png')
	var image_texture = ImageTexture.create_from_image(img)
	
	var path = 'res://Images/RainfallMaps.tres'
	
	ResourceSaver.save(image_texture, path)
	print('Saved RainfallMaps.tres')
	emit_signal('process_complete')
	
	
