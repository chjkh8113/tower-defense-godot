extends Node
class_name AudioManager
## Generates and plays game sounds

var shoot_sound: AudioStreamWAV
var hit_sound: AudioStreamWAV
var death_sound: AudioStreamWAV
var music_player: AudioStreamPlayer

# Default: sound OFF
var sfx_muted: bool = true
var music_muted: bool = true

signal sfx_mute_changed(muted: bool)
signal music_mute_changed(muted: bool)

func _ready() -> void:
	shoot_sound = generate_shoot_sound()
	hit_sound = generate_hit_sound()
	death_sound = generate_death_sound()
	setup_background_music()

func setup_background_music() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.stream = generate_background_music()
	music_player.volume_db = -15
	music_player.autoplay = false  # Don't autoplay since muted by default
	add_child(music_player)
	music_player.finished.connect(_on_music_finished)

func _on_music_finished() -> void:
	if not music_muted:
		music_player.play()

func generate_background_music() -> AudioStreamWAV:
	var sample_rate = 22050
	var duration = 8.0
	var samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(samples * 2)

	var notes = [130.81, 146.83, 164.81, 174.61, 196.0, 220.0, 246.94, 261.63]
	var bass_notes = [65.41, 73.42, 82.41, 87.31]
	var chord_pattern = [0, 0, 3, 3, 4, 4, 0, 0]
	var beats_per_bar = 8
	var beat_duration = duration / (beats_per_bar * 2)

	for i in samples:
		var t = float(i) / sample_rate
		var beat = int(t / beat_duration) % beats_per_bar
		var chord_idx = chord_pattern[beat]

		var bass_freq = bass_notes[chord_idx % bass_notes.size()]
		var bass = sin(t * bass_freq * TAU) * 0.15

		var arp_speed = 4.0
		var arp_idx = int(t * arp_speed) % 4
		var melody_freq = notes[(chord_idx + arp_idx * 2) % notes.size()]
		var melody = sin(t * melody_freq * TAU) * 0.08

		var pad_freq = notes[chord_idx % notes.size()] * 2
		var pad = sin(t * pad_freq * TAU) * 0.05 * (0.5 + 0.5 * sin(t * 0.5))

		var sample = bass + melody + pad
		sample = tanh(sample * 2) * 0.3

		var value = int(sample * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF

	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = samples
	return stream

func generate_shoot_sound() -> AudioStreamWAV:
	var sample_rate = 22050
	var duration = 0.08
	var samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var t = float(i) / sample_rate
		var envelope = 1.0 - (float(i) / samples)
		var freq = 800 - (t * 4000)
		var sample = sin(t * freq * TAU) * envelope * 0.5
		var value = int(sample * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF

	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func generate_hit_sound() -> AudioStreamWAV:
	var sample_rate = 22050
	var duration = 0.05
	var samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var t = float(i) / sample_rate
		var envelope = 1.0 - (float(i) / samples)
		var sample = sin(t * 200 * TAU) * envelope * 0.3
		sample += (randf() - 0.5) * envelope * 0.2
		var value = int(sample * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF

	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func generate_death_sound() -> AudioStreamWAV:
	var sample_rate = 22050
	var duration = 0.15
	var samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var t = float(i) / sample_rate
		var envelope = pow(1.0 - (float(i) / samples), 2)
		var sample = sin(t * 150 * TAU) * envelope * 0.4
		sample += (randf() - 0.5) * envelope * 0.4
		var value = int(sample * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF

	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func play_shoot() -> void:
	if sfx_muted:
		return
	var player = AudioStreamPlayer.new()
	player.stream = shoot_sound
	player.volume_db = -10
	player.pitch_scale = randf_range(0.9, 1.1)
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func play_hit() -> void:
	if sfx_muted:
		return
	var player = AudioStreamPlayer.new()
	player.stream = hit_sound
	player.volume_db = -15
	player.pitch_scale = randf_range(0.8, 1.2)
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func play_death() -> void:
	if sfx_muted:
		return
	var player = AudioStreamPlayer.new()
	player.stream = death_sound
	player.volume_db = -8
	player.pitch_scale = randf_range(0.9, 1.1)
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func toggle_sfx_mute() -> void:
	sfx_muted = not sfx_muted
	sfx_mute_changed.emit(sfx_muted)

func toggle_music_mute() -> void:
	music_muted = not music_muted
	if music_muted:
		music_player.stop()
	else:
		music_player.play()
	music_mute_changed.emit(music_muted)
