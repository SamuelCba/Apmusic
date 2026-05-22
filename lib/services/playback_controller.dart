import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:palette_generator/palette_generator.dart';

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
        unawaited(_updateLocalPalette(song));
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
        unawaited(_updateRemotePalette(song['image']?.toString()));
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
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final Map<int, Uint8List?> _localArtworkBytesCache = {};
  final Map<int, Uri?> _localArtworkUriCache = {};
  List<Color> backgroundGradient = const [
    Color(0xFF5A421B),
    Color(0xFF242426),
    Color(0xFF121212),
  ];
  int _paletteRequestId = 0;

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

  Color _deepen(Color color, double amount) {
    return Color.lerp(color, Colors.black, amount) ?? color;
  }

  Color _paletteColor(PaletteGenerator palette) {
    return palette.dominantColor?.color ??
        palette.vibrantColor?.color ??
        palette.darkVibrantColor?.color ??
        palette.mutedColor?.color ??
        backgroundGradient.first;
  }

  void _setFallbackPalette() {
    _paletteRequestId++;
    backgroundGradient = const [
      Color(0xFF5A421B),
      Color(0xFF242426),
      Color(0xFF121212),
    ];
    notifyListeners();
  }

  Future<void> _updatePaletteFromProvider(ImageProvider provider) async {
    final requestId = ++_paletteRequestId;
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        provider,
        size: const Size(220, 220),
        maximumColorCount: 16,
      );
      if (requestId != _paletteRequestId) return;

      final primary = _paletteColor(palette);
      final secondary = palette.darkMutedColor?.color ??
          palette.mutedColor?.color ??
          palette.darkVibrantColor?.color ??
          primary;
      backgroundGradient = [
        _deepen(primary, 0.44),
        _deepen(secondary, 0.62),
        const Color(0xFF121212),
      ];
      notifyListeners();
    } catch (_) {
      if (requestId == _paletteRequestId) {
        backgroundGradient = const [
          Color(0xFF5A421B),
          Color(0xFF242426),
          Color(0xFF121212),
        ];
        notifyListeners();
      }
    }
  }

  Future<void> _updateRemotePalette(String? artworkUrl) async {
    if (artworkUrl == null || artworkUrl.isEmpty) {
      _setFallbackPalette();
      return;
    }
    final uri = Uri.tryParse(artworkUrl);
    if (uri == null) {
      _setFallbackPalette();
      return;
    }
    await _updatePaletteFromProvider(NetworkImage(uri.toString()));
  }

  Future<Uint8List?> _localArtworkBytes(SongModel song) async {
    if (_localArtworkBytesCache.containsKey(song.id)) {
      return _localArtworkBytesCache[song.id];
    }

    try {
      final bytes = await _audioQuery.queryArtwork(
        song.id,
        ArtworkType.AUDIO,
        format: ArtworkFormat.JPEG,
        size: 900,
        quality: 100,
      );
      _localArtworkBytesCache[song.id] = bytes == null || bytes.isEmpty ? null : bytes;
      return _localArtworkBytesCache[song.id];
    } catch (_) {
      _localArtworkBytesCache[song.id] = null;
      return null;
    }
  }

  Future<void> _updateLocalPalette(SongModel song) async {
    final bytes = await _localArtworkBytes(song);
    if (bytes == null || bytes.isEmpty) {
      _setFallbackPalette();
      return;
    }
    await _updatePaletteFromProvider(MemoryImage(bytes));
  }

  Future<Uri?> _localArtworkUri(SongModel song) async {
    if (_localArtworkUriCache.containsKey(song.id)) {
      return _localArtworkUriCache[song.id];
    }

    try {
      final bytes = await _localArtworkBytes(song);
      if (bytes == null || bytes.isEmpty) {
        _localArtworkUriCache[song.id] = null;
        return null;
      }

      final directory = Directory('${Directory.systemTemp.path}/apmusic_artwork');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final file = File('${directory.path}/${song.id}.jpg');
      await file.writeAsBytes(bytes, flush: true);
      final uri = file.uri;
      _localArtworkUriCache[song.id] = uri;
      return uri;
    } catch (_) {
      _localArtworkUriCache[song.id] = null;
      return null;
    }
  }

  Future<MediaItem> _localMediaItem(SongModel song) async {
    return MediaItem(
      id: song.data,
      album: song.album ?? 'Unknown album',
      title: song.title,
      artist: song.artist ?? 'Unknown artist',
      artUri: await _localArtworkUri(song),
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
    unawaited(_updateRemotePalette(current['image']?.toString()));
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
    final queue = List<SongModel>.from(songs);
    localQueue = queue;
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
    unawaited(_updateLocalPalette(current));
    final mediaItems = await Future.wait([
      for (final song in queue) _localMediaItem(song),
    ]);
    final playlist = ConcatenatingAudioSource(
      children: [
        for (var i = 0; i < queue.length; i++)
          AudioSource.uri(
            Uri.file(queue[i].data),
            tag: mediaItems[i],
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
