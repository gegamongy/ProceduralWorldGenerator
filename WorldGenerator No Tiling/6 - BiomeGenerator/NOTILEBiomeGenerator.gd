extends WorldGenProcess

@onready var subviewports = get_node("Subviewports").get_children()

@onready var view_rect = get_node("MarginContainer/BiomeColors2")

@export var hum_desert_tundra_flag: float = 0.27
@export var hum_tundra_grass_flag: float = 0.33
@export var hum_grass_dryf_flag: float = 0.55
@export var hum_dryf_rainf_flag: float = 0.69
@export var hum_wetland_swamp_flag: float = 0.42
@export var hum_swamp_lake_flag: float = 0.54
@export var rain_water_biome_flag: float = 0.72


@export var blend_radius: float = 0.01

#BIOME SHADER RESOURCES
var rainfall
var humidity 
var altitude

var wc = WorldConfiguration.new()

var textures = []
var rects = []
var mats = []

func _ready():
	rainfall = load("res://Images/RainfallMap.tres") #rainfall map
	humidity = load("res://Images/HumidityMap.tres") #humidity map
	altitude = load("res://Images/LandmassesWithFaultlineDetail.tres") #altitude map
	
	set_viewport_size()
	setup_shaders()
	get_viewport_textures()
	
	await RenderingServer.frame_post_draw
	generate_biome_maps()

func get_viewport_textures():
	for viewport in subviewports:
		textures.append(viewport.get_texture())
	
func set_viewport_size():
	
	for viewport in subviewports:
		viewport.size = Vector2(wc.heightmap_texture_size, wc.heightmap_texture_size)
	
func setup_shaders():
	
	for viewport in subviewports:
		var rect = viewport.get_child(0)
		mats.append(rect.material)
	
	for mat in mats:
		
		#SHADER RESOURCES
		mat.set_shader_parameter('rainfall_maps', rainfall)
		mat.set_shader_parameter('humidity_maps', humidity)
		mat.set_shader_parameter('altitude_maps', altitude)
		
		#BIOME CONFIG
		mat.set_shader_parameter('hum_desert_tundra_flag', hum_desert_tundra_flag)
		mat.set_shader_parameter('hum_tundra_grass_flag', hum_tundra_grass_flag)
		mat.set_shader_parameter('hum_grass_dryf_flag', hum_grass_dryf_flag)
		mat.set_shader_parameter('hum_dryf_rainf_flag', hum_dryf_rainf_flag)
		mat.set_shader_parameter('hum_wetland_swamp_flag', hum_wetland_swamp_flag)
		mat.set_shader_parameter('hum_swamp_lake_flag', hum_swamp_lake_flag)
		mat.set_shader_parameter('rain_water_biome_flag', rain_water_biome_flag)
		
		mat.set_shader_parameter('blend_radius', blend_radius)
		

func generate_biome_maps():
	
	#Generate Rainfall and Humidity Maps

	for i in range(len(textures)):
		var img = textures[i].get_image()
		
		
		var image_texture = ImageTexture.create_from_image(img)
		var path = ""

		match i:
			5:
				path = "res://Images/WaterBiomes.tres"
				img.save_png("res://Images/WaterBiomes.png")
			6:
				path = "res://Images/LakeDepthMasks.tres"
				img.save_png("res://Images/LakeDepthMask.png")
			7:
				path = "res://Images/SwampMasks.tres"
				img.save_png("res://Images/SwampMask.png")
			8:
				path = "res://Images/WetlandMasks.tres"
				img.save_png("res://Images/WetlandMask.png")
			9:
				path = "res://Images/BiomeColors.tres"
				img.save_png("res://Images/BiomeColors.png")
				print('trying to save BiomeColors.tres')
			_:
				print("Trying to print Biome Map ", i)
				path = "res://Images/BiomeMap%s.tres"
				path = path % i
				
				img.save_png("res://Images/BiomeImg%s.png" % i)

		ResourceSaver.save(image_texture, path)
	
	print('Biome Maps Saved')
	emit_signal('process_complete')
	
	
	
