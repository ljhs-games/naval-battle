extends AudioStreamPlayer

const tracks = [
	'title0',
	'title1',
	'title2',
	'title3',
	'title4',
	'title5',
	'title6',
	'title7',
	'title8',
	'title9',
	'title10',
	'title11',
	'title12',
]

func _ready():
	#audio looping:
	randomize()
	
	play_random_song()
	
func play_random_song():
	stop()
	var rand_nb = randi() % tracks.size()
	var audiostream = load('res://assets/title-loops/' + tracks[rand_nb] + '.ogg')
	set_stream(audiostream)
	play()
	pass