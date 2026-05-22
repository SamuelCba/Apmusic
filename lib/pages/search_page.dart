import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/services/music_library_controller.dart';
import 'package:musicplayer/widgets/music_library_sheets.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

class SearchPage extends StatefulWidget {
  final bool autoFocus;
  final bool showSearchField;

  const SearchPage({
    super.key,
    this.autoFocus = false,
    this.showSearchField = true,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final MusicLibraryController _libraryController = MusicLibraryController.instance;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  static const _categories = [
    _BrowseCategory('Pop', Color(0xFFB83A45)),
    _BrowseCategory('Rock', Color(0xFF7A4A32)),
    _BrowseCategory('Hip-Hop', Color(0xFF9A6A21)),
    _BrowseCategory('Electronic', Color(0xFF355CA8)),
    _BrowseCategory('Latin', Color(0xFF9D3E73)),
    _BrowseCategory('Albums', Color(0xFF4A6857)),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onQueryChanged);
    unawaited(_libraryController.ensureLoaded());
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onQueryChanged)
      ..dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged() => setState(() {});

  List<SongModel> get _results {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return [];

    return _libraryController.visibleSongs.where((song) {
      final title = song.title.toLowerCase();
      final artist = (song.artist ?? '').toLowerCase();
      final album = (song.album ?? '').toLowerCase();
      return title.contains(query) || artist.contains(query) || album.contains(query);
    }).toList();
  }

  void _openSong(SongModel song) {
    Navigator.pushNamed(context, '/player', arguments: {
      'source': song.data,
      'title': song.title,
      'artist': song.artist ?? 'Unknown artist',
      'album': song.album ?? 'Unknown album',
      'artworkId': song.id,
      'isLocal': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final results = _results;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.apple, color: Colors.white, size: 22),
                        const SizedBox(width: 4),
                        const Text(
                          'Music',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => showAccountMenuSheet(context),
                          icon: const Icon(Icons.account_circle_rounded, color: Colors.white, size: 34),
                        ),
                      ],
                    ),
                    Text(
                      'Search',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.54),
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (widget.showSearchField) ...[
                      const SizedBox(height: 18),
                      _SearchField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                      ),
                    ] else
                      const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
            if (query.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 170),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.68,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _CategoryTile(category: _categories[index]),
                    childCount: _categories.length,
                  ),
                ),
              )
            else if (results.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 160),
                  child: _EmptySearch(query: query),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 170),
                sliver: SliverList.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final song = results[index];
                    return _SearchSongTile(
                      song: song,
                      onTap: () => _openSong(song),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const _SearchField({
    required this.controller,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(13),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: const TextStyle(color: Colors.white, fontSize: 18),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(CupertinoIcons.search, color: Colors.white54, size: 22),
          suffixIcon: controller.text.isEmpty
              ? const Icon(CupertinoIcons.mic_fill, color: Colors.white38, size: 20)
              : IconButton(
                  onPressed: controller.clear,
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.white38, size: 20),
                ),
          hintText: 'Artists, Songs, Lyrics, and More',
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 17),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _SearchSongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;

  const _SearchSongTile({
    required this.song,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: QueryArtworkWidget(
                id: song.id,
                type: ArtworkType.AUDIO,
                artworkWidth: 54,
                artworkHeight: 54,
                artworkFit: BoxFit.cover,
                quality: 100,
                nullArtworkWidget: const _FallbackArtwork(),
                errorBuilder: (_, __, ___) => const _FallbackArtwork(),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    song.artist ?? 'Unknown artist',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right, color: Colors.white24, size: 18),
          ],
        ),
      ),
    );
  }
}

class _FallbackArtwork extends StatelessWidget {
  const _FallbackArtwork();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      color: const Color(0xFF242426),
      child: const Icon(Icons.music_note_rounded, color: Colors.white54, size: 25),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final _BrowseCategory category;

  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: category.color,
        borderRadius: BorderRadius.circular(13),
      ),
      padding: const EdgeInsets.all(13),
      alignment: Alignment.bottomLeft,
      child: Text(
        category.title,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  final String query;

  const _EmptySearch({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.search, size: 58, color: Colors.white.withOpacity(0.28)),
          const SizedBox(height: 16),
          const Text(
            'No Results',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'No local MP3 matches "$query".',
            style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _BrowseCategory {
  final String title;
  final Color color;

  const _BrowseCategory(this.title, this.color);
}
