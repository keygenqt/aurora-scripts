import 'dart:convert';

import 'package:async/async.dart';

extension ExtCameraController on Stream<List<int>> {
  Future<String?> loadString() async {
    final broadcastStream = await asBroadcastStream().firstOrNull;
    if (broadcastStream == null) {
      return null;
    }
    return String.fromCharCodes(broadcastStream).trim();
  }

  Future<List<String>> loadList() async {
    final result = await loadString();
    if (result == null) {
      return [];
    }
    return LineSplitter().convert(result);
  }
}
