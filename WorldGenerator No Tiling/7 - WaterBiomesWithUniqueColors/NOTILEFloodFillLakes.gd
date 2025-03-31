extends WorldGenProcess

# Load the black-and-white lake mask image
var lake_mask: Image

# Output image to store the result with unique colors for each lake
var output_image: Image

# Keep track of previously used colors to ensure uniqueness
var used_colors = []

# Function to generate a random color, ensuring it's unique
func _generate_random_color() -> Color:
	var new_color: Color
	var is_unique: bool = false
	
	while not is_unique:
		# Generate a random color
		new_color = Color(randf(), randf(), randf())
		
		# Assume the color is unique until proven otherwise
		is_unique = true
		
		# Check if the color has already been used
		for color in used_colors:
			if color == new_color:
				is_unique = false
				break
	
	# If unique, add to the used_colors and return
	used_colors.append(new_color)
	return new_color


# Function to perform flood fill and assign unique colors to each lake
func _flood_fill_lakes(lake_mask: Image):
	output_image = Image.new()
	output_image.copy_from(lake_mask)
	
	var width = lake_mask.get_width()
	var height = lake_mask.get_height()
	
	# Keep track of processed regions
	var visited_pixels = {}
	
	# Loop through each pixel in the lake mask
	for y in range(height):
		for x in range(width):
			var pixel_color = lake_mask.get_pixel(x, y)
			pixel_color = Vector3(pixel_color.r, pixel_color.g, pixel_color.b)
			
			# Check if the pixel is part of a lake (white) and hasn't been visited yet
			if pixel_color > Vector3(0,0,0) and not visited_pixels.has(Vector2(x, y)):
				var random_color = _generate_random_color()
				# Perform flood fill to color the entire connected region (lake)
				_flood_fill_region(output_image, lake_mask, x, y, random_color, visited_pixels)
	
	# Save the output image with colored lakes
	var img_tex = ImageTexture.create_from_image(output_image)
	output_image.save_png("res://Images/WaterBiomesUniqueColors.png")
	ResourceSaver.save(img_tex, "res://Images/WaterBiomesUniqueColors.tres")
	print('Saved WaterBiomesUniqueColors.tres')
	emit_signal('process_complete')

# Function to perform flood fill on a single region (lake)
func _flood_fill_region(output_image: Image, lake_mask: Image, start_x: int, start_y: int, fill_color: Color, visited_pixels: Dictionary):
	var stack = []
	stack.append(Vector2(start_x, start_y))
	
	while stack.size() > 0:
		var current = stack.pop_back()
		var x = int(current.x)
		var y = int(current.y)
		
		var pixel_color = lake_mask.get_pixel(x, y)
		pixel_color = Vector3(pixel_color.r, pixel_color.g, pixel_color.b)
		
		# Skip if already visited or not part of the lake (white)
		if visited_pixels.has(Vector2(x, y)) or pixel_color == Vector3(0,0,0):
			continue
		
		# Mark pixel as visited
		visited_pixels[Vector2(x, y)] = true
		
		# Set the color in the output image
		output_image.set_pixel(x, y, fill_color)
		
		# Add neighboring pixels to the stack (4-connectivity)
		if x > 0: stack.append(Vector2(x - 1, y))
		if x < lake_mask.get_width() - 1: stack.append(Vector2(x + 1, y))
		if y > 0: stack.append(Vector2(x, y - 1))
		if y < lake_mask.get_height() - 1: stack.append(Vector2(x, y + 1))

# Call this function to start the process
func _ready():
	lake_mask = load("res://Images/WaterBiomes.tres").get_image()
	_flood_fill_lakes(lake_mask)

