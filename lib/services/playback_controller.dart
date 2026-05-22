import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class PlaybackController extends ChangeNotifier {
  PlaybackController._() {
    _stateSubscription = audioPlayer.playerStateStream.listen((state) {
      isPlaying = state.playing;
      notifyListeners();
    });
    _durationSubscription = audioPlayer.durationStream.listen((value) {
      duration = value ?? Duration.zero;
      notifyListeners();
    });
    _positionSubscription = audioPlayer.positionStream.listen((value) {
      position = value;
    });
  }

  static final PlaybackController instance = PlaybackController._();

  final AudioPlayer audioPlayer = AudioPlayer();
  late final StreamSubscription<PlayerState> _stateSubscription;
  late final StreamSubscription<Duration?> _durationSubscription;
  late final StreamSubscription<Duration> _positionSubscription;

  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String? source;
  String title = 'Not Playing';
  String artist = 'Apple Music';
  String album = '';
  int? artworkId;
  String? artworkUrl;
  bool isLocalTrack = false;
  int? remoteIndex;

  bool get hasTrack => source != null || artworkUrl != null;

  void setMetadata({
    required String title,
    required String artist,
    required String album,
    required bool isLocalTrack,
    String? source,
    int? artworkId,
    String? artworkUrl,
    int? remoteIndex,
  }) {
    this.title = title;
    this.artist = artist;
    this.album = album;
    this.isLocalTrack = isLocalTrack;
    this.source = source;
    this.artworkId = artworkId;
    this.artworkUrl = artworkUrl;
    this.remoteIndex = remoteIndex;
    notifyListeners();
  }

  Future<void> playPause() async {
    if (isPlaying) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play();
    }
  }

  Future<void> seek(Duration value) => audioPlayer.seek(value);

  Future<void> setVolume(double value) => audioPlayer.setVolume(value);

  @override
  void dispose() {
    _stateSubscription.cancel();
    _durationSubscription.cancel();
    _positionSubscription.cancel();
    audioPlayer.dispose();
    super.dispose();
  }
}
