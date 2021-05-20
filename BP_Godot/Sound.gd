extends Node

var enabled = true

#var character_speak_sound_1 = preload("res://assets/Audio/SoundEffects/SFX/Speech/CharSpeak_blop1.wav")
#var character_speak_sound_2 = preload("res://assets/Audio/SoundEffects/SFX/Speech/CharSpeak_blop2.wav")
#var character_speak_sound_3 = preload("res://assets/Audio/SoundEffects/SFX/Speech/CharSpeak3.wav")

var sound_node
var music_node

var music = {
	"intro_music": preload("res://assets/Audio/Music/bensound-buddy.ogg"),
	"livingroom_music": preload("res://assets/Audio/Music/bensound-cute.ogg"),
	"dark_times_music": preload("res://assets/Audio/Music/Dark/569726__josefpres__dark-loops-202-piano-with-melody-short-loop-60-bpm.wav"),
	"pub": preload("res://assets/Audio/SoundEffects/SFX/Pub/294425__alexkandrell__cambridge-pub-beergarden-rowdy-short-atmos.wav"),
	"street_day": preload("res://assets/Audio/SoundEffects/SFX/Street/52740__eric5335__town-or-suburbs-amb-spring-day.wav"),
	"office": preload("res://assets/Audio/Music/Office/407292__nightwatcher98__office-ambience.mp3"),
	"good_end": preload("res://assets/Audio/Music/Endings/442789__lena-orsa__happy-music-pistachio-ice-cream-ragtime.mp3"),
	"bad_end": preload("res://assets/Audio/Music/Endings/416057__psovod__sad-ending-piano-1.mp3"),
}

var sounds = {
	"doors_sound": preload("res://assets/Audio/SoundEffects/SFX/Door/519065__angelkunev__door-unlock.wav"),
	"doors_open": preload("res://assets/Audio/SoundEffects/SFX/Door/369618__cribbler__door-close-open-int.wav"),
	"woman_ehmehm": preload("res://assets/Audio/SoundEffects/SFX/Voices/Woman/431599__owly-bee__clearing-throat.wav"),
	"sofa_fall": preload("res://assets/Audio/SoundEffects/SFX/Items/Sofa/186476__jar-jar-vince__sofa.wav"),
	"boom": preload("res://assets/Audio/SoundEffects/SFX/Factory/388200__contramundum__fire.mp3"),
	"door_knock": preload("res://assets/Audio/SoundEffects/SFX/Door/567607__oldhiccup__knocking-on-the-door.mp3"),
	"turn_page": preload("res://assets/Audio/SoundEffects/SFX/Items/Paper/63318__flag2__page-turn-please-turn-over-pto-paper-turn-over.wav"),
	"ringtone": preload("res://assets/Audio/SoundEffects/SFX/Phone/351284__pogmothoin__incoming-call-marimba-ringtone-sound.mp3"),
	"pipipip": preload("res://assets/Audio/SoundEffects/SFX/Phone/453267__lyd4tuna__getting-hung-up-on-three-beeps.wav"),
	"snore1": preload("res://assets/Audio/SoundEffects/SFX/Snore/180334__sankalp__snoring-1.wav"),
	"snore2": preload("res://assets/Audio/SoundEffects/SFX/Snore/471944__juanfg__yawning-and-snoring.wav"),
	"keyboard": preload("res://assets/Audio/SoundEffects/SFX/Items/Laptop/364116__noblerinthemind__typing.mp3"),
	"message": preload("res://assets/Audio/SoundEffects/SFX/Phone/98950__pj123pj__text-message.ogg"),
}

var curr_sound
var curr_music

func _ready():
	sounds.doors_sound.loop_mode = 0
	music.pub.loop_mode = 1
	music.pub.loop_end = 500000
	sounds.boom.loop = false;
	sounds.door_knock.loop = false;
	sounds.ringtone.loop = false;
	sounds.keyboard.loop = false;
	sounds.message.loop = false;

func play_sound(name):
	if enabled: 
		curr_sound = name
		sound_node.set_stream(sounds[name])
		sound_node.play()
	
func play_music(name):
	if enabled: 
		if curr_music != name:
			curr_music = name
			music_node.set_stream(music[name])
			music_node.play()
	
func audio_finished():
	pass

func sound_off():
	enabled = false
	curr_music = ""
	sound_node.stop()
	music_node.stop()

func sound_on():
	enabled = true
	music_node.play()
