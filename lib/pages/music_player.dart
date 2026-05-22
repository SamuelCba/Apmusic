import 'dart:async';

// import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

import '../models/lyrics.dart';
import '../services/music_library_controller.dart';
import '../services/playback_controller.dart';
import '../services/lyrics_service.dart';
import '../widgets/apple_music_player_widgets.dart';
import 'package:palette_generator/palette_generator.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({super.key});

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  List song = [
    {
      "id": "wake_up_01",
      "title": "Intro - The Way Of Waking Up (feat. Alan Watts)",
      "album": "Wake Up",
      "artist": "The Kyoto Connection",
      "genre": "Electronic",
      "source": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/01_-_Intro_-_The_Way_Of_Waking_Up_feat_Alan_Watts.mp3",
      "image": "https://d1csarkz8obe9u.cloudfront.net/posterpreviews/love-song-mixtape-album-cover-template-design-250a66b33422287542e2690b437f881b_screen.jpg?ts=1635176340",
      "trackNumber": 1,
      "totalTrackCount": 13,
      "duration": 90,
      "site": "http://freemusicarchive.org/music/The_Kyoto_Connection/Wake_Up_1957/"
    },
    {
      "id": "wake_up_02",
      "title": "Geisha",
      "album": "Wake Up",
      "artist": "The Kyoto Connection",
      "genre": "Electronic",
      "source": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/02_-_Geisha.mp3",
      "image": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/art.jpg",
      "trackNumber": 2,
      "totalTrackCount": 13,
      "duration": 267,
      "site": "http://freemusicarchive.org/music/The_Kyoto_Connection/Wake_Up_1957/"
    },
    {
      "id": "wake_up_03",
      "title": "Voyage I - Waterfall",
      "album": "Wake Up",
      "artist": "The Kyoto Connection",
      "genre": "Electronic",
      "source": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/03_-_Voyage_I_-_Waterfall.mp3",
      "image": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/art.jpg",
      "trackNumber": 3,
      "totalTrackCount": 13,
      "duration": 264,
      "site": "http://freemusicarchive.org/music/The_Kyoto_Connection/Wake_Up_1957/"
    },
    {
      "id": "wake_up_04",
      "title": "The Music In You",
      "album": "Wake Up",
      "artist": "The Kyoto Connection",
      "genre": "Electronic",
      "source": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/04_-_The_Music_In_You.mp3",
      "image": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/art.jpg",
      "trackNumber": 4,
      "totalTrackCount": 13,
      "duration": 223,
      "site": "http://freemusicarchive.org/music/The_Kyoto_Connection/Wake_Up_1957/"
    },
    {
      "id": "wake_up_05",
      "title": "The Calm Before The Storm",
      "album": "Wake Up",
      "artist": "The Kyoto Connection",
      "genre": "Electronic",
      "source": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/05_-_The_Calm_Before_The_Storm.mp3",
      "image": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/art.jpg",
      "trackNumber": 5,
      "totalTrackCount": 13,
      "duration": 229,
      "site": "http://freemusicarchive.org/music/The_Kyoto_Connection/Wake_Up_1957/"
    },
    {
      "id": "wake_up_06",
      "title": "No Pain, No Gain",
      "album": "Wake Up",
      "artist": "The Kyoto Connection",
      "genre": "Electronic",
      "source": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/06_-_No_Pain_No_Gain.mp3",
      "image": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/art.jpg",
      "trackNumber": 6,
      "totalTrackCount": 13,
      "duration": 304,
      "site": "http://freemusicarchive.org/music/The_Kyoto_Connection/Wake_Up_1957/"
    },
    {
      "id": "wake_up_07",
      "title": "Voyage II - Satori",
      "album": "Wake Up",
      "artist": "The Kyoto Connection",
      "genre": "Electronic",
      "source": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/07_-_Voyage_II_-_Satori.mp3",
      "image": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/art.jpg",
      "trackNumber": 7,
      "totalTrackCount": 13,
      "duration": 256,
      "site": "http://freemusicarchive.org/music/The_Kyoto_Connection/Wake_Up_1957/"
    },
    {
      "id": "wake_up_08",
      "title": "Reveal the Magic",
      "album": "Wake Up",
      "artist": "The Kyoto Connection",
      "genre": "Electronic",
      "source": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/08_-_Reveal_the_Magic.mp3",
      "image": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/art.jpg",
      "trackNumber": 8,
      "totalTrackCount": 13,
      "duration": 293,
      "site": "http://freemusicarchive.org/music/The_Kyoto_Connection/Wake_Up_1957/"
    },
    {
      "id": "wake_up_09",
      "title": "Hachiko (The Faithtful Dog)",
      "album": "Wake Up",
      "artist": "The Kyoto Connection",
      "genre": "Electronic",
      "source": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/09_-_Hachiko_The_Faithtful_Dog.mp3",
      "image": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/art.jpg",
      "trackNumber": 9,
      "totalTrackCount": 13,
      "duration": 185,
      "site": "http://freemusicarchive.org/music/The_Kyoto_Connection/Wake_Up_1957/"
    },
    {
      "id": "wake_up_10",
      "title": "Wake Up",
      "album": "Wake Up",
      "artist": "The Kyoto Connection",
      "genre": "Electronic",
      "source": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/10_-_Wake_Up.mp3",
      "image": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/art.jpg",
      "trackNumber": 10,
      "totalTrackCount": 13,
      "duration": 251,
      "site": "http://freemusicarchive.org/music/The_Kyoto_Connection/Wake_Up_1957/"
    },
    {
      "id": "wake_up_11",
      "title": "Voyage III - The Space Between Us",
      "album": "Wake Up",
      "artist": "The Kyoto Connection",
      "genre": "Electronic",
      "source": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/11_-_Voyage_III_-_The_Space_Between_Us.mp3",
      "image": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/art.jpg",
      "trackNumber": 11,
      "totalTrackCount": 13,
      "duration": 290,
      "site": "http://freemusicarchive.org/music/The_Kyoto_Connection/Wake_Up_1957/"
    },
    {
      "id": "wake_up_12",
      "title": "Ume No Kaori (feat. Sunawai)",
      "album": "Wake Up",
      "artist": "The Kyoto Connection",
      "genre": "Electronic",
      "source": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/12_-_Ume_No_Kaori_feat_Sunawai.mp3",
      "image": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/art.jpg",
      "trackNumber": 12,
      "totalTrackCount": 13,
      "duration": 334,
      "site": "http://freemusicarchive.org/music/The_Kyoto_Connection/Wake_Up_1957/"
    },
    {
      "id": "wake_up_13",
      "title": "Outro - Totally Here and Now (feat. Alan Watts)",
      "album": "Wake Up",
      "artist": "The Kyoto Connection",
      "genre": "Electronic",
      "source": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/13_-_Outro_-_Totally_Here_and_Now_feat_Alan_Watts.mp3",
      "image": "https://storage.googleapis.com/uamp/The_Kyoto_Connection_-_Wake_Up/art.jpg",
      "trackNumber": 13,
      "totalTrackCount": 13,
      "duration": 242,
      "site": "http://freemusicarchive.org/music/The_Kyoto_Connection/Wake_Up_1957/"
    },
    {
      "id": "jazz_in_paris",
      "title": "Jazz in Paris",
      "album": "Jazz & Blues",
      "artist": "Media Right Productions",
      "genre": "Jazz & Blues",
      "source": "https://storage.googleapis.com/automotive-media/Jazz_In_Paris.mp3",
      "image": "https://storage.googleapis.com/automotive-media/album_art.jpg",
      "trackNumber": 1,
      "totalTrackCount": 6,
      "duration": 103,
      "site": "https://www.youtube.com/audiolibrary/music"
    },
    {
      "id": "the_messenger",
      "title": "The Messenger",
      "album": "Jazz & Blues",
      "artist": "Silent Partner",
      "genre": "Jazz & Blues",
      "source": "https://storage.googleapis.com/automotive-media/The_Messenger.mp3",
      "image": "https://storage.googleapis.com/automotive-media/album_art.jpg",
      "trackNumber": 2,
      "totalTrackCount": 6,
      "duration": 132,
      "site": "https://www.youtube.com/audiolibrary/music"
    },
    {
      "id": "talkies",
      "title": "Talkies",
      "album": "Jazz & Blues",
      "artist": "Huma-Huma",
      "genre": "Jazz & Blues",
      "source": "https://storage.googleapis.com/automotive-media/Talkies.mp3",
      "image": "https://storage.googleapis.com/automotive-media/album_art.jpg",
      "trackNumber": 3,
      "totalTrackCount": 6,
      "duration": 162,
      "site": "https://www.youtube.com/audiolibrary/music"
    },
    {
      "id": "on_the_bach",
      "title": "On the Bach",
      "album": "Cinematic",
      "artist": "Jingle Punks",
      "genre": "Cinematic",
      "source": "https://storage.googleapis.com/automotive-media/On_the_Bach.mp3",
      "image": "https://storage.googleapis.com/automotive-media/album_art.jpg",
      "trackNumber": 4,
      "totalTrackCount": 6,
      "duration": 66,
      "site": "https://www.youtube.com/audiolibrary/music"
    },
    {
      "id": "the_story_unfolds",
      "title": "The Story Unfolds",
      "album": "Cinematic",
      "artist": "Jingle Punks",
      "genre": "Cinematic",
      "source": "https://storage.googleapis.com/automotive-media/The_Story_Unfolds.mp3",
      "image": "https://storage.googleapis.com/automotive-media/album_art.jpg",
      "trackNumber": 5,
      "totalTrackCount": 6,
      "duration": 91,
      "site": "https://www.youtube.com/audiolibrary/music"
    },
    {
      "id": "drop_and_roll",
      "title": "Drop and Roll",
      "album": "Youtube Audio Library Rock",
      "artist": "Silent Partner",
      "genre": "Rock",
      "source": "https://storage.googleapis.com/automotive-media/Drop_and_Roll.mp3",
      "image": "https://storage.googleapis.com/automotive-media/album_art_2.jpg",
      "trackNumber": 1,
      "totalTrackCount": 7,
      "duration": 121,
      "site": "https://www.youtube.com/audiolibrary/music"
    },
    {
      "id": "motocross",
      "title": "Motocross",
      "album": "Youtube Audio Library Rock",
      "artist": "Topher Mohr and Alex Elena",
      "genre": "Rock",
      "source": "https://storage.googleapis.com/automotive-media/Motocross.mp3",
      "image": "https://storage.googleapis.com/automotive-media/album_art_2.jpg",
      "trackNumber": 2,
      "totalTrackCount": 7,
      "duration": 182,
      "site": "https://www.youtube.com/audiolibrary/music"
    },
    {
      "id": "wish_youd_come_true",
      "title": "Wish You'd Come True",
      "album": "Youtube Audio Library Rock",
      "artist": "The 126ers",
      "genre": "Rock",
      "source": "https://storage.googleapis.com/automotive-media/Wish_You_d_Come_True.mp3",
      "image": "https://storage.googleapis.com/automotive-media/album_art_2.jpg",
      "trackNumber": 3,
      "totalTrackCount": 7,
      "duration": 169,
      "site": "https://www.youtube.com/audiolibrary/music"
    },
    {
      "id": "awakening",
      "title": "Awakening",
      "album": "Youtube Audio Library Rock",
      "artist": "Silent Partner",
      "genre": "Rock",
      "source": "https://storage.googleapis.com/automotive-media/Awakening.mp3",
      "image": "https://storage.googleapis.com/automotive-media/album_art_2.jpg",
      "trackNumber": 4,
      "totalTrackCount": 7,
      "duration": 220,
      "site": "https://www.youtube.com/audiolibrary/music"
    },
    {
      "id": "home",
      "title": "Home",
      "album": "Youtube Audio Library Rock",
      "artist": "Letter Box",
      "genre": "Rock",
      "source": "https://storage.googleapis.com/automotive-media/Home.mp3",
      "image": "https://storage.googleapis.com/automotive-media/album_art_2.jpg",
      "trackNumber": 5,
      "totalTrackCount": 7,
      "duration": 213,
      "site": "https://www.youtube.com/audiolibrary/music"
    },
    {
      "id": "tell_the_angels",
      "title": "Tell The Angels",
      "album": "Youtube Audio Library Rock",
      "artist": "Letter Box",
      "genre": "Rock",
      "source": "https://storage.googleapis.com/automotive-media/Tell_The_Angels.mp3",
      "image": "https://storage.googleapis.com/automotive-media/album_art_2.jpg",
      "trackNumber": 6,
      "totalTrackCount": 7,
      "duration": 208,
      "site": "https://www.youtube.com/audiolibrary/music"
    },
    {
      "id": "hey_sailor",
      "title": "Hey Sailor",
      "album": "Youtube Audio Library Rock",
      "artist": "Letter Box",
      "genre": "Rock",
      "source": "https://storage.googleapis.com/automotive-media/Hey_Sailor.mp3",
      "image": "https://storage.googleapis.com/automotive-media/album_art_2.jpg",
      "trackNumber": 7,
      "totalTrackCount": 7,
      "duration": 193,
      "site": "https://www.youtube.com/audiolibrary/music"
    },
    {
      "id": "keys_to_the_kingdom",
      "title": "Keys To The Kingdom",
      "album": "Youtube Audio Library Rock 2",
      "artist": "The 126ers",
      "genre": "Rock",
      "source": "https://storage.googleapis.com/automotive-media/Keys_To_The_Kingdom.mp3",
      "image": "https://storage.googleapis.com/automotive-media/album_art_3.jpg",
      "trackNumber": 1,
      "totalTrackCount": 2,
      "duration": 221,
      "site": "https://www.youtube.com/audiolibrary/music"
    },
    {
      "id": "the_coldest_shoulder",
      "title": "The Coldest Shoulder",
      "album": "Youtube Audio Library Rock 2",
      "artist": "The 126ers",
      "genre": "Rock",
      "source": "https://storage.googleapis.com/automotive-media/The_Coldest_Shoulder.mp3",
      "image": "https://storage.googleapis.com/automotive-media/album_art_3.jpg",
      "trackNumber": 2,
      "totalTrackCount": 2,
      "duration": 160,
      "site": "https://www.youtube.com/audiolibrary/music"
    },
    {
      "id": "spatial_01",
      "title": "Pre-game marching band",
      "album": "Spatial Audio",
      "artist": "Watson Wu",
      "genre": "People",
      "source": "https://storage.googleapis.com/uamp/Spatial Audio/Marching band.wav",
      "image": "https://storage.googleapis.com/uamp/Spatial Audio/Marching band.jpg",
      "trackNumber": 1,
      "totalTrackCount": 6,
      "duration": 56,
      "site": "https://library.soundfield.com/track/163"
    },
    {
      "id": "spatial_02",
      "title": "Chickens on a farm",
      "album": "Spatial Audio",
      "artist": "Watson Wu",
      "genre": "Animals",
      "source": "https://storage.googleapis.com/uamp/Spatial Audio/Chickens.wav",
      "image": "https://storage.googleapis.com/uamp/Spatial Audio/Chickens.jpg",
      "trackNumber": 2,
      "totalTrackCount": 6,
      "duration": 180,
      "site": "https://library.soundfield.com/track/129"
    },
    {
      "id": "spatial_03",
      "title": "Rural market busker",
      "album": "Spatial Audio",
      "artist": "Stephan Schutze",
      "genre": "Ambience",
      "source": "https://storage.googleapis.com/uamp/Spatial Audio/Rural market.wav",
      "image": "https://storage.googleapis.com/uamp/Spatial Audio/Rural market.jpg",
      "trackNumber": 3,
      "totalTrackCount": 6,
      "duration": 299,
      "site": "https://library.soundfield.com/track/55"
    },
    {
      "id": "spatial_04",
      "title": "Steamtrain interior",
      "album": "Spatial Audio",
      "artist": "Stephan Schutze",
      "genre": "Ambience",
      "source": "https://storage.googleapis.com/uamp/Spatial Audio/Steamtrain.wav",
      "image": "https://storage.googleapis.com/uamp/Spatial Audio/Steamtrain.jpg",
      "trackNumber": 4,
      "totalTrackCount": 6,
      "duration": 296,
      "site": "https://library.soundfield.com/track/65"
    },
    {
      "id": "spatial_05",
      "title": "Rural road car pass",
      "album": "Spatial Audio",
      "artist": "Stephan Schutze",
      "genre": "Ambience",
      "source": "https://storage.googleapis.com/uamp/Spatial Audio/Car pass.wav",
      "image": "https://i.pinimg.com/474x/63/d8/c2/63d8c24d77ea080d1a8dcb1cca2a683e.jpg",
      "trackNumber": 5,
      "totalTrackCount": 6,
      "duration": 302,
      "site": "https://library.soundfield.com/track/57"
    },
    {
      "id": "spatial_06",
      "title": "10 feet from shore",
      "album": "Spatial Audio",
      "artist": "Watson Wu",
      "genre": "Ambience",
      "source": "https://storage.googleapis.com/uamp/Spatial Audio/Shore.wav",
      "image": "https://i.pinimg.com/474x/aa/ec/28/aaec2887892340a23889a4e98d44afcb.jpg",
      "trackNumber": 6,
      "totalTrackCount": 6,
      "duration": 180,
      "site": "https://library.soundfield.com/track/114"
    }
  ];

  //variable for music audioPlayer
  late final AudioPlayer audioPlayer;
  final PlaybackController _playbackController = PlaybackController.instance;
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final MusicLibraryController _libraryController = MusicLibraryController.instance;
  final PageController _playerPageController = PageController();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  int currentIndex = 0;
  bool isLoading = false;
  bool _isLocalTrack = false;
  bool _showLyrics = false;
  bool _queuePageActive = false;
  bool _lyricsLoading = false;
  String? _lyricsError;
  LyricsData? _lyricsData;
  int _activeLyricIndex = -1;
  String? _localSource;
  String? _localTitle;
  String? _localArtist;
  String? _localAlbum;
  int? _localArtworkId;
  double _volume = 1.0;
  final ScrollController _lyricsScrollController = ScrollController();
  final Map<int, GlobalKey> _lyricKeys = {};
  final LyricsService _lyricsService = const LyricsService();
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<ProcessingState>? _processingStateSubscription;

  @override
  void initState() {
    super.initState();
    // Initialize audio player
    audioPlayer = _playbackController.audioPlayer;
    unawaited(audioPlayer.setVolume(_volume));
    unawaited(_libraryController.ensureLoaded());
    setupAudioPlayer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routes = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (routes != null && routes['source'] != null) {
        setState(() {
          _isLocalTrack = true;
          _localSource = routes['source'] as String;
          _localTitle = routes['title'] as String?;
          _localArtist = routes['artist'] as String?;
          _localAlbum = routes['album'] as String?;
          _localArtworkId = routes['artworkId'] as int?;
          _showLyrics = false;
        });
        _loadLocalSong();
      } else if (routes != null && routes.containsKey('index')) {
        setState(() {
          currentIndex = routes['index'] as int;
          _isLocalTrack = false;
          _showLyrics = false;
        });
        _updatePaletteGenerator(currentIndex);
        changeImage(currentIndex);
        _loadSong(currentIndex);
      } else {
        if (_playbackController.hasTrack) {
          setState(() {
            _isLocalTrack = _playbackController.isLocalTrack;
            _localSource = _playbackController.source;
            _localTitle = _playbackController.title;
            _localArtist = _playbackController.artist;
            _localAlbum = _playbackController.album;
            _localArtworkId = _playbackController.artworkId;
            if (!_playbackController.isLocalTrack && _playbackController.remoteIndex != null) {
              currentIndex = _playbackController.remoteIndex!;
            }
            isPlaying = _playbackController.isPlaying;
            duration = _playbackController.duration;
            position = _playbackController.position;
          });
          return;
        }
        _isLocalTrack = false;
        _showLyrics = false;
        _updatePaletteGenerator(currentIndex);
        changeImage(currentIndex);
        // Load the first song by default
        _loadSong(currentIndex);
      }
    });
  }

  void setupAudioPlayer() {
    // Listen to player state changes
    _playerStateSubscription = audioPlayer.playerStateStream.listen((PlayerState state) {
      if (!mounted) return;
      setState(() {
        isPlaying = state.playing;
      });
    });

    // Listen to duration changes
    _durationSubscription = audioPlayer.durationStream.listen((newDuration) {
      if (!mounted) return;
      setState(() {
        duration = newDuration ?? Duration.zero;
      });
    });

    // Listen to position changes
    _positionSubscription = audioPlayer.positionStream.listen((newPosition) {
      if (!mounted) return;
      setState(() {
        position = newPosition;
      });
      _updateLyricPosition(newPosition);
    });

    // Listen to sequence state for completion
    _processingStateSubscription = audioPlayer.processingStateStream.listen((state) {
      if (!mounted) return;
      if (state == ProcessingState.completed) {
        setState(() {
          position = Duration.zero;
          isPlaying = false;
        });
        if (_isLocalTrack && _canGoNext) {
          _skipNext();
        } else if (!_isLocalTrack && currentIndex < song.length - 1) {
          currentIndex++;
          unawaited(_loadSong(currentIndex));
        }
      }
    });
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _processingStateSubscription?.cancel();
    _playerPageController.dispose();
    _lyricsScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSong(int index) async {
    setState(() {
      isLoading = true;
      _isLocalTrack = false;
      _showLyrics = false;
      _lyricsData = null;
      _lyricsError = null;
      _activeLyricIndex = -1;
      currentIndex = index;
    });
    _playbackController.setMetadata(
      title: song[index]['title'].toString(),
      artist: song[index]['artist'].toString(),
      album: song[index]['album'].toString(),
      isLocalTrack: false,
      source: song[index]['source'].toString(),
      artworkUrl: song[index]['image'].toString(),
      remoteIndex: index,
    );

    try {
      await audioPlayer.stop();
      await audioPlayer.setUrl(song[index]['source'].toString());
      await audioPlayer.play();
      await _updatePaletteGenerator(index);
      await _loadLyricsForTrack(
        artist: song[index]['artist']?.toString() ?? 'Unknown artist',
        title: song[index]['title']?.toString() ?? 'Unknown title',
        durationSeconds: song[index]['duration'] is int
            ? song[index]['duration'] as int
            : null,
      );
    } catch (e) {
      print('Error loading song: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing song: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadLocalSong() async {
    final source = _localSource;
    if (source == null) return;

    setState(() {
      isLoading = true;
      colors = [
        const Color(0xFF202020),
        const Color(0xFF000000),
      ];
      _lyricsData = null;
      _lyricsError = null;
      _activeLyricIndex = -1;
    });
    _playbackController.setMetadata(
      title: _localTitle ?? 'Local track',
      artist: _localArtist ?? 'Unknown artist',
      album: _localAlbum ?? 'Unknown album',
      isLocalTrack: true,
      source: source,
      artworkId: _localArtworkId,
    );

    try {
      await audioPlayer.stop();
      await audioPlayer.setFilePath(source);
      await audioPlayer.play();
      await _loadLyricsForTrack(
        artist: _localArtist ?? 'Unknown artist',
        title: _localTitle ?? 'Local track',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing local file: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadLocalSongModel(SongModel songModel) async {
    setState(() {
      _isLocalTrack = true;
      _localSource = songModel.data;
      _localTitle = songModel.title;
      _localArtist = songModel.artist ?? 'Unknown artist';
      _localAlbum = songModel.album ?? 'Unknown album';
      _localArtworkId = songModel.id;
      _showLyrics = false;
    });
    await _loadLocalSong();
  }

  int get _currentLocalQueueIndex {
    if (!_isLocalTrack || _localSource == null) return -1;
    return _libraryController.visibleSongs.indexWhere((song) => song.data == _localSource);
  }

  bool get _canGoPrevious {
    if (_isLocalTrack) return _currentLocalQueueIndex > 0;
    return currentIndex > 0;
  }

  bool get _canGoNext {
    if (_isLocalTrack) {
      final index = _currentLocalQueueIndex;
      return index >= 0 && index < _libraryController.visibleSongs.length - 1;
    }
    return currentIndex < song.length - 1;
  }

  void _skipPrevious() {
    if (_isLocalTrack) {
      final index = _currentLocalQueueIndex;
      if (index > 0) {
        unawaited(_loadLocalSongModel(_libraryController.visibleSongs[index - 1]));
      }
      return;
    }

    if (currentIndex > 0) {
      unawaited(_loadSong(currentIndex - 1));
    }
  }

  void _skipNext() {
    if (_isLocalTrack) {
      final index = _currentLocalQueueIndex;
      if (index >= 0 && index < _libraryController.visibleSongs.length - 1) {
        unawaited(_loadLocalSongModel(_libraryController.visibleSongs[index + 1]));
      }
      return;
    }

    if (currentIndex < song.length - 1) {
      unawaited(_loadSong(currentIndex + 1));
    }
  }

  String formatTime(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

////////////
  PaletteGenerator? paletteGenerator;
  List<Color> colors = [
    Colors.white,
    Colors.black
  ];

  Future<void> _updatePaletteGenerator(int index) async {
    if (_isLocalTrack) {
      return;
    }
    try {
      final imageUrl = song[index]['image'];
      paletteGenerator = await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl.toString()),
        size: const Size(200, 200),
      );

      if (paletteGenerator != null && paletteGenerator!.colors.isNotEmpty) {
        setState(() {
          colors = [
            paletteGenerator!.dominantColor?.color ?? colors[0],
            paletteGenerator!.mutedColor?.color ?? colors[1],
          ];
        });
      }
    } catch (e) {
      print('Error generating palette: $e');
    }
  }

  void changeImage(int newIndex) async {
    if (_isLocalTrack) return;
    setState(() {
      currentIndex = newIndex;
    });
    await _updatePaletteGenerator(currentIndex);
  }

  Future<void> _loadLyricsForTrack({
    required String artist,
    required String title,
    int? durationSeconds,
  }) async {
    if (!mounted) return;
    setState(() {
      _lyricsLoading = true;
      _lyricsError = null;
      _lyricsData = null;
      _activeLyricIndex = -1;
    });

    try {
      final lyrics = await _lyricsService.fetchLyrics(
        artist: artist,
        title: title,
        durationSeconds: durationSeconds,
      );

      if (!mounted) return;

      setState(() {
        _lyricsData = lyrics;
        _lyricsError = lyrics == null ? 'No lyrics found for this track.' : null;
        _lyricsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _lyricsData = null;
        _lyricsError = 'Failed to load lyrics.';
        _lyricsLoading = false;
      });
    }
  }

  void _toggleLyrics() {
    setState(() {
      _showLyrics = !_showLyrics;
    });
    if (_showLyrics && _activeLyricIndex >= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollLyricIntoView(_activeLyricIndex);
      });
    }
  }

  void _showQueuePage() {
    setState(() {
      _showLyrics = false;
      _queuePageActive = true;
    });
    _playerPageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 430),
      curve: Curves.easeOutCubic,
    );
  }

  void _showPlayerPage() {
    setState(() {
      _queuePageActive = false;
    });
    _playerPageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 430),
      curve: Curves.easeOutCubic,
    );
  }

  void _showAirPlayNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AirPlay controls are visual in this build.')),
    );
  }

  void _updateLyricPosition(Duration currentPosition) {
    final lyrics = _lyricsData;
    if (lyrics == null || lyrics.lines.isEmpty) return;

    final newIndex = lyrics.activeIndex(currentPosition);
    if (newIndex == _activeLyricIndex) return;

    _activeLyricIndex = newIndex;
    if (!mounted) return;
    setState(() {});
    if (_showLyrics && newIndex >= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollLyricIntoView(newIndex);
      });
    }
  }

  void _scrollLyricIntoView(int index) {
    final key = _lyricKeys[index];
    final context = key?.currentContext;
    if (context == null) return;

    Scrollable.ensureVisible(
      context,
      alignment: 0.45,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  String get _currentTitle =>
      _isLocalTrack
          ? (_localTitle ?? 'Local track')
          : song[currentIndex]['title'].toString();

  String get _currentArtist =>
      _isLocalTrack
          ? (_localArtist ?? 'Unknown artist')
          : song[currentIndex]['artist'].toString();

  String get _currentAlbum =>
      _isLocalTrack
          ? (_localAlbum ?? 'Unknown album')
          : song[currentIndex]['album'].toString();

  Widget _buildArtwork([double size = 360]) {
    if (_isLocalTrack) {
      final artworkId = _localArtworkId;
      if (artworkId != null) {
        return QueryArtworkWidget(
          id: artworkId,
          type: ArtworkType.AUDIO,
          artworkWidth: size,
          artworkHeight: size,
          artworkFit: BoxFit.cover,
          quality: 100,
          controller: _audioQuery,
          nullArtworkWidget: _artworkPlaceholder(size),
          errorBuilder: (_, __, ___) => _artworkPlaceholder(size),
        );
      }

      return _artworkPlaceholder(size);
    }

    return CachedNetworkImage(
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => _artworkPlaceholder(size),
      imageUrl: song[currentIndex]['image'].toString(),
      height: size,
      width: size,
      fit: BoxFit.cover,
    );
  }

  Widget _artworkPlaceholder([double size = 360]) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: const Color(0xFF202020),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(
        Icons.music_note_rounded,
        size: 84,
        color: Colors.white54,
      ),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.white,
            overlayColor: Colors.white24,
          ),
          child: Slider(
            min: 0,
            max: duration.inSeconds > 0 ? duration.inSeconds.toDouble() : 1,
            value: position.inSeconds.clamp(0, duration.inSeconds).toDouble(),
            onChanged: (value) async {
              final newPosition = Duration(seconds: value.toInt());
              await audioPlayer.seek(newPosition);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatTime(position),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                formatTime(duration - position),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(
            Icons.fast_rewind_rounded,
            size: 44,
            color: Colors.white,
          ),
          onPressed: !_isLocalTrack && currentIndex > 0
              ? () {
                  setState(() {
                    currentIndex--;
                  });
                  _loadSong(currentIndex);
                }
              : null,
        ),
        const SizedBox(width: 10),
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 34,
              color: Colors.black,
            ),
            onPressed: () {
              if (isPlaying) {
                audioPlayer.pause();
              } else {
                audioPlayer.play();
              }
            },
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(
            Icons.fast_forward_rounded,
            size: 44,
            color: Colors.white,
          ),
          onPressed: !_isLocalTrack && currentIndex < song.length - 1
              ? () {
                  setState(() {
                    currentIndex++;
                  });
                  _loadSong(currentIndex);
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildVolumeSection() {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              _volume == 0 ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: Colors.white70,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Slider(
                min: 0,
                max: 1,
                value: _volume.clamp(0.0, 1.0),
                onChanged: (value) {
                  setState(() {
                    _volume = value;
                  });
                  unawaited(audioPlayer.setVolume(value));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLyricsPanel() {
    final lyrics = _lyricsData;

    if (_lyricsLoading) {
      return const SizedBox(
        height: 240,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white70),
        ),
      );
    }

    if (lyrics == null || lyrics.lines.isEmpty) {
      return Container(
        height: 240,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Center(
          child: Text(
            _lyricsError ?? 'No lyrics available yet.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    for (var i = 0; i < lyrics.lines.length; i++) {
      _lyricKeys.putIfAbsent(i, () => GlobalKey());
    }

    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Row(
              children: [
                const Icon(Icons.lyrics_rounded, color: Colors.white70),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Lyrics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (_activeLyricIndex >= 0) {
                      _scrollLyricIntoView(_activeLyricIndex);
                    }
                  },
                  child: const Text('Current'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              controller: _lyricsScrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemBuilder: (context, index) {
                final line = lyrics.lines[index];
                final isActive = index == _activeLyricIndex;
                return Container(
                  key: _lyricKeys[index],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withOpacity(0.16)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    line.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white70,
                      fontSize: isActive ? 18 : 16,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemCount: lyrics.lines.length,
            ),
          ),
        ],
      ),
    );
  }

  void _togglePlayPause() {
    if (isPlaying) {
      unawaited(audioPlayer.pause());
    } else {
      unawaited(audioPlayer.play());
    }
  }

  Widget _buildBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF473616),
            Color(0xFF2C2C2E),
            Color(0xFF121212),
          ],
          stops: [0, 0.45, 1],
        ),
      ),
      child: child,
    );
  }

  Widget _buildTopHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 22),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.34),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white70,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlayingPage() {
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final artSize = (constraints.maxWidth - 44).clamp(280.0, 590.0).toDouble();
          final showLyrics = _showLyrics;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTopHandle(),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.32),
                            blurRadius: 28,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: SizedBox(
                          width: artSize,
                          height: artSize,
                          child: _buildArtwork(artSize),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                  MiniPlayerHeader(
                    artwork: _buildArtwork(72),
                    title: _currentTitle,
                    artist: _currentArtist,
                    artworkSize: 0,
                  ),
                  const SizedBox(height: 24),
                  AudioSlider(
                    position: position,
                    duration: duration,
                    onChanged: (newPosition) {
                      unawaited(audioPlayer.seek(newPosition));
                    },
                  ),
                  const SizedBox(height: 48),
                  ControlButtonsBar(
                    isPlaying: isPlaying,
                    canGoPrevious: _canGoPrevious,
                    canGoNext: _canGoNext,
                    onPrevious: _skipPrevious,
                    onPlayPause: _togglePlayPause,
                    onNext: _skipNext,
                  ),
                  const SizedBox(height: 46),
                  VolumeBar(
                    value: _volume,
                    onChanged: (value) {
                      setState(() {
                        _volume = value;
                      });
                      unawaited(audioPlayer.setVolume(value));
                    },
                  ),
                  const SizedBox(height: 24),
                  BottomToolsBar(
                    onLyrics: _toggleLyrics,
                    onAirPlay: _showAirPlayNotice,
                    onQueue: _showQueuePage,
                    queueActive: _queuePageActive,
                  ),
                  if (showLyrics) ...[
                    const SizedBox(height: 20),
                    _buildLyricsPanel(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQueuePage() {
    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: _libraryController,
        builder: (context, _) {
          final songs = _libraryController.visibleSongs;
          final sourceFolder = _localSource == null
              ? 'Office'
              : _libraryController.folderNameFor(
                  _libraryController.folderPathFor(_localSource!),
                );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTopHandle(),
                    MiniPlayerHeader(
                      artwork: _buildArtwork(74),
                      title: _currentTitle,
                      artist: _currentArtist,
                    ),
                    const SizedBox(height: 28),
                    QueueModeBar(automixOn: true),
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'AutoMix ON',
                        style: TextStyle(
                          color: Color(0xFFFF3B24),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Continue Playing',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'From $sourceFolder',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: songs.isEmpty
                    ? const Center(
                        child: Text(
                          'No active MP3 files',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final songModel = songs[index];
                          return SongListTile(
                            song: songModel,
                            onTap: () {
                              unawaited(_loadLocalSongModel(songModel));
                              _showPlayerPage();
                            },
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
                child: Column(
                  children: [
                    AudioSlider(
                      position: position,
                      duration: duration,
                      onChanged: (newPosition) {
                        unawaited(audioPlayer.seek(newPosition));
                      },
                    ),
                    const SizedBox(height: 40),
                    ControlButtonsBar(
                      isPlaying: isPlaying,
                      canGoPrevious: _canGoPrevious,
                      canGoNext: _canGoNext,
                      onPrevious: _skipPrevious,
                      onPlayPause: _togglePlayPause,
                      onNext: _skipNext,
                    ),
                    const SizedBox(height: 32),
                    VolumeBar(
                      value: _volume,
                      onChanged: (value) {
                        setState(() {
                          _volume = value;
                        });
                        unawaited(audioPlayer.setVolume(value));
                      },
                    ),
                    const SizedBox(height: 16),
                    BottomToolsBar(
                      onLyrics: _toggleLyrics,
                      onAirPlay: _showAirPlayNotice,
                      onQueue: _showPlayerPage,
                      queueActive: true,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _buildBackground(
        child: PageView(
          controller: _playerPageController,
          scrollDirection: Axis.vertical,
          onPageChanged: (index) {
            setState(() {
              _queuePageActive = index == 1;
              if (index == 1) _showLyrics = false;
            });
          },
          children: [
            _buildNowPlayingPage(),
            _buildQueuePage(),
          ],
        ),
      ),
    );
  }
}
