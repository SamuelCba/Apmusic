import 'dart:async';

// import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

import '../models/lyrics.dart';
import '../services/lyrics_service.dart';
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
  final OnAudioQuery _audioQuery = OnAudioQuery();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  int currentIndex = 0;
  bool isLoading = false;
  bool _isLocalTrack = false;
  bool _showLyrics = false;
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

  @override
  void initState() {
    super.initState();
    // Initialize audio player
    audioPlayer = AudioPlayer();
    unawaited(audioPlayer.setVolume(_volume));
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
          _showLyrics = true;
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
    audioPlayer.playerStateStream.listen((PlayerState state) {
      if (!mounted) return;
      setState(() {
        isPlaying = state.playing;
      });
    });

    // Listen to duration changes
    audioPlayer.durationStream.listen((newDuration) {
      if (!mounted) return;
      setState(() {
        duration = newDuration ?? Duration.zero;
      });
    });

    // Listen to position changes
    audioPlayer.positionStream.listen((newPosition) {
      if (!mounted) return;
      setState(() {
        position = newPosition;
        _updateLyricPosition(newPosition);
      });
    });

    // Listen to sequence state for completion
    audioPlayer.processingStateStream.listen((state) {
      if (!mounted) return;
      if (state == ProcessingState.completed) {
        setState(() {
          position = Duration.zero;
          isPlaying = false;
        });
        // Automatically play next song only for the built-in demo playlist.
        if (!_isLocalTrack && currentIndex < song.length - 1) {
          currentIndex++;
          _loadSong(currentIndex);
        }
      }
    });
  }

  @override
  void dispose() {
    _lyricsScrollController.dispose();
    audioPlayer.dispose();
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
          controller: _audioQuery,
          nullArtworkWidget: _artworkPlaceholder(),
          errorBuilder: (_, __, ___) => _artworkPlaceholder(),
        );
      }

      return _artworkPlaceholder();
    }

    return CachedNetworkImage(
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => _artworkPlaceholder(),
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
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
                        ? Colors.white.withValues(alpha: 0.16)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 34,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _toggleLyrics,
            icon: Icon(
              _showLyrics ? Icons.lyrics_rounded : Icons.lyrics_outlined,
              color: _showLyrics ? Colors.white : Colors.white70,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final artSize = constraints.maxWidth > constraints.maxHeight
                  ? (constraints.maxHeight * 0.58).clamp(240.0, 360.0)
                  : (constraints.maxWidth * 0.86).clamp(260.0, 360.0);

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(110, 0, 0, 0),
                                blurRadius: 22,
                                spreadRadius: 4,
                                offset: Offset(0, 10),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: _buildArtwork(artSize),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _currentArtist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currentAlbum,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  _showLyrics ? 'Lyrics' : 'Now Playing',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.more_horiz_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _buildProgressSection(),
                      const SizedBox(height: 10),
                      _buildControls(),
                      const SizedBox(height: 10),
                      _buildVolumeSection(),
                      const SizedBox(height: 18),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: _showLyrics
                            ? _buildLyricsPanel()
                            : Container(
                                key: const ValueKey('lyrics-hint'),
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.lyrics_rounded,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'Tap the lyrics button to show synced lyrics while the track is playing.',
                                        style: TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _toggleLyrics,
                                      child: const Text('Open'),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
