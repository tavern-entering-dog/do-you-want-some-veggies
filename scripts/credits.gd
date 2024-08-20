extends Control


@onready var music = $"/root/Music"
@onready var credits_song = $"/root/Music/Credits Song"

@export var bg_color : Color = Color.BLACK
@export var to_scene : PackedScene = null
@export var title_color := Color.FOREST_GREEN
@export var text_color := Color.WHITE
@export var title_font : FontFile = null
@export var text_font : FontFile = null
@export var Music : AudioStream = null
@export var Use_Video_Audio : bool = false
@export var Video : VideoStream = null

const section_time := 2.0
const line_time := 0.3
const base_speed := 70
const speed_up_multiplier := 10.0

var scroll_speed : float = base_speed
var speed_up := false

@onready var colorrect := $ColorRect
@onready var videoplayer := $VideoPlayer
@onready var line := $CreditsContainer/Line
var started := false
var finished := false

var section
var section_next := true
var section_timer := 0.0
var line_timer := 0.0
var curr_line := 0
var lines := []

var credits = [
	[
		"A game by tavern-entering dog Studios"
	],[
		"Programming and Art",
		"Henry Díaz Bordón",
	],[
		"Works Cited",
		"'4 Chiptunes (Adventure)' by SubspaceAudio",
		"https://opengameart.org/content/4-chiptunes-adventure",
		"",
		"'NES Shooter Music (5 tracks, 3 jingles)' by SketchyLogic",
		"https://opengameart.org/content/nes-shooter-music-5-tracks-3-jingles",
		"",
		"'War Pack' by 2dGameCreation",
		"https://opengameart.org/content/war-pack",
		"",
		"'City tilemap 32x32' by AvKov",
		"https://avkov.itch.io/city-tilemap-32x32",
		"",
		"Sound effects imported from Myinstants",
		"https://www.myinstants.com/",
		"",
		"'Realistic CRT shader' by c64cosmin",
		"https://godotshaders.com/shader/realistic-crt-shader/",
		"",
		"'JinxedWizards' by Christina Antoinette Neofotistou",
		"https://www.pentacom.jp/pentacom/bitfontmaker2/gallery/?id=1362",
		"",
		"'Credits Screen' by MiDe",
		"https://godotengine.org/asset-library/asset/2411"
	],[
		"Tools Used",
		"Developed with Godot Engine v4.3",
		"https://godotengine.org/releases/4.3/",
		"",
		"Art created with Pixelorama",
		"https://orama-interactive.itch.io/pixelorama"
	],[
		"Special thanks",
		"This game is dedicated to my parents,",
		"whose support has been the seed of all I have ever produced.",
		"",
		"Thanks as well to everybody who has helped in any sort of way",
		"making a game dev group out of a stupid bar joke.",
	],[
		"And thank YOU for playing this game!"
	]
]

func _ready():
	for song in music.get_children():
		song.volume_db = -80
	credits_song.volume_db = 0
	credits_song.play()
	colorrect.color = bg_color
	videoplayer.set_stream(Video)
	if !Use_Video_Audio:
		var stream = AudioStreamPlayer.new()
		stream.set_stream(Music)
		add_child(stream)
		videoplayer.set_volume_db(-80)
		stream.play()
	else:
		videoplayer.set_volume_db(0)
	videoplayer.play()
	

func _process(delta):
	scroll_speed = base_speed * delta
	
	if section_next:
		section_timer += delta * speed_up_multiplier if speed_up else delta
		if section_timer >= section_time:
			section_timer -= section_time
			
			if credits.size() > 0:
				started = true
				section = credits.pop_front()
				curr_line = 0
				add_line()
	
	else:
		line_timer += delta * speed_up_multiplier if speed_up else delta
		if line_timer >= line_time:
			line_timer -= line_time
			add_line()
	
	if speed_up:
		scroll_speed *= speed_up_multiplier
	
	if lines.size() > 0:
		for l in lines:
			l.set_global_position(l.get_global_position() - Vector2(0, scroll_speed))
			if l.get_global_position().y < l.get_line_height():
				lines.erase(l)
				l.queue_free()
	elif started:
		finish()


func finish():
	if not finished:
		finished = true
		if to_scene != null:
			var path = to_scene.get_path()
			get_tree().change_scene_to_file(path)
		else:
			get_tree().quit()


func add_line():
	var new_line = line.duplicate()
	new_line.text = section.pop_front()
	lines.append(new_line)
	if curr_line == 0:
		if title_font != null:
			new_line.set("theme_override_fonts/font", title_font)
		new_line.set("theme_override_colors/font_color", title_color)
	
	else:
		if text_font != null:
			new_line.set("theme_override_fonts/font", text_font)
		new_line.set("theme_override_colors/font_color", text_color)
	
	$CreditsContainer.add_child(new_line)
	
	if section.size() > 0:
		curr_line += 1
		section_next = false
	else:
		section_next = true


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		finish()
	if event.is_action_pressed("ui_down") and !event.is_echo():
		speed_up = true
	if event.is_action_released("ui_down") and !event.is_echo():
		speed_up = false
