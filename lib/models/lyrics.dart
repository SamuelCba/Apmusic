class LyricLine {
  final Duration timestamp;
  final String text;

  const LyricLine({
    required this.timestamp,
    required this.text,
  });
}

class LyricsData {
  final List<LyricLine> lines;
  final bool isSynced;

  const LyricsData({
    required this.lines,
    required this.isSynced,
  });

  bool get isEmpty => lines.isEmpty;

  int activeIndex(Duration position) {
    if (lines.isEmpty) return -1;
    if (!isSynced) return 0;

    var index = -1;
    for (var i = 0; i < lines.length; i++) {
      if (position >= lines[i].timestamp) {
        index = i;
      } else {
        break;
      }
    }
    return index;
  }
}
