tool
extends ImmediateGeometry

class_name ocean

# amplitude, steepness, wavelength
export (Array, Vector3) var waves = [Vector3(2.0, 50.0, 20.0)] setget set_waves
export (PoolRealArray) var wave_directions  = PoolRealArray([0.0]) setget set_wave_directions
#const NUMBER_OF_WAVES = 10;

export(float) var speed = 10.0 setget set_speed
export (float) var n_max = 2.5 setget set_n_max
export (float) var n_min = 1.0 setget set_n_min

export(bool) var noise_enabled = true setget set_noise_enabled
export(float) var noise_amplitude = 0.28 setget set_noise_amplitude
export(float) var noise_frequency = 0.065 setget set_noise_frequency
export(float) var noise_speed = 0.48 setget set_noise_speed

export(int) var seed_value = 0 setget set_seed

var res = 300.0
var initialized = false

#var waves = []
var waves_in_tex = ImageTexture.new()

func set_n_max(new_n_max):
	n_max = new_n_max
	material_override.set_shader_param('n_max', new_n_max)

func set_n_min(new_n_min):
	n_min = new_n_min
	material_override.set_shader_param('n_min', new_n_min)

func set_waves(new_waves):
	waves = new_waves
	update_waves()

func set_wave_directions(new_wave_directions):
	wave_directions = new_wave_directions
	update_waves()

func _ready():
	if OS.get_cmdline_args().size() >= 1 and !Engine.editor_hint:
		var new_res = OS.get_cmdline_args()[0].lstrip("-").to_float()
		print(new_res)
		res = new_res
	
	for j in range(res):
		var y = j/res - 0.5
		var n_y = (j+1)/res - 0.5
		begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
		for i in range(res):
			var x = i/res - 0.5
			
#			var new_x = x 
#			var new_y = y
			
			add_vertex(Vector3(x*2, 0, -y*2))
			
#			new_y = n_y - translation.z
			add_vertex(Vector3(x*2, 0, -n_y*2))
		end()
	begin(Mesh.PRIMITIVE_POINTS)
	add_vertex(-Vector3(1,1,1)*pow(2,32))
	add_vertex(Vector3(1,1,1)*pow(2,32))
	end()
	material_override.set_shader_param('resolution', res)
#	waves_in_tex = ImageTexture.new()
	update_waves()

func get_time() -> float:
	return OS.get_ticks_msec()/1000.0 * speed

func _process(_delta):
	material_override.set_shader_param('time_offset', get_time())
	initialized = true


func set_seed(value):
	seed_value = value
	if initialized:
		update_waves()

func set_speed(value):
	speed = value
	material_override.set_shader_param('speed', value)

func set_noise_enabled(value):
	noise_enabled = value
	var old_noise_params = material_override.get_shader_param('noise_params')
	old_noise_params.d = 1 if value else 0
	material_override.set_shader_param('noise_params', old_noise_params)

func set_noise_amplitude(value):
	noise_amplitude = value
	var old_noise_params = material_override.get_shader_param('noise_params')
	old_noise_params.x = value
	material_override.set_shader_param('noise_params', old_noise_params)

func set_noise_frequency(value):
	noise_frequency = value
	var old_noise_params = material_override.get_shader_param('noise_params')
	old_noise_params.y = value
	material_override.set_shader_param('noise_params', old_noise_params)

func set_noise_speed(value):
	noise_speed = value
	var old_noise_params = material_override.get_shader_param('noise_params')
	old_noise_params.z = value
	material_override.set_shader_param('noise_params', old_noise_params)

func get_displace(pos: Vector3) -> Vector3:
	
	var new_p = Vector3(pos.x, 0.0, pos.z)
	var w: float
	var amp: float
# warning-ignore:unused_variable
	var steep: float
	var phase: float
	var dir: Vector2
	for i in range(0, waves.size()):
		amp = waves[i][0]/100.0
		if amp == 0.0: continue;
		
		dir = Vector2(1.0, 1.0).rotated(deg2rad(wave_directions[i]))
		w = (TAU)/waves[i][2]
		steep = waves[i][1]/100.0
		phase = 2.0 * w
		
		var W = (w*dir).dot(Vector2(pos.x, pos.z)) + phase*get_time()
#		new_p.x += steep*amp * dir.x * cos(W)
#		new_p.z += steep*amp * dir.y * cos(W)
		new_p.y += amp * sin(W)
	return new_p

func update_waves():
	if waves.size() != wave_directions.size():
#		printerr("Waves size ", waves.size(), " not equal to Wave Directions size ", wave_directions.size())
		return
	#Generate Waves..
	seed(seed_value)
#	var amp_length_ratio = amplitude / wavelength
	waves_in_tex = ImageTexture.new()
	var img = Image.new()
	img.create(5, waves.size(), false, Image.FORMAT_RF)
	img.lock()
	for i in range(waves.size()):
		var w = waves[i]
#		var _wavelength = rand_range(wavelength/2.0, wavelength*2.0)
		var _wind_direction = Vector2(1.0, 1.0).rotated(deg2rad(wave_directions[i]))
		
		img.set_pixel(0, i, Color(w[0]/100.0, 0,0,0))
		img.set_pixel(1, i, Color(w[1]/100.0, 0,0,0))
		img.set_pixel(2, i, Color(_wind_direction.x, 0,0,0))
		img.set_pixel(3, i, Color(_wind_direction.y, 0,0,0))
		img.set_pixel(4, i, Color((TAU)/w[2], 0,0,0))

	img.unlock()
	waves_in_tex.create_from_image(img, 0)
	
	material_override.set_shader_param('waves', waves_in_tex)