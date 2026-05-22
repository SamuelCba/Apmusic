// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:musicplayer/pages/browse_page.dart';
import 'package:musicplayer/pages/home_page.dart';
import 'package:musicplayer/pages/library_page.dart';
import 'package:musicplayer/pages/radio.dart';
import 'package:musicplayer/pages/search_page.dart';
import 'package:musicplayer/services/playback_controller.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> with SingleTickerProviderStateMixin {
  static const double _collapsedPlayerHeight = 72.0;
  static const double _snapThreshold = 0.40;

  int _selected_index = 0;
  bool _isMiniMode = false;
  bool _showSearchPage = false;
  final PlaybackController _playbackController = PlaybackController.instance;
  late final ValueNotifier<double> _playerHeight;
  late final AnimationController _snapController;
  Animation<double>? _snapAnimation;

  @override
  void initState() {
    super.initState();
    _playerHeight = ValueNotifier<double>(_collapsedPlayerHeight);
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..addListener(() {
        final animation = _snapAnimation;
        if (animation != null) _playerHeight.value = animation.value;
      });
  }

  @override
  void dispose() {
    _snapController.dispose();
    _playerHeight.dispose();
    super.dispose();
  }

  double _maxPlayerHeight(BuildContext context) => MediaQuery.sizeOf(context).height;

  double _playerProgress(double height, double maxHeight) {
    return ((height - _collapsedPlayerHeight) / (maxHeight - _collapsedPlayerHeight)).clamp(0.0, 1.0).toDouble();
  }

  void _animatePlayerTo(double targetHeight) {
    _snapController.stop();
    _snapAnimation = Tween<double>(
      begin: _playerHeight.value,
      end: targetHeight,
    ).animate(
      CurvedAnimation(
        parent: _snapController,
        curve: Curves.easeOutCubic,
      ),
    );
    _snapController
      ..reset()
      ..forward();
  }

  void _expandPlayer() {
    _animatePlayerTo(_maxPlayerHeight(context));
  }

  void _collapsePlayer() {
    _animatePlayerTo(_collapsedPlayerHeight);
  }

  void _handlePlayerDragUpdate(DragUpdateDetails details) {
    final maxHeight = _maxPlayerHeight(context);
    final delta = details.primaryDelta ?? 0;
    _snapController.stop();
    _playerHeight.value = (_playerHeight.value - delta).clamp(_collapsedPlayerHeight, maxHeight).toDouble();
  }

  void _handlePlayerDragEnd(DragEndDetails details) {
    final maxHeight = _maxPlayerHeight(context);
    final velocity = details.primaryVelocity ?? 0;
    final progress = _playerProgress(_playerHeight.value, maxHeight);
    final expand = velocity < -500 || (velocity < 500 && progress > _snapThreshold);
    _animatePlayerTo(expand ? maxHeight : _collapsedPlayerHeight);
  }

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
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    final maxPlayerHeight = _maxPlayerHeight(context);

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
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
          ValueListenableBuilder<double>(
            valueListenable: _playerHeight,
            builder: (context, height, _) {
              final progress = _playerProgress(height, maxPlayerHeight);
              if (progress <= 0.001 || !_playbackController.hasTrack) {
                return const SizedBox.shrink();
              }
              return _PersistentPlayerSheet(
                controller: _playbackController,
                height: height,
                progress: progress,
                safeBottom: safeBottom,
                isMiniMode: _isMiniMode && !_showSearchPage,
                onTapCollapsed: _expandPlayer,
                onCollapse: _collapsePlayer,
                onVerticalDragUpdate: _handlePlayerDragUpdate,
                onVerticalDragEnd: _handlePlayerDragEnd,
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _playbackController,
        builder: (context, _) {
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

          return ValueListenableBuilder<double>(
            valueListenable: _playerHeight,
            builder: (context, height, _) {
              final progress = _playerProgress(height, maxPlayerHeight);
              final miniOpacity = progress <= 0.001 ? 1.0 : 0.0;
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
                          duration: Duration.zero,
                          opacity: hideMiniForSearchKeyboard ? 0 : miniOpacity,
                          child: IgnorePointer(
                            ignoring: hideMiniForSearchKeyboard || miniOpacity == 0,
                            child: _LiquidMiniPlayer(
                              controller: _playbackController,
                              onOpen: _expandPlayer,
                              compact: compactPlayer,
                              onVerticalDragUpdate: _handlePlayerDragUpdate,
                              onVerticalDragEnd: _handlePlayerDragEnd,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: safeBottom,
                      child: Transform.translate(
                        offset: Offset(0, progress * (104 + safeBottom)),
                        child: _LiquidNavBar(
                          selectedIndex: _selected_index,
                          isMiniMode: _isMiniMode,
                          isSearching: _showSearchPage,
                          onSelected: _navgateBottomBar,
                          onSearch: _openSearch,
                          onSearchClosed: _closeSearch,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
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
  final GestureDragUpdateCallback onVerticalDragUpdate;
  final GestureDragEndCallback onVerticalDragEnd;

  const _LiquidMiniPlayer({
    required this.controller,
    required this.onOpen,
    required this.onVerticalDragUpdate,
    required this.onVerticalDragEnd,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: onVerticalDragUpdate,
      onVerticalDragEnd: onVerticalDragEnd,
      child: GlassButton(
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
                onPressed: () => unawaited(controller.playPause()),
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
        nullArtworkWidget: const _SmallArtworkFallback(),
        errorBuilder: (_, __, ___) => const _SmallArtworkFallback(),
      );
    }

    if (controller.artworkUrl != null) {
      return CachedNetworkImage(
        imageUrl: controller.artworkUrl!,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => const _SmallArtworkFallback(),
      );
    }

    return const _SmallArtworkFallback();
  }
}

class _SmallArtworkFallback extends StatelessWidget {
  const _SmallArtworkFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF242426),
      child: const Icon(Icons.music_note_rounded, color: Colors.white54, size: 22),
    );
  }
}

class _PersistentPlayerSheet extends StatelessWidget {
  final PlaybackController controller;
  final double height;
  final double progress;
  final double safeBottom;
  final bool isMiniMode;
  final VoidCallback onTapCollapsed;
  final VoidCallback onCollapse;
  final GestureDragUpdateCallback onVerticalDragUpdate;
  final GestureDragEndCallback onVerticalDragEnd;

  const _PersistentPlayerSheet({
    required this.controller,
    required this.height,
    required this.progress,
    required this.safeBottom,
    required this.isMiniMode,
    required this.onTapCollapsed,
    required this.onCollapse,
    required this.onVerticalDragUpdate,
    required this.onVerticalDragEnd,
  });

  static const double _expandedTopArtwork = 100.0;

  String _format(Duration duration) {
    final safe = duration.isNegative ? Duration.zero : duration;
    final minutes = safe.inMinutes.remainder(60);
    final seconds = safe.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  double _maxiOpacity(double alpha) => math.max(0.0, 4 * alpha - 3.0);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final alpha = progress.clamp(0.0, 1.0).toDouble();
    final navOffset = 64.0 + 16.0 + safeBottom + 14.0;
    final bottom = lerpDouble(navOffset, 0, alpha)!;
    final horizontalMargin = lerpDouble(isMiniMode ? 76.0 : 16.0, 0, alpha)!;
    final artworkSize = 48.0 + alpha * (width * 0.85 - 48.0);
    final artworkLeft = 16.0 + alpha * ((width - artworkSize) / 2.0 - 16.0);
    final artworkTop = lerpDouble(12.0, _expandedTopArtwork, alpha)!;
    final artworkRadius = 8.0 + alpha * 16.0;
    final maxiOpacity = _maxiOpacity(alpha);

    return Positioned(
      left: horizontalMargin,
      right: horizontalMargin,
      bottom: bottom,
      height: height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: alpha < 0.08 ? onTapCollapsed : null,
        onVerticalDragUpdate: onVerticalDragUpdate,
        onVerticalDragEnd: onVerticalDragEnd,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(lerpDouble(28.0, 0.0, alpha)!),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18 * (1 - alpha), sigmaY: 18 * (1 - alpha)),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                border: Border.all(
                  color: Colors.white.withOpacity(lerpDouble(0.12, 0.0, alpha)!),
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: alpha * 0.55,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
                        child: _CoverArtwork(
                          controller: controller,
                          width: width,
                          height: MediaQuery.sizeOf(context).height,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.lerp(const Color(0xCC1C1C1E), const Color(0xDD5A421B), alpha)!,
                            Color.lerp(const Color(0xEE171719), const Color(0xEE242426), alpha)!,
                            const Color(0xFF121212),
                          ],
                          stops: const [0, 0.48, 1],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: artworkLeft,
                    top: artworkTop,
                    width: artworkSize,
                    height: artworkSize,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(artworkRadius),
                      child: _PlayerArtwork(
                        controller: controller,
                        size: artworkSize,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 22,
                    right: 22,
                    top: artworkTop + artworkSize + 30,
                    bottom: math.max(18.0, safeBottom + 18),
                    child: IgnorePointer(
                      ignoring: maxiOpacity == 0,
                      child: Opacity(
                        opacity: maxiOpacity,
                        child: _ExpandedPlayerControls(
                          controller: controller,
                          onCollapse: onCollapse,
                          formatDuration: _format,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandedPlayerControls extends StatefulWidget {
  final PlaybackController controller;
  final VoidCallback onCollapse;
  final String Function(Duration duration) formatDuration;

  const _ExpandedPlayerControls({
    required this.controller,
    required this.onCollapse,
    required this.formatDuration,
  });

  @override
  State<_ExpandedPlayerControls> createState() => _ExpandedPlayerControlsState();
}

class _ExpandedPlayerControlsState extends State<_ExpandedPlayerControls> {
  double _volume = 1.0;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    controller.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(CupertinoIcons.star, color: Colors.white70),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(CupertinoIcons.ellipsis, color: Colors.white70),
            ),
            IconButton(
              onPressed: widget.onCollapse,
              icon: const Icon(CupertinoIcons.chevron_down, color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 18),
        StreamBuilder<Duration>(
          stream: controller.audioPlayer.positionStream,
          initialData: controller.position,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            final duration = controller.duration.inMilliseconds > 0 ? controller.duration : const Duration(seconds: 1);
            final totalMs = duration.inMilliseconds;
            final value = position.inMilliseconds.clamp(0, totalMs).toDouble();
            return Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                    overlayShape: SliderComponentShape.noOverlay,
                    activeTrackColor: Colors.white.withOpacity(0.78),
                    inactiveTrackColor: Colors.white.withOpacity(0.24),
                  ),
                  child: Slider(
                    min: 0,
                    max: totalMs.toDouble(),
                    value: value,
                    onChanged: (ms) {
                      unawaited(controller.seek(Duration(milliseconds: ms.toInt())));
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.formatDuration(position),
                      style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '-${widget.formatDuration(duration - position)}',
                      style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.backward_end_fill, color: Colors.white54, size: 38),
            const SizedBox(width: 30),
            IconButton(
              onPressed: () => unawaited(controller.playPause()),
              icon: Icon(
                controller.isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_arrow_solid,
                color: Colors.white,
                size: 70,
              ),
            ),
            const SizedBox(width: 30),
            const Icon(CupertinoIcons.forward_end_fill, color: Colors.white54, size: 38),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            const Icon(Icons.volume_down_rounded, color: Colors.white54, size: 20),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                  overlayShape: SliderComponentShape.noOverlay,
                  activeTrackColor: Colors.white.withOpacity(0.76),
                  inactiveTrackColor: Colors.white.withOpacity(0.24),
                ),
                child: Slider(
                  min: 0,
                  max: 1,
                  value: _volume,
                  onChanged: (value) {
                    setState(() => _volume = value);
                    unawaited(controller.setVolume(value));
                  },
                ),
              ),
            ),
            const Icon(Icons.volume_up_rounded, color: Colors.white54, size: 20),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.chat_bubble_outline_rounded, color: Colors.white54, size: 25),
            Icon(Icons.airplay_rounded, color: Colors.white54, size: 25),
            Icon(Icons.format_list_bulleted_rounded, color: Colors.white70, size: 29),
          ],
        ),
      ],
    );
  }
}

class _CoverArtwork extends StatelessWidget {
  final PlaybackController controller;
  final double width;
  final double height;

  const _CoverArtwork({
    required this.controller,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.isLocalTrack && controller.artworkId != null) {
      return QueryArtworkWidget(
        id: controller.artworkId!,
        type: ArtworkType.AUDIO,
        artworkFit: BoxFit.cover,
        artworkWidth: 900,
        artworkHeight: 900,
        quality: 100,
        artworkBorder: BorderRadius.zero,
        nullArtworkWidget: const _CoverArtworkFallback(),
        errorBuilder: (_, __, ___) => const _CoverArtworkFallback(),
      );
    }

    if (controller.artworkUrl != null) {
      return CachedNetworkImage(
        imageUrl: controller.artworkUrl!,
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorWidget: (_, __, ___) => const _CoverArtworkFallback(),
      );
    }

    return const _CoverArtworkFallback();
  }
}

class _CoverArtworkFallback extends StatelessWidget {
  const _CoverArtworkFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF5A421B),
            Color(0xFF242426),
            Color(0xFF121212),
          ],
        ),
      ),
    );
  }
}

class _PlayerArtwork extends StatelessWidget {
  final PlaybackController controller;
  final double size;

  const _PlayerArtwork({
    required this.controller,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.isLocalTrack && controller.artworkId != null) {
      return QueryArtworkWidget(
        id: controller.artworkId!,
        type: ArtworkType.AUDIO,
        artworkFit: BoxFit.cover,
        artworkWidth: 900,
        artworkHeight: 900,
        quality: 100,
        artworkBorder: BorderRadius.zero,
        nullArtworkWidget: _MiniArtworkFallback(size: size),
        errorBuilder: (_, __, ___) => _MiniArtworkFallback(size: size),
      );
    }

    if (controller.artworkUrl != null) {
      return CachedNetworkImage(
        imageUrl: controller.artworkUrl!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorWidget: (_, __, ___) => _MiniArtworkFallback(size: size),
      );
    }

    return _MiniArtworkFallback(size: size);
  }
}

class _MiniArtworkFallback extends StatelessWidget {
  final double size;

  const _MiniArtworkFallback({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFF242426),
      child: Icon(
        Icons.music_note_rounded,
        color: Colors.white54,
        size: math.min(size * 0.52, 64),
      ),
    );
  }
}
