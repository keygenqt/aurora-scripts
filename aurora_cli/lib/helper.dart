import 'dart:io';

import 'package:aurora_cli/cli_constants.dart';
import 'package:mason_logger/mason_logger.dart';

class Helper {
  static Map<String, dynamic>? getItem(
    List<Map<String, dynamic>> data,
    String keyName,
    bool isConfig,
    String? index,
    Logger logger,
  ) {
    if (data.isEmpty) {
      logger.info('Not a single $keyName was found!');
      if (isConfig) {
        logger.info(
            'Check configuration file: ${pathUserCommon}/configuration.yaml');
      }
      return null;
    }

    final _index = (int.tryParse(index ?? '') ?? 0) - 1;

    if (index != null && (_index < 0 || _index >= data.length)) {
      logger.info('You specified the wrong index!');
      return null;
    }

    if (_index >= 0 && _index < data.length) {
      return data[_index];
    }

    logger
      ..info('Select an available option:')
      ..info('');

    for (final (_index, item) in data.indexed) {
      logger.info('${_index + 1}. ${item['name']}');
    }

    logger
      ..info('')
      ..info('Enter the index of the $keyName:');

    final input = (int.tryParse(stdin.readLineSync() ?? '') ?? 0) - 1;

    logger.info('');

    if (input >= 0 && input < data.length) {
      return data[input];
    } else {
      logger.info('You specified the wrong index!');
      return null;
    }
  }
}
