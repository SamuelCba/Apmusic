import 'package:flutter/foundation.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

class MusicFolderEntry {
  final String path;
  final String name;
  final int depth;

  const MusicFolderEntry({
    required this.path,
    required this.name,
    required this.depth,
  });
}

class MusicLibraryController extends ChangeNotifier {
  MusicLibraryController._();

  static final MusicLibraryController instance = MusicLibraryController._();

  final OnAudioQuery _audioQuery = OnAudioQuery();

  bool _loading = false;
  bool _permissionGranted = true;
  bool _loaded = false;
  List<SongModel> _songs = [];
  List<MusicFolderEntry> _folders = [];
  final Set<String> _enabledFolders = <String>{};

  bool get loading => _loading;
  bool get permissionGranted => _permissionGranted;
  bool get hasLoaded => _loaded;

  List<SongModel> get songs => List.unmodifiable(_songs);
  List<MusicFolderEntry> get folders => List.unmodifiable(_folders);
  Set<String> get enabledFolders => Set.unmodifiable(_enabledFolders);

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();

    final granted = await _audioQuery.checkAndRequest();
    if (!granted) {
      _permissionGranted = false;
      _songs = [];
      _folders = [];
      _enabledFolders.clear();
      _loading = false;
      _loaded = true;
      notifyListeners();
      return;
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

    final previousFolderPaths = _folders.map((folder) => folder.path).toSet();
    final folderPaths = <String>{};
    for (final song in mp3Songs) {
      folderPaths.add(folderPathFor(song.data));
    }

    final folders = folderPaths
        .map(
          (path) => MusicFolderEntry(
            path: path,
            name: folderNameFor(path),
            depth: _folderDepth(path),
          ),
        )
        .toList()
      ..sort((a, b) {
        final depthCompare = a.depth.compareTo(b.depth);
        if (depthCompare != 0) return depthCompare;
        return a.path.toLowerCase().compareTo(b.path.toLowerCase());
      });

    if (!_loaded) {
      _enabledFolders
        ..clear()
        ..addAll(folderPaths);
    } else {
      final previousEnabled = Set<String>.from(_enabledFolders);
      final hadAnyEnabled = previousEnabled.isNotEmpty;
      _enabledFolders
        ..clear()
        ..addAll(previousEnabled.intersection(folderPaths));

      if (hadAnyEnabled) {
        final newFolders = folderPaths.difference(previousFolderPaths);
        _enabledFolders.addAll(newFolders);
      }
    }

    _songs = mp3Songs;
    _folders = folders;
    _permissionGranted = true;
    _loading = false;
    _loaded = true;
    notifyListeners();
  }

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    await refresh();
  }

  void setFolderEnabled(String path, bool enabled) {
    if (enabled) {
      _enabledFolders.add(path);
    } else {
      _enabledFolders.remove(path);
    }
    notifyListeners();
  }

  void setAllFoldersEnabled(bool enabled) {
    if (enabled) {
      _enabledFolders
        ..clear()
        ..addAll(_folders.map((folder) => folder.path));
    } else {
      _enabledFolders.clear();
    }
    notifyListeners();
  }

  bool isFolderEnabled(String path) => _enabledFolders.contains(path);

  List<SongModel> get visibleSongs {
    if (_enabledFolders.isEmpty) return [];
    return _songs.where((song) {
      final folder = folderPathFor(song.data);
      return _enabledFolders.contains(folder);
    }).toList();
  }

  int countSongsInFolder(String path) {
    return _songs.where((song) => folderPathFor(song.data) == path).length;
  }

  String folderPathFor(String filePath) {
    final normalized = filePath.replaceAll('\\', '/');
    final index = normalized.lastIndexOf('/');
    if (index <= 0) return normalized;
    return normalized.substring(0, index);
  }

  String folderNameFor(String folderPath) {
    final normalized = folderPath.replaceAll('\\', '/');
    final index = normalized.lastIndexOf('/');
    if (index == -1 || index == normalized.length - 1) {
      return normalized;
    }
    return normalized.substring(index + 1);
  }

  int _folderDepth(String folderPath) {
    return folderPath.split('/').where((segment) => segment.isNotEmpty).length;
  }
}
