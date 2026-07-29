import 'package:audioplayers/audioplayers.dart';

class SoundHelper {
    // Singleton
    static final SoundHelper _instance = SoundHelper._internal();
    factory SoundHelper() => _instance;
    SoundHelper._internal();
    
    final AudioPlayer _player = AudioPlayer();

    Future<void> playBeep() async {
        await _player.stop(); // Stop any currently playing sound
        await _player.play(AssetSource('sounds/beep-sound.mp3'));
    }

}