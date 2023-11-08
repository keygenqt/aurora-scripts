import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:aurora_cli/cli_configuration.dart';
import 'package:aurora_cli/cli_constants.dart';
import 'package:aurora_cli/cli_di.dart';
import 'package:mason_logger/mason_logger.dart';

import 'package:path/path.dart' as p;

enum CommandsPsdkArg { sign }

class CommandsPsdk extends Command<int> {
  CommandsPsdk() {
    argParser
      ..addOption(
        'sign',
        help: 'Sign RPM packages directly from the directory.',
        valueHelp: 'extended|regular|system',
        defaultsTo: null,
      );
  }

  @override
  String get description => 'PSDK helper for Aurora OS.';

  @override
  String get name => 'psdk';

  Logger get _logger => getIt<Logger>();

  CommandsPsdkArg? _getArg(ArgResults? args) {
    final list = [];

    if (argResults?['sign'] != null) {
      switch (argResults?['sign']) {
        case 'extended':
        case 'regular':
        case 'system':
          list.add(CommandsPsdkArg.sign);
          break;
        default:
          _logger.info('Sign keys: extended, regular, system!');
          return null;
      }
    }

    if (list.length > 1) {
      _logger.info('Only one flag at a time!');
      list.clear();
    }
    if (list.isEmpty) {
      printUsage();
    }
    return list.firstOrNull;
  }

  @override
  Future<int> run() async {
    switch (_getArg(argResults)) {
      case CommandsPsdkArg.sign:
        final keys = Configuration.sign()[argResults?['sign']];
        if (keys == null) {
          _logger.info('This key is not added to the configuration!');
          _logger.info(
              'Check configuration file: ${pathUserCommon}/configuration.yaml');
          return ExitCode.usage.code;
        } else {
          _logger
            ..info(await _sign(keys))
            ..detail('Show verbose sign');
        }
        break;
      default:
        return ExitCode.usage.code;
    }
    return ExitCode.success.code;
  }

  Future<String> _sign(Map<String, String> keys) async {
    final result = await Process.run(
      p.join(
        pathSnap,
        'scripts',
        'psdk_sign.sh',
      ),
      [
        '-k',
        keys['key']!,
        '-c',
        keys['cert']!,
      ],
    );
    return result.stderr.toString().isNotEmpty ? result.stderr : result.stdout;
  }
}
