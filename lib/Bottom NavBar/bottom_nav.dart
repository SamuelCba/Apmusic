// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:musicplayer/pages/browse_page.dart';
import 'package:musicplayer/pages/home_page.dart';
import 'package:musicplayer/pages/library_page.dart';
import 'package:musicplayer/pages/music_player.dart';
import 'package:musicplayer/pages/radio.dart';
import 'package:musicplayer/pages/search_page.dart';
import 'package:musicplayer/services/playback_controller.dart';
import 'package:musicplayer/webView/webViewContainer.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  int _selected_index = 0;
  bool _isMiniMode = false;
  bool _showSearchPage = false;
  final PlaybackController _playbackController = PlaybackController.instance;

  void _navgateBottomBar(int index) {
    final restoreExpandedBar = _isMiniMode && index == _selected_index;
    setState(() {
      _selected_index = index;
      _showSearchPage = false;
      _isMiniMode = false;
    });
    if (restoreExpandedBar) {
      final controller = PrimaryScrollController.maybeOf(context);
      if (controller != null && controller.hasClients) {
        controller.animateTo(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuart,
        );
      }
    }
  }

  void _openSearch() {
    setState(() {
      _showSearchPage = true;
      _isMiniMode = false;
    });
  }

  void _closeSearch() {
    setState(() {
      _showSearchPage = false;
      _isMiniMode = false;
    });
  }

  void _openPlayer() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 520),
        reverseTransitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (_, __, ___) => const WebView(child: MusicPlayer()),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          final fadeIn = CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
          );
          return FadeTransition(
            opacity: fadeIn,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.72, end: 1.0).animate(curved),
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.30),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  bool _handleScroll(ScrollNotification notification) {
    if (_showSearchPage || notification.metrics.axis != Axis.vertical) return false;
    final mini = notification.metrics.pixels > 50;
    if (mini != _isMiniMode) {
      setState(() => _isMiniMode = mini);
    }
    return false;
  }

  final List _pages = [
    const HomePage(),
    const BrowsePage(),
    const RadioPage(),
    const LibraryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScroll,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeOutCubic,
          child: _showSearchPage
              ? const SearchPage(
                  key: ValueKey('search'),
                  autoFocus: false,
                  showSearchField: false,
                )
              : KeyedSubtree(
                  key: ValueKey('tab-$_selected_index'),
                  child: _pages[_selected_index],
                ),
        ),
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _playbackController,
        builder: (context, _) {
          final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
          final hasTrack = _playbackController.hasTrack;
          final hideMiniForSearchKeyboard = _showSearchPage && MediaQuery.viewInsetsOf(context).bottom > 0;
          const expandedNavBarH = 72.0;
          const collapsedNavBarH = 50.0;
          const pillGap = 14.0;
          const collapsedPillW = 50.0;
          final activeNavBarH = _showSearchPage ? collapsedNavBarH : expandedNavBarH;
          final aboveBarBottom = activeNavBarH + pillGap + safeBottom;
          final miniBarBottom = 16.0 + safeBottom;
          final miniPlayInset = 20.0 + collapsedPillW + 6.0;
          final compactPlayer = _isMiniMode && !_showSearchPage;

          return SizedBox(
            height: (hasTrack ? 152 : 88) + safeBottom,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                if (hasTrack)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeInOutCubic,
                    left: compactPlayer ? miniPlayInset : 20,
                    right: compactPlayer ? miniPlayInset : 20,
                    bottom: compactPlayer ? miniBarBottom : aboveBarBottom,
                    height: 50,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: hideMiniForSearchKeyboard ? 0 : 1,
                      child: IgnorePointer(
                        ignoring: hideMiniForSearchKeyboard,
                        child: _LiquidMiniPlayer(
                          controller: _playbackController,
                          onOpen: _openPlayer,
                          compact: compactPlayer,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: safeBottom,
                  child: _LiquidNavBar(
                    selectedIndex: _selected_index,
                    isMiniMode: _isMiniMode,
                    isSearching: _showSearchPage,
                    onSelected: _navgateBottomBar,
                    onSearch: _openSearch,
                    onSearchClosed: _closeSearch,
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
  final bool isMiniMode;
  final bool isSearching;
  final ValueChanged<int> onSelected;
  final VoidCallback onSearch;
  final VoidCallback onSearchClosed;

  const _LiquidNavBar({
    required this.selectedIndex,
    required this.isMiniMode,
    required this.isSearching,
    required this.onSelected,
    required this.onSearch,
    required this.onSearchClosed,
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
  ];

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassSearchableBottomBar(
      isSearchActive: widget.isMiniMode || widget.isSearching,
      selectedIndex: widget.selectedIndex,
      onTabSelected: widget.onSelected,
      barHeight: 64,
      searchBarHeight: 50,
      horizontalPadding: 20,
      verticalPadding: 16,
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
        expandWhenActive: !widget.isMiniMode || widget.isSearching,
        hintText: 'Apple Music',
        onSearchToggle: (active) {
          if (active) {
            widget.onSearch();
          } else {
            _searchFocusNode.unfocus();
            widget.onSearchClosed();
          }
        },
        onSearchFocusChanged: (focused) {
          if (focused) widget.onSearch();
        },
        searchIconColor: Colors.white.withOpacity(0.86),
        textInputAction: TextInputAction.search,
        collapsedLogoBuilder: (context) {
          final tab = _tabs[widget.selectedIndex];
          final iconColor = widget.isMiniMode && !widget.isSearching
              ? const Color(0xFFFF2D55)
              : Colors.white.withOpacity(0.86);
          return Center(
            child: IconTheme(
              data: IconThemeData(color: iconColor, size: 28),
              child: tab.activeIcon ?? tab.icon,
            ),
          );
        },
      ),
      tabs: _tabs,
    );
  }
}

class _LiquidMiniPlayer extends StatelessWidget {
  final PlaybackController controller;
  final VoidCallback onOpen;
  final bool compact;

  const _LiquidMiniPlayer({
    required this.controller,
    required this.onOpen,
    this.compact = false,
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
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: SizedBox(
                width: compact ? 34 : 38,
                height: compact ? 34 : 38,
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
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: compact ? 13 : 14,
                    ),
                  ),
                  if (!compact)
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
                size: compact ? 21 : 24,
              ),
            ),
            if (!compact) const Icon(CupertinoIcons.forward_end_fill, color: Colors.white60, size: 20),
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
        artworkBorder: BorderRadius.zero,
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
