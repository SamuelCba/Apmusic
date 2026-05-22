import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/lyrics.dart';

class LyricsService {
  const LyricsService();

  Future<LyricsData?> fetchLyrics({
    required String artist,
    required String title,
    int? durationSeconds,
  }) async {
    final query = <String, String>{
      'artist_name': artist,
      'track_name': title,
      if (durationSeconds != null) 'duration': durationSeconds.toString(),
    };

    final uri = Uri.https('lrclib.net', '/api/get', query);
    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final syncedLyrics = _parseSyncedLyrics(decoded['syncedLyrics'] as String?);
    if (syncedLyrics != null) {
      return syncedLyrics;
    }

    final plainLyrics = (decoded['plainLyrics'] as String?)?.trim();
    if (plainLyrics == null || plainLyrics.isEmpty) {
      return null;
    }

    final lines = plainLyrics
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map(
          (line) => LyricLine(
            timestamp: Duration.zero,
            text: line,
          ),
        )
        .toList();

    if (lines.isEmpty) {
      return null;
    }

    return LyricsData(lines: lines, isSynced: false);
  }

  LyricsData? _parseSyncedLyrics(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final lines = <LyricLine>[];
    final regex = RegExp(r'\[(\d{1,2}):(\d{2})[.:](\d{2,3})\](.*)');

    for (final rawLine in LineSplitter.split(value)) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final match = regex.firstMatch(line);
      if (match == null) continue;

      final minutes = int.parse(match.group(1)!);
      final seconds = int.parse(match.group(2)!);
      final fraction = match.group(3)!;
      final text = match.group(4)!.trim();
      if (text.isEmpty) continue;

      final milliseconds =
          fraction.length == 2 ? int.parse(fraction) * 10 : int.parse(fraction);
      lines.add(
        LyricLine(
          timestamp: Duration(
            minutes: minutes,
            seconds: seconds,
            milliseconds: milliseconds,
          ),
          text: text,
        ),
      );
    }

    if (lines.isEmpty) {
      return null;
    }

    lines.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return LyricsData(lines: lines, isSynced: true);
  }
}
