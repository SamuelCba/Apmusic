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
  bool _playerQueueMode = false;
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
    setState(() => _playerQueueMode = false);
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
                      autoFocus: true,
                      showSearchField: true,
                    )
                  : KeyedSubtree(
                      key: ValueKey('tab-$_selected_index'),
                      child: _pages[_selected_index],
                    ),
            ),
          ),
          AnimatedBuilder(
            animation: _playbackController,
            builder: (context, _) {
              return ValueListenableBuilder<double>(
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
                    queueMode: _playerQueueMode,
                    onTapCollapsed: _expandPlayer,
                    onCollapse: _collapsePlayer,
                    onQueueModeChanged: (value) => setState(() => _playerQueueMode = value),
                    onVerticalDragUpdate: _handlePlayerDragUpdate,
                    onVerticalDragEnd: _handlePlayerDragEnd,
                  );
                },
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
          final aboveBarBottom = activeNavBarH + pillGap + safeBottom + (_showSearchPage ? 22.0 : 0.0);
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
              if (!compact)
                IconButton(
                  onPressed: controller.canGoNext ? () => unawaited(controller.skipNext()) : null,
                  icon: Icon(
                    CupertinoIcons.forward_end_fill,
                    color: controller.canGoNext ? Colors.white60 : Colors.white24,
                    size: 20,
                  ),
                ),
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
  final bool queueMode;
  final VoidCallback onTapCollapsed;
  final VoidCallback onCollapse;
  final ValueChanged<bool> onQueueModeChanged;
  final GestureDragUpdateCallback onVerticalDragUpdate;
  final GestureDragEndCallback onVerticalDragEnd;

  const _PersistentPlayerSheet({
    required this.controller,
    required this.height,
    required this.progress,
    required this.safeBottom,
    required this.isMiniMode,
    required this.queueMode,
    required this.onTapCollapsed,
    required this.onCollapse,
    required this.onQueueModeChanged,
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
    final collapsedBottom = isMiniMode ? 16.0 + safeBottom : navOffset;
    final bottom = lerpDouble(collapsedBottom, 0, alpha)!;
    final horizontalMargin = lerpDouble(isMiniMode ? 76.0 : 16.0, 0, alpha)!;
    final expandedArtworkSize = width * 0.85;
    final expandedArtworkLeft = (width - expandedArtworkSize) / 2.0;
    final expandedArtworkTop = _expandedTopArtwork;
    final artworkSize = 48.0 + alpha * (expandedArtworkSize - 48.0);
    final artworkLeft = lerpDouble(16.0, expandedArtworkLeft, alpha)!;
    final artworkTop = lerpDouble(12.0, expandedArtworkTop, alpha)!;
    final artworkRadius = 8.0 + alpha * 16.0;
    const expandedTitleLeft = 22.0;
    const expandedTitleRight = 132.0;
    final expandedTitleTop = artworkTop + artworkSize + 30.0;
    final titleLeft = lerpDouble(78.0, expandedTitleLeft, alpha)!;
    final titleRight = lerpDouble(74.0, expandedTitleRight, alpha)!;
    final titleTop = lerpDouble(10.0, expandedTitleTop, alpha)!;
    final maxiOpacity = _maxiOpacity(alpha);
    final gradientColors = controller.backgroundGradient;

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
                            Color.lerp(const Color(0xFF1C1C1E), gradientColors[0], alpha)!,
                            Color.lerp(const Color(0xFF171719), gradientColors[1], alpha)!,
                            gradientColors[2],
                          ],
                          stops: const [0, 0.48, 1],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 11,
                    left: (width - 42) / 2,
                    width: 42,
                    height: 5,
                    child: Opacity(
                      opacity: alpha,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.34),
                          borderRadius: BorderRadius.circular(999),
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
                    left: titleLeft,
                    right: titleRight,
                    top: titleTop,
                    child: _TransformingTrackTitle(
                      controller: controller,
                      progress: alpha,
                    ),
                  ),
                  Positioned(
                    left: 22,
                    right: 22,
                    top: titleTop,
                    bottom: math.max(18.0, safeBottom + 18),
                    child: IgnorePointer(
                      ignoring: maxiOpacity == 0,
                      child: Opacity(
                        opacity: maxiOpacity,
                        child: _ExpandedPlayerControls(
                          controller: controller,
                          onCollapse: onCollapse,
                          queueMode: queueMode,
                          onQueueModeChanged: onQueueModeChanged,
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
  final bool queueMode;
  final ValueChanged<bool> onQueueModeChanged;
  final String Function(Duration duration) formatDuration;

  const _ExpandedPlayerControls({
    required this.controller,
    required this.onCollapse,
    required this.queueMode,
    required this.onQueueModeChanged,
    required this.formatDuration,
  });

  @override
  State<_ExpandedPlayerControls> createState() => _ExpandedPlayerControlsState();
}

class _TransformingTrackTitle extends StatelessWidget {
  final PlaybackController controller;
  final double progress;

  const _TransformingTrackTitle({
    required this.controller,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final alpha = progress.clamp(0.0, 1.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: lerpDouble(14, 21, alpha),
            fontWeight: FontWeight.lerp(FontWeight.w700, FontWeight.w800, alpha),
          ),
        ),
        SizedBox(height: lerpDouble(0, 3, alpha)),
        Opacity(
          opacity: lerpDouble(0.0, 1.0, alpha)!,
          child: Text(
            controller.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white60,
              fontSize: lerpDouble(12, 15, alpha),
              fontWeight: FontWeight.lerp(FontWeight.w500, FontWeight.w600, alpha),
            ),
          ),
        ),
      ],
    );
  }
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
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
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
        const SizedBox(height: 52),
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
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: controller.canGoPrevious ? () => unawaited(controller.skipPrevious()) : null,
              icon: Icon(
                CupertinoIcons.backward_end_fill,
                color: controller.canGoPrevious ? Colors.white54 : Colors.white24,
                size: 38,
              ),
            ),
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
            IconButton(
              onPressed: controller.canGoNext ? () => unawaited(controller.skipNext()) : null,
              icon: Icon(
                CupertinoIcons.forward_end_fill,
                color: controller.canGoNext ? Colors.white54 : Colors.white24,
                size: 38,
              ),
            ),
          ],
        ),
        if (widget.queueMode)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 10),
              child: _InlineQueuePanel(controller: controller),
            ),
          )
        else
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
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white54, size: 25),
            const Icon(Icons.airplay_rounded, color: Colors.white54, size: 25),
            IconButton(
              onPressed: () => widget.onQueueModeChanged(!widget.queueMode),
              icon: Icon(
                Icons.format_list_bulleted_rounded,
                color: widget.queueMode ? Colors.white : Colors.white70,
                size: 29,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InlineQueuePanel extends StatelessWidget {
  final PlaybackController controller;

  const _InlineQueuePanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isLocal = controller.localQueue.isNotEmpty;
    final currentLocalIndex = isLocal ? controller.localQueue.indexWhere((song) => song.data == controller.source) : -1;
    final startIndex = isLocal ? math.max(0, currentLocalIndex + 1) : (controller.remoteIndex ?? -1) + 1;
    final queueLength = isLocal ? controller.localQueue.length : controller.remoteQueue.length;
    final itemCount = math.max(0, queueLength - startIndex);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Up Next',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          isLocal ? 'From Library' : 'From Apple Music',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: itemCount == 0
              ? const Center(
                  child: Text(
                    'No more songs',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: itemCount,
                  itemBuilder: (context, offset) {
                    final index = startIndex + offset;
                    if (isLocal) {
                      final song = controller.localQueue[index];
                      return _InlineLocalQueueTile(
                        song: song,
                        selected: false,
                        onTap: () => unawaited(controller.playLocalQueue(controller.localQueue, index)),
                      );
                    }
                    final song = controller.remoteQueue[index];
                    return _InlineRemoteQueueTile(
                      song: song,
                      selected: false,
                      onTap: () => unawaited(controller.playRemoteQueue(controller.remoteQueue, index)),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _InlineLocalQueueTile extends StatelessWidget {
  final SongModel song;
  final bool selected;
  final VoidCallback onTap;

  const _InlineLocalQueueTile({
    required this.song,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: QueryArtworkWidget(
                id: song.id,
                type: ArtworkType.AUDIO,
                artworkWidth: 46,
                artworkHeight: 46,
                artworkFit: BoxFit.cover,
                quality: 100,
                nullArtworkWidget: const _SmallArtworkFallback(),
                errorBuilder: (_, __, ___) => const _SmallArtworkFallback(),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: _InlineQueueText(
                title: song.title,
                artist: song.artist ?? 'Unknown artist',
                selected: selected,
              ),
            ),
            Icon(
              selected ? Icons.equalizer_rounded : Icons.drag_handle_rounded,
              color: selected ? const Color(0xFFFF2D55) : Colors.white30,
              size: selected ? 22 : 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineRemoteQueueTile extends StatelessWidget {
  final Map<String, dynamic> song;
  final bool selected;
  final VoidCallback onTap;

  const _InlineRemoteQueueTile({
    required this.song,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = song['image']?.toString();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: SizedBox(
                width: 46,
                height: 46,
                child: imageUrl == null || imageUrl.isEmpty
                    ? const _SmallArtworkFallback()
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const _SmallArtworkFallback(),
                      ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: _InlineQueueText(
                title: song['title']?.toString() ?? 'Unknown title',
                artist: song['artist']?.toString() ?? 'Unknown artist',
                selected: selected,
              ),
            ),
            Icon(
              selected ? Icons.equalizer_rounded : Icons.drag_handle_rounded,
              color: selected ? const Color(0xFFFF2D55) : Colors.white30,
              size: selected ? 22 : 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineQueueText extends StatelessWidget {
  final String title;
  final String artist;
  final bool selected;

  const _InlineQueueText({
    required this.title,
    required this.artist,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected ? const Color(0xFFFF6B7A) : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          artist,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CoverArtwork extends StatefulWidget {
  final PlaybackController controller;
  final double width;
  final double height;

  const _CoverArtwork({
    required this.controller,
    required this.width,
    required this.height,
  });

  @override
  State<_CoverArtwork> createState() => _CoverArtworkState();
}

class _CoverArtworkState extends State<_CoverArtwork> {
  String? _cacheKey;
  Widget? _cachedArtwork;

  String get _artworkKey {
    final controller = widget.controller;
    if (controller.isLocalTrack) {
      return 'local-${controller.artworkId ?? 'none'}';
    }
    return 'remote-${controller.artworkUrl ?? 'none'}';
  }

  Widget _buildArtwork() {
    final controller = widget.controller;
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
        errorWidget: (_, __, ___) => const _CoverArtworkFallback(),
      );
    }

    return const _CoverArtworkFallback();
  }

  @override
  Widget build(BuildContext context) {
    final key = _artworkKey;
    if (_cacheKey != key || _cachedArtwork == null) {
      _cacheKey = key;
      _cachedArtwork = _buildArtwork();
    }
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _cachedArtwork,
    );
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

class _PlayerArtwork extends StatefulWidget {
  final PlaybackController controller;
  final double size;

  const _PlayerArtwork({
    required this.controller,
    required this.size,
  });

  @override
  State<_PlayerArtwork> createState() => _PlayerArtworkState();
}

class _PlayerArtworkState extends State<_PlayerArtwork> {
  String? _cacheKey;
  Widget? _cachedArtwork;

  String get _artworkKey {
    final controller = widget.controller;
    if (controller.isLocalTrack) {
      return 'local-${controller.artworkId ?? 'none'}';
    }
    return 'remote-${controller.artworkUrl ?? 'none'}';
  }

  Widget _buildArtwork() {
    final controller = widget.controller;
    if (controller.isLocalTrack && controller.artworkId != null) {
      return QueryArtworkWidget(
        id: controller.artworkId!,
        type: ArtworkType.AUDIO,
        artworkFit: BoxFit.cover,
        artworkWidth: 900,
        artworkHeight: 900,
        quality: 100,
        artworkBorder: BorderRadius.zero,
        nullArtworkWidget: _MiniArtworkFallback(size: widget.size),
        errorBuilder: (_, __, ___) => _MiniArtworkFallback(size: widget.size),
      );
    }

    if (controller.artworkUrl != null) {
      return CachedNetworkImage(
        imageUrl: controller.artworkUrl!,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _MiniArtworkFallback(size: widget.size),
      );
    }

    return _MiniArtworkFallback(size: widget.size);
  }

  @override
  Widget build(BuildContext context) {
    final key = _artworkKey;
    if (_cacheKey != key || _cachedArtwork == null) {
      _cacheKey = key;
      _cachedArtwork = _buildArtwork();
    }
    return SizedBox.expand(child: _cachedArtwork);
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
