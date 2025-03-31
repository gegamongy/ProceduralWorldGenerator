class_name WorldConfiguration
extends Node

#This class contains all the configuration settings of the procedurally generated world
#A good worldsize = 65536 or 4096 * 16

var world_size = 65536 #In meters

#LANDMASS CONFIGURATION

var heightmap_texture_size: float = 2048

var tile_count = 2 #Incorrect nomenclature, actual tile_count is tile_count^2
var max_tiles = 8

var terrain_scale_factor = 25.0

var amplitude = 80.0

var max_terrain_height: float = 700
var mountain_amplitude: float = 450
var hills_amplitude: float = 360
var continent_amplitude: float = 300 #Continent Height in meters
var island_amplitude: float = 150


var sea_level: float = 85 # Out of 300, Sea level ratio is 0.44

#Landmass Map Config
var continent_noise_frequency = 0.004 / (heightmap_texture_size / 1024.0) #Ratio is 0.004 : 1024px, 
var island_noise_frequency = 0.0188 / (heightmap_texture_size / 1024.0) #Ratio is 0.0188 : 1024px



#Faultline Map Config
const faultline_distortion = 0.09 #Not set yet
const faultline_gradient_offset = -0.93 #Not set yet
const faultline_gradient_scale = 8.5 #Not set yet
var faultline_noise_frequency = 0.0118 / (heightmap_texture_size / 1024.0)

#Landmass Faultline Composite Config
var mountain_range_noise_frequency = 0.0334 / (heightmap_texture_size / 1024.0)
var rolling_hills_noise_frequency = 0.0643 / (heightmap_texture_size / 1024.0)

#Humidity Map Config
var humidity_noise_frequency = 0.0114 / (heightmap_texture_size / 1024.0)

#Rainfall Map Config 
var rainfall_noise_frequency = 0.0114 / (heightmap_texture_size / 1024.0)

