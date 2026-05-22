import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

class MiniPlayerHeader extends StatelessWidget {
  final Widget artwork;
  final String title;
  final String artist;
  final double artworkSize;

  const MiniPlayerHeader({
    super.key,
    required this.artwork,
    required this.title,
    required this.artist,
    this.artworkSize = 74,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (artworkSize > 0) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: artworkSize,
              height: artworkSize,
              child: artwork,
            ),
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        const _RoundIcon(icon: Icons.star_border_rounded),
        const SizedBox(width: 10),
        const _RoundIcon(icon: Icons.more_horiz_rounded),
      ],
    );
  }
}

class AudioSlider extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onChanged;

  const AudioSlider({
    super.key,
    required this.position,
    required this.duration,
    required this.onChanged,
  });

  String _format(Duration duration) {
    final safe = duration.isNegative ? Duration.zero : duration;
    final minutes = safe.inMinutes.remainder(60);
    final seconds = safe.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = duration.inSeconds > 0 ? duration.inSeconds : 1;
    final value = position.inSeconds.clamp(0, totalSeconds).toDouble();
    final remaining = duration - position;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
            overlayShape: SliderComponentShape.noOverlay,
            activeTrackColor: Colors.white.withOpacity(0.78),
            inactiveTrackColor: Colors.white.withOpacity(0.24),
          ),
          child: Slider(
            min: 0,
            max: totalSeconds.toDouble(),
            value: value,
            onChanged: (seconds) {
              onChanged(Duration(seconds: seconds.toInt()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _format(position),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '-${_format(remaining)}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ControlButtonsBar extends StatelessWidget {
  final bool isPlaying;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;

  const ControlButtonsBar({
    super.key,
    required this.isPlaying,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: canGoPrevious ? onPrevious : null,
          icon: Icon(
            Icons.fast_rewind_rounded,
            size: 58,
            color: canGoPrevious ? Colors.white : Colors.white24,
          ),
        ),
        const SizedBox(width: 34),
        IconButton(
          onPressed: onPlayPause,
          icon: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 78,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 34),
        IconButton(
          onPressed: canGoNext ? onNext : null,
          icon: Icon(
            Icons.fast_forward_rounded,
            size: 58,
            color: canGoNext ? Colors.white : Colors.white24,
          ),
        ),
      ],
    );
  }
}

class VolumeBar extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const VolumeBar({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          value <= 0.01 ? Icons.volume_mute_rounded : Icons.volume_down_rounded,
          color: Colors.white54,
          size: 22,
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
              overlayShape: SliderComponentShape.noOverlay,
              activeTrackColor: Colors.white.withOpacity(0.76),
              inactiveTrackColor: Colors.white.withOpacity(0.24),
            ),
            child: Slider(
              min: 0,
              max: 1,
              value: value.clamp(0.0, 1.0),
              onChanged: onChanged,
            ),
          ),
        ),
        const Icon(
          Icons.volume_up_rounded,
          color: Colors.white54,
          size: 22,
        ),
      ],
    );
  }
}

class BottomToolsBar extends StatelessWidget {
  final VoidCallback onLyrics;
  final VoidCallback onAirPlay;
  final VoidCallback onQueue;
  final bool queueActive;

  const BottomToolsBar({
    super.key,
    required this.onLyrics,
    required this.onAirPlay,
    required this.onQueue,
    required this.queueActive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          onPressed: onLyrics,
          icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white54),
        ),
        IconButton(
          onPressed: onAirPlay,
          icon: const Icon(Icons.airplay_rounded, color: Colors.white54),
        ),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: queueActive ? Colors.white.withOpacity(0.28) : Colors.transparent,
            border: queueActive ? Border.all(color: const Color(0xFFFF3B24), width: 3) : null,
          ),
          child: IconButton(
            onPressed: onQueue,
            icon: const Icon(Icons.format_list_bulleted_rounded, color: Colors.white70, size: 34),
          ),
        ),
      ],
    );
  }
}

class QueueModeBar extends StatelessWidget {
  final bool automixOn;

  const QueueModeBar({
    super.key,
    required this.automixOn,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _ModePill(icon: Icons.shuffle_rounded)),
        const SizedBox(width: 12),
        const Expanded(child: _ModePill(icon: Icons.repeat_rounded)),
        const SizedBox(width: 12),
        const Expanded(child: _ModePill(icon: Icons.all_inclusive_rounded)),
        const SizedBox(width: 12),
        Expanded(
          child: _ModePill(
            icon: Icons.all_inclusive_rounded,
            active: automixOn,
          ),
        ),
      ],
    );
  }
}

class SongListTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;

  const SongListTile({
    super.key,
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
              borderRadius: BorderRadius.circular(8),
              child: QueryArtworkWidget(
                id: song.id,
                type: ArtworkType.AUDIO,
                artworkWidth: 54,
                artworkHeight: 54,
                artworkFit: BoxFit.cover,
                quality: 100,
                nullArtworkWidget: _ArtworkFallback(size: 54),
                errorBuilder: (_, __, ___) => _ArtworkFallback(size: 54),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    song.artist ?? 'Unknown artist',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.drag_handle_rounded, color: Colors.white38, size: 30),
          ],
        ),
      ),
    );
  }
}

class BlurPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const BlurPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  final IconData icon;
  final bool active;

  const _ModePill({
    required this.icon,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: active ? Colors.white.withOpacity(0.26) : Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: active ? Border.all(color: const Color(0xFFFF3B24), width: 3) : null,
      ),
      child: Icon(icon, color: active ? Colors.black.withOpacity(0.72) : Colors.white, size: 26),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;

  const _RoundIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.12),
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}

class _ArtworkFallback extends StatelessWidget {
  final double size;

  const _ArtworkFallback({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFF222225),
      child: Icon(Icons.music_note_rounded, color: Colors.white54, size: size * 0.48),
    );
  }
}
