extends Node2D

@export_enum(
	"1. Landmass Map", 
	"2. Faultline Map", 
	"3. Landmass Faultline Composite",
	"4. Humidity Map",
	"5. Rainfall Map",
	"6. Biome Generator",
	"7. Water Biome Unique Colors",
	"8. Water Biome Levels",
	"9. Landmass Flat Water Biomes",
	"10. Landmass Water Biome Detail"
) var world_gen_step: int

var landmassMap = preload('res://01 - landmass_map/LandmassGenerator.tscn')
var faultlineMap = preload('res://02 - faultline_map/FaultlineGenerator.tscn')
var landmassFaultlineComposite = preload('res://03 - landmass_faultline_composite/LandmassFaultlineComposite.tscn')
var humidityMap = preload('res://04 - humidity_map/HumidityMap.tscn')
var rainfallMap = preload("res://05 - rainfall_map/RainfallMap.tscn")
var biomeGenerator = preload('res://06 - BiomeGenerator/BiomeGenerator.tscn')
var waterBiomeUniqueColors = preload('res://07 - WaterBiomeUniqueColors/WaterBiomeUniqueColors.tscn')
var waterBiomeLevel = preload("res://08 - WaterBiomeLevel/WaterBiomeLevel.tscn")
var landmassFlatWaterBiomes = preload('res://09 - landmass_flat_water_biomes/LandmassFlatWaterBiomes.tscn')
var landmassWaterBiomeTextures = preload("res://10 - WaterBiomeTextures/WaterBiomeTextures.tscn")

var current_index = 0
var world_gen_functions = []

func _ready():
	# Start running functions based on the selected step
	world_gen_functions = [
		"landmass_generator",
		"faultline_generator",
		"landmass_faultline_composite",
		"humidity_map",
		"rainfall_map",
		"biome_generator",
		"water_biome_unique_colors",
		"water_biome_levels",
		"landmass_flat_water_biomes",
		"landmass_water_biome_textures"
	]
	current_index = world_gen_step
	run_world_gen_step(current_index)

func run_world_gen_step(index):
	if index >= world_gen_functions.size():
		print("All steps completed")
		return

	call(world_gen_functions[index])  # Call the current step function

# Functions for each step
func landmass_generator():
	print("Running Landmass Generator")
	var landmassMap_inst = landmassMap.instantiate()
	landmassMap_inst.process_complete.connect(_on_step_ready.bind())
	add_child(landmassMap_inst)

func faultline_generator():
	print("Running Faultline Generator")
	var faultlineMap_inst = faultlineMap.instantiate()
	faultlineMap_inst.process_complete.connect(_on_step_ready.bind())
	add_child(faultlineMap_inst)

func landmass_faultline_composite():
	print("Running Landmass Faultline Composite")
	var landmassFaultlineComposite_inst = landmassFaultlineComposite.instantiate()
	landmassFaultlineComposite_inst.process_complete.connect(_on_step_ready.bind())
	add_child(landmassFaultlineComposite_inst)

func humidity_map():
	print("Running Humidity Map")
	var humidityMap_inst = humidityMap.instantiate()
	humidityMap_inst.process_complete.connect(_on_step_ready.bind())
	add_child(humidityMap_inst)
	
func rainfall_map():
	print("Running Rainfall Map")
	var rainfallMap_inst = rainfallMap.instantiate()
	rainfallMap_inst.process_complete.connect(_on_step_ready.bind())
	add_child(rainfallMap_inst)

func biome_generator():
	print("Running Biome Generator")
	var biomeGenerator_inst = biomeGenerator.instantiate()
	biomeGenerator_inst.process_complete.connect(_on_step_ready.bind())
	add_child(biomeGenerator_inst)

func water_biome_unique_colors():
	print("Running Water Biome Unique Colors")
	var waterBiomeUniqueColors_inst = waterBiomeUniqueColors.instantiate()
	waterBiomeUniqueColors_inst.process_complete.connect(_on_step_ready.bind())
	add_child(waterBiomeUniqueColors_inst)

func water_biome_levels():
	print("Running Water Biome Levels")
	var waterBiomeLevel_inst = waterBiomeLevel.instantiate()
	waterBiomeLevel_inst.process_complete.connect(_on_step_ready.bind())
	add_child(waterBiomeLevel_inst)

func landmass_flat_water_biomes():
	print("Running Landmass Flat Water Biomes")
	var landmassFlatWaterBiomes_inst = landmassFlatWaterBiomes.instantiate()
	landmassFlatWaterBiomes_inst.process_complete.connect(_on_step_ready.bind())
	add_child(landmassFlatWaterBiomes_inst)

func landmass_water_biome_textures():
	print("Running Landmass Water Biome Textures")
	var landmassWaterBiomesTextures_inst = landmassWaterBiomeTextures.instantiate()
	landmassWaterBiomesTextures_inst.process_complete.connect(_on_step_ready.bind())
	add_child(landmassWaterBiomesTextures_inst)

# Callback function that runs after each step is completed
func _on_step_ready():
	# Move to the next step without removing the completed child
	current_index += 1
	run_world_gen_step(current_index)
	print("on step ready")
