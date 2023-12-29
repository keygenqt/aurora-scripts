import 'dart:io';

import 'package:async/async.dart';
import 'package:aurora_cli/cli_di.dart';
import 'package:mason_logger/mason_logger.dart';

enum IndexErrors {
  emptyList,
  wrongIndex,
}

class Helper {
  static dynamic indexQuery(List<dynamic> list, {String? index = null}) {
    Logger logger = getIt<Logger>();

    if (list.isEmpty) {
      return IndexErrors.emptyList;
    }

    final _index = (int.tryParse(index ?? '') ?? 0) - 1;

    if (index != null && (_index < 0 || _index >= list.length)) {
      return IndexErrors.wrongIndex;
    }

    if (_index >= 0 && _index < list.length) {
      return _index;
    }

    logger.info('Select an available option:\n');

    for (final (_index, item) in list.indexed) {
      logger.info('${_index + 1}. ${item}');
    }

    logger.info('\nEnter the index:');

    final input = (int.tryParse(stdin.readLineSync() ?? '') ?? 0) - 1;

    logger.info('');

    if (input >= 0 && input < list.length) {
      return input;
    } else {
      return IndexErrors.wrongIndex;
    }
  }

  static Future<Stream<List<int>>> processStream(String executable,
      {List<String>? arguments, Map<String, String>? environment}) async {
    final process = await Process.start(executable, arguments ?? [],
        environment: environment);
    return StreamGroup.merge([
      process.stdout,
      process.stderr,
    ]);
  }
}
