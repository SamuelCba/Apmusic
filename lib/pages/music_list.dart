import 'dart:async';

import 'package:flutter/material.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

import '../services/music_library_controller.dart';
import '../services/playback_controller.dart';
import '../widgets/apple_music_player_widgets.dart';
import '../widgets/music_library_sheets.dart';

class MusicList extends StatefulWidget {
  const MusicList({super.key});

  @override
  State<MusicList> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  final MusicLibraryController _controller = MusicLibraryController.instance;

  @override
  void initState() {
    super.initState();
    unawaited(_controller.ensureLoaded());
  }

  Future<void> _refreshSongs() => _controller.refresh();

  void _openPlayer(SongModel song) {
    final songs = _controller.visibleSongs;
    final index = songs.indexWhere((item) => item.data == song.data);
    unawaited(PlaybackController.instance.playLocalQueue(songs, index < 0 ? 0 : index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Songs',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 28),
        ),
        actions: [
          IconButton(
            onPressed: _refreshSongs,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            onPressed: () => showFoldersSheet(context),
            icon: const Icon(Icons.folder_copy_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF473616),
              Color(0xFF232326),
              Color(0xFF121212),
            ],
            stops: [0, 0.34, 1],
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            if (_controller.loading && !_controller.hasLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

          if (!_controller.permissionGranted) {
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

            final songs = _controller.visibleSongs;
            final firstFolder = songs.isEmpty
                ? 'No folder'
                : _controller.folderNameFor(
                    _controller.folderPathFor(songs.first.data),
                  );
            if (songs.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refreshSongs,
                child: ListView(
                  children: [
                    const SizedBox(height: 120),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'No encontré archivos .mp3 en las carpetas activas.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => showFoldersSheet(context),
                        icon: const Icon(Icons.folder_copy_rounded),
                        label: const Text('Manage folders'),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshSongs,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
                children: [
                  BlurPanel(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        QueueModeBar(automixOn: true),
                        const SizedBox(height: 12),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'AutoMix ON',
                            style: TextStyle(
                              color: Color(0xFFFF3B24),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Continue Playing',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'From $firstFolder',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...songs.map(
                          (song) => SongListTile(
                            song: song,
                            onTap: () => _openPlayer(song),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
