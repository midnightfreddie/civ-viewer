 #tool
extends Node2D

const CIVCOLORSHADER = preload("res://civcolor.shader")
export var civ3root = "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Sid Meier's Civilization III Complete"

# func _process(delta):
 	# Shuffle pophead indexes on child sprites
# 	for N in get_children():
# 		if typeof(N) == typeof(Sprite):
# 			if randi() % 1000 == 1:
# 				var whichsprite = randi() % 180
# 				N.region_rect = Rect2(whichsprite % 9 * 50, whichsprite / 9 * 50, 50, 50)
# 	pass

func _ready():
	randomize()
	terrainplay()
	showsomepopheads()
	pass

func terrainplay():
	var image = readpcx(civ3root + "/Art/Terrain/xpgc.pcx")
	var sprite = civcolorsprite(image)
	sprite.hframes = 9
	sprite.vframes = 9
#	sprite.centered = false
	for i in range(180):
		sprite.position.x = (i % 9) * 128 + (64 * ((i / 9) % 2))
		sprite.position.y = (i / 9) * 32
		sprite.frame = randi() % 81
		add_child(sprite)
		sprite = sprite.duplicate()
	

func showsomepopheads():
	var image_from_code = readpcx(civ3root + "/Conquests/Art/SmallHeads/popHeads.pcx")
	var sprite_from_code = civcolorsprite(image_from_code)
#	sprite_from_code.apply_scale(Vector2(2, 2))
	for i in range(24):
		sprite_from_code.region_enabled = true
		var whichsprite = randi() % 180
		sprite_from_code.region_rect = Rect2(whichsprite % 9 * 50, whichsprite / 9 * 50, 50, 50)
		# sprite_from_code.frame = i + 1
		sprite_from_code.position.x = i % 8 * 120 + 70
		sprite_from_code.position.y = i * 20 + 70
		# sprite_from_code.centered = false
		# add sprite to scene
		add_child(sprite_from_code)
		sprite_from_code = sprite_from_code.duplicate()

# Given an image, returns a sprite object with a civ color shader
func civcolorsprite(image, flags = 0):
	# Create texture from image
	var texture = ImageTexture.new()
	texture.create_from_image(image, flags)
	# sprite from code only
	var sprite = Sprite.new()
	# apply texture to Sprite
	sprite.texture = texture
	# add shader
	var throwsomeshade = ShaderMaterial.new()
	throwsomeshade.shader = CIVCOLORSHADER
	sprite.material = throwsomeshade
	return sprite

# Given a filename, reads a PCX file, modifies the palette and returns an Image object
func readpcx(filename):
	# not a generalized pcx reader
	# assumes 8-bit image with 256-color 8-bit rgb palette
	var file = File.new()
	file.open(filename, file.READ)
	# seek to margins
	file.seek(0x4)
	var leftmargin = file.get_16()
	var topmargin = file.get_16()
	var rightmargin = file.get_16()
	var bottommargin = file.get_16()
	var width = rightmargin - leftmargin
	var height = bottommargin - topmargin
	# seek to bytes per scanline; assuming 1 color plane
	file.seek(0x42)
	# this is always even, so last byte may be junk if image width is odd
	var bytesperline = file.get_16()
	var imagelength = bytesperline * height
	# seek to palette, 256*3 bytes from end of file
	file.seek_end(-(256*3))
	var palettebytes = file.get_buffer(256*3)
	var palette = PoolColorArray()
	palette.resize(256)
	for i in range(256):
		palette[i] = Color(
			palettebytes[i * 3] * 256 * 256 * 256 +
			palettebytes[i * 3 + 1] * 256 * 256 +
			palettebytes[i * 3 + 2] * 256 +
			255
		)
	# set shadow and transprent color values
	# This isn't quite right
#	for i in range(16):
#		# Shadow colors
#		palette.set(255 - i, Color(0.0, 0.0, 0.0, i / 15.0))
#		# Smoke/fog colors
#		palette.set(224 + i, Color(1.0, 1.0, 1.0, i / 15.0))
	palette.set(254, Color(0x00000080))
	palette.set(255, Color(0x00000000))
	palette.set(253, Color(0xffffffff))
	# Attempt at changing hue on civ colors to preserve intensity
	var color
	for i in range(64):
		color = palette[i]
		if i < 16 or i % 2 == 0:
			# Alhpa-keying civ colors so civ color shader can hue-shift them
			color.a = 0.1
			palette[i] = color
		
	# seek to image data; assuming RLE-encoded
	file.seek(0x80)
	var i = 0
	var b = 0
	var runlen = 0
	var imagebytes = PoolByteArray()
	while i < imagelength and not file.eof_reached():
		b = file.get_8()
		# see if first 2 bits are 1s
		if b & 0xc0 == 0xc0:
			runlen = b & 0x3f
			b = file.get_8()
			for j in range(runlen):
				imagebytes.append(b)
				i += 1
		else:
			imagebytes.append(b)
			i += 1
	file.close()
		
	# create/format image data
	var image_from_code = Image.new()
	image_from_code.create(width, height, false, image_from_code.FORMAT_RGBA8)
	image_from_code.lock()
	for x in range(image_from_code.get_width()):
		for y in range(image_from_code.get_height()):
			image_from_code.set_pixel(x,y, palette[imagebytes[y * bytesperline + x]])
	image_from_code.unlock()
	return image_from_code
