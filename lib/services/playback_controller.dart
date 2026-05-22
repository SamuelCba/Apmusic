import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

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
    _currentIndexSubscription = audioPlayer.currentIndexStream.listen((index) {
      if (index == null) return;
      if (isLocalTrack && index >= 0 && index < localQueue.length) {
        final song = localQueue[index];
        _setMetadataSilently(
          title: song.title,
          artist: song.artist ?? 'Unknown artist',
          album: song.album ?? 'Unknown album',
          isLocalTrack: true,
          source: song.data,
          artworkId: song.id,
          remoteIndex: null,
        );
      } else if (!isLocalTrack && index >= 0 && index < remoteQueue.length) {
        final song = remoteQueue[index];
        _setMetadataSilently(
          title: song['title']?.toString() ?? 'Unknown title',
          artist: song['artist']?.toString() ?? 'Unknown artist',
          album: song['album']?.toString() ?? 'Unknown album',
          isLocalTrack: false,
          source: song['source']?.toString(),
          artworkUrl: song['image']?.toString(),
          remoteIndex: index,
        );
      }
      notifyListeners();
    });
  }

  static final PlaybackController instance = PlaybackController._();

  final AudioPlayer audioPlayer = AudioPlayer();
  late final StreamSubscription<PlayerState> _stateSubscription;
  late final StreamSubscription<Duration?> _durationSubscription;
  late final StreamSubscription<Duration> _positionSubscription;
  late final StreamSubscription<int?> _currentIndexSubscription;

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
  List<SongModel> localQueue = [];
  List<Map<String, dynamic>> remoteQueue = [];

  bool get hasTrack => source != null || artworkUrl != null;
  bool get canGoPrevious => audioPlayer.hasPrevious;
  bool get canGoNext => audioPlayer.hasNext;

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

  void _setMetadataSilently({
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
  }

  MediaItem _remoteMediaItem(Map<String, dynamic> song, int index) {
    final imageUrl = song['image']?.toString();
    return MediaItem(
      id: song['id']?.toString() ?? 'remote-$index',
      album: song['album']?.toString() ?? 'Unknown album',
      title: song['title']?.toString() ?? 'Unknown title',
      artist: song['artist']?.toString() ?? 'Unknown artist',
      artUri: imageUrl == null || imageUrl.isEmpty ? null : Uri.tryParse(imageUrl),
    );
  }

  MediaItem _localMediaItem(SongModel song) {
    return MediaItem(
      id: song.data,
      album: song.album ?? 'Unknown album',
      title: song.title,
      artist: song.artist ?? 'Unknown artist',
    );
  }

  Future<void> playRemoteQueue(List<dynamic> songs, int index) async {
    final queue = songs
        .whereType<Map>()
        .map((song) => Map<String, dynamic>.from(song))
        .where((song) => song['source'] != null)
        .toList();
    if (queue.isEmpty) return;
    final safeIndex = index.clamp(0, queue.length - 1).toInt();
    remoteQueue = queue;
    localQueue = [];
    final current = queue[safeIndex];
    setMetadata(
      title: current['title']?.toString() ?? 'Unknown title',
      artist: current['artist']?.toString() ?? 'Unknown artist',
      album: current['album']?.toString() ?? 'Unknown album',
      isLocalTrack: false,
      source: current['source']?.toString(),
      artworkUrl: current['image']?.toString(),
      remoteIndex: safeIndex,
    );
    final playlist = ConcatenatingAudioSource(
      children: [
        for (var i = 0; i < queue.length; i++)
          AudioSource.uri(
            Uri.parse(queue[i]['source'].toString()),
            tag: _remoteMediaItem(queue[i], i),
          ),
      ],
    );
    await audioPlayer.stop();
    await audioPlayer.setAudioSource(playlist, initialIndex: safeIndex);
    await audioPlayer.play();
  }

  Future<void> playLocalQueue(List<SongModel> songs, int index) async {
    if (songs.isEmpty) return;
    final safeIndex = index.clamp(0, songs.length - 1).toInt();
    localQueue = List<SongModel>.from(songs);
    remoteQueue = [];
    final current = localQueue[safeIndex];
    setMetadata(
      title: current.title,
      artist: current.artist ?? 'Unknown artist',
      album: current.album ?? 'Unknown album',
      isLocalTrack: true,
      source: current.data,
      artworkId: current.id,
    );
    final playlist = ConcatenatingAudioSource(
      children: [
        for (final song in localQueue)
          AudioSource.uri(
            Uri.file(song.data),
            tag: _localMediaItem(song),
          ),
      ],
    );
    await audioPlayer.stop();
    await audioPlayer.setAudioSource(playlist, initialIndex: safeIndex);
    await audioPlayer.play();
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

  Future<void> skipPrevious() async {
    if (audioPlayer.hasPrevious) await audioPlayer.seekToPrevious();
  }

  Future<void> skipNext() async {
    if (audioPlayer.hasNext) await audioPlayer.seekToNext();
  }

  @override
  void dispose() {
    _stateSubscription.cancel();
    _durationSubscription.cancel();
    _positionSubscription.cancel();
    _currentIndexSubscription.cancel();
    audioPlayer.dispose();
    super.dispose();
  }
}
