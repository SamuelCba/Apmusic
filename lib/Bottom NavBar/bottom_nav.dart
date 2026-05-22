// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:musicplayer/pages/artist_list.dart';
import 'package:musicplayer/pages/browse_page.dart';
import 'package:musicplayer/pages/home_page.dart';
import 'package:musicplayer/pages/library_page.dart';
import 'package:musicplayer/pages/music_list.dart';
import 'package:musicplayer/pages/radio.dart';
import 'package:musicplayer/pages/search_page.dart';
import 'package:musicplayer/services/playback_controller.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  int _selected_index = 0;
  final PlaybackController _playbackController = PlaybackController.instance;

  void _navgateBottomBar(int index) {
    setState(() {
      _selected_index = index;
    });
  }

  final List _pages = [
    const HomePage(),
    const BrowsePage(),
    const RadioPage(),
    const LibraryPage(),
    const SearchPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_selected_index],
      bottomNavigationBar: AnimatedBuilder(
        animation: _playbackController,
        builder: (context, _) {
          final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
          final hasTrack = _playbackController.hasTrack;
          return SizedBox(
            height: (hasTrack ? 142 : 84) + safeBottom,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                if (hasTrack)
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 78 + safeBottom,
                    height: 54,
                    child: _LiquidMiniPlayer(
                      controller: _playbackController,
                      onOpen: () => Navigator.pushNamed(context, '/player'),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 12 + safeBottom,
                  height: 58,
                  child: _LiquidNavBar(
                    selectedIndex: _selected_index,
                    onSelected: _navgateBottomBar,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LiquidNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _LiquidNavBar({
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  State<_LiquidNavBar> createState() => _LiquidNavBarState();
}

class _LiquidNavBarState extends State<_LiquidNavBar> {
  final FocusNode _searchFocusNode = FocusNode();

  static const _tabs = [
    GlassBottomBarTab(
      label: 'Home',
      icon: Icon(CupertinoIcons.house),
      activeIcon: Icon(CupertinoIcons.house_fill),
    ),
    GlassBottomBarTab(
      label: 'Browse',
      icon: Icon(CupertinoIcons.square_grid_2x2),
      activeIcon: Icon(CupertinoIcons.square_grid_2x2_fill),
    ),
    GlassBottomBarTab(
      label: 'Radio',
      icon: Icon(CupertinoIcons.antenna_radiowaves_left_right),
    ),
    GlassBottomBarTab(
      label: 'Library',
      icon: Icon(CupertinoIcons.music_albums),
      activeIcon: Icon(CupertinoIcons.music_albums_fill),
    ),
    GlassBottomBarTab(
      label: 'Search',
      icon: Icon(CupertinoIcons.search),
    ),
  ];

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassSearchableBottomBar(
      isSearchActive: false,
      selectedIndex: widget.selectedIndex,
      onTabSelected: widget.onSelected,
      barHeight: 58,
      searchBarHeight: 50,
      horizontalPadding: 18,
      verticalPadding: 0,
      spacing: 8,
      selectedIconColor: const Color(0xFFFF2D55),
      unselectedIconColor: Colors.white.withOpacity(0.86),
      indicatorColor: Colors.white.withOpacity(0.18),
      labelFontSize: 9,
      iconSize: 24,
      iconLabelSpacing: 1,
      quality: GlassQuality.premium,
      interactionBehavior: GlassInteractionBehavior.full,
      glassSettings: const LiquidGlassSettings(
        glassColor: Color(0xCC1C1C1E),
        thickness: 30,
        blur: 3,
        lightIntensity: 0.35,
        chromaticAberration: .01,
      ),
      searchConfig: GlassSearchBarConfig(
        focusNode: _searchFocusNode,
        autoFocusOnExpand: false,
        showsCancelButton: true,
        expandWhenActive: false,
        hintText: 'Apple Music',
        onSearchToggle: (active) {
          if (active) {
            widget.onSelected(4);
            _searchFocusNode.unfocus();
          }
        },
        onSearchFocusChanged: (focused) {
          if (!focused) return;
          widget.onSelected(4);
          _searchFocusNode.unfocus();
        },
        searchIconColor: Colors.white.withOpacity(0.86),
        textInputAction: TextInputAction.search,
      ),
      tabs: _tabs,
    );
  }
}

class _LiquidMiniPlayer extends StatelessWidget {
  final PlaybackController controller;
  final VoidCallback onOpen;

  const _LiquidMiniPlayer({
    required this.controller,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      onTap: onOpen,
      quality: GlassQuality.premium,
      useOwnLayer: true,
      shape: const LiquidRoundedSuperellipse(borderRadius: 28),
      settings: const LiquidGlassSettings(
        glassColor: Color(0xCC1C1C1E),
        thickness: 30,
        blur: 3,
        lightIntensity: 0.35,
        chromaticAberration: .01,
      ),
      icon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 38,
                height: 38,
                child: _MiniArtwork(controller: controller),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    controller.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => controller.playPause(),
              icon: Icon(
                controller.isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_arrow_solid,
                color: Colors.white,
                size: 24,
              ),
            ),
            const Icon(CupertinoIcons.forward_end_fill, color: Colors.white60, size: 20),
          ],
        ),
      ),
    );
  }
}

class _MiniArtwork extends StatelessWidget {
  final PlaybackController controller;

  const _MiniArtwork({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLocalTrack && controller.artworkId != null) {
      return QueryArtworkWidget(
        id: controller.artworkId!,
        type: ArtworkType.AUDIO,
        artworkFit: BoxFit.cover,
        artworkWidth: 38,
        artworkHeight: 38,
        quality: 100,
        nullArtworkWidget: const _MiniArtworkFallback(),
        errorBuilder: (_, __, ___) => const _MiniArtworkFallback(),
      );
    }

    if (controller.artworkUrl != null) {
      return CachedNetworkImage(
        imageUrl: controller.artworkUrl!,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => const _MiniArtworkFallback(),
      );
    }

    return const _MiniArtworkFallback();
  }
}

class _MiniArtworkFallback extends StatelessWidget {
  const _MiniArtworkFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF242426),
      child: const Icon(Icons.music_note_rounded, color: Colors.white54, size: 22),
    );
  }
}
