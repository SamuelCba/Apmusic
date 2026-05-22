import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MusicList extends StatefulWidget {
  const MusicList({super.key});

  @override
  State<MusicList> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  late Future<List<SongModel>> _songsFuture;
  bool _permissionGranted = true;

  @override
  void initState() {
    super.initState();
    _songsFuture = _loadSongs();
  }

  Future<List<SongModel>> _loadSongs() async {
    final granted = await _audioQuery.checkAndRequest();
    if (!granted) {
      if (mounted) {
        setState(() {
          _permissionGranted = false;
        });
      }
      return [];
    }

    final songs = await _audioQuery.querySongs(
      sortType: SongSortType.DATE_ADDED,
      uriType: UriType.EXTERNAL,
    );

    final mp3Songs = songs.where((song) {
      final extension = song.fileExtension.toLowerCase();
      return extension == 'mp3' || song.data.toLowerCase().endsWith('.mp3');
    }).toList()
      ..sort((a, b) {
        final aDate = a.dateAdded ?? 0;
        final bDate = b.dateAdded ?? 0;
        return bDate.compareTo(aDate);
      });

    if (mounted) {
      setState(() {
        _permissionGranted = true;
      });
    }

    return mp3Songs;
  }

  Future<void> _refreshSongs() async {
    setState(() {
      _songsFuture = _loadSongs();
    });
  }

  void _openPlayer(SongModel song) {
    Navigator.pushNamed(
      context,
      '/player',
      arguments: {
        'source': song.data,
        'title': song.title,
        'artist': song.artist ?? 'Unknown artist',
        'album': song.album ?? 'Unknown album',
        'artworkId': song.id,
        'isLocal': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Songs',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            onPressed: _refreshSongs,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<SongModel>>(
        future: _songsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!_permissionGranted) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.audiotrack_rounded, size: 72, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'No tengo permiso para leer tu música.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Dale acceso a audio/almacenamiento para mostrar los MP3 del teléfono.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshSongs,
                      child: const Text('Intentar otra vez'),
                    ),
                  ],
                ),
              ),
            );
          }

          final songs = snapshot.data ?? [];
          if (songs.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshSongs,
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No encontré archivos .mp3 en el almacenamiento.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshSongs,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: songs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final song = songs[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _openPlayer(song),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1B1D),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: QueryArtworkWidget(
                            id: song.id,
                            type: ArtworkType.AUDIO,
                            artworkWidth: 64,
                            artworkHeight: 64,
                            artworkFit: BoxFit.cover,
                            quality: 50,
                            nullArtworkWidget: Container(
                              width: 64,
                              height: 64,
                              color: const Color(0xFF2A2A2D),
                              child: const Icon(Icons.music_note_rounded, color: Colors.white54),
                            ),
                            errorBuilder: (_, __, ___) => Container(
                              width: 64,
                              height: 64,
                              color: const Color(0xFF2A2A2D),
                              child: const Icon(Icons.music_note_rounded, color: Colors.white54),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                song.artist ?? 'Unknown artist',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                song.album ?? 'Unknown album',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.play_arrow_rounded, color: Colors.red, size: 30),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
