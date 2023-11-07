import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:aurora_cli/cli_di.dart';
import 'package:mason_logger/mason_logger.dart';

enum CommandsPsdkArg { sign, resign }

class CommandsPsdk extends Command<int> {
  CommandsPsdk() {
    argParser
      ..addFlag(
        'sign',
        negatable: false,
        help: 'Sign RPM packages directly from the directory.',
      )
      ..addFlag(
        'resign',
        negatable: false,
        help: 'Re-Sign RPM packages directly from the directory.',
      );
  }

  @override
  String get description => 'PSDK helper for Aurora OS.';

  @override
  String get name => 'psdk';

  Logger get _logger => getIt<Logger>();

  CommandsPsdkArg? _getArg(ArgResults? args) {
    final list = [];
    if (argResults?['sign'] == true) {
      list.add(CommandsPsdkArg.sign);
    }
    if (argResults?['resign'] == true) {
      list.add(CommandsPsdkArg.resign);
    }
    if (list.length > 1) {
      _logger.info('Only one flag at a time!\n');
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
        _logger
          ..info(await _sign())
          ..detail('Show verbose sign');
        break;
      case CommandsPsdkArg.resign:
        _logger
          ..info(await _resign())
          ..detail('Show verbose resign');
        break;
      default:
        return ExitCode.usage.code;
    }
    return ExitCode.success.code;
  }

  Future<String> _sign() async {
    final snap = Platform.environment['SNAP'];
    var result = await Process.run('$snap/scripts/psdk_sign.sh', []);
    return result.stderr.toString().isNotEmpty ? result.stderr : result.stdout;
  }

  Future<String> _resign() async {
    final snap = Platform.environment['SNAP'];
    var result = await Process.run('$snap/scripts/psdk_resign.sh', []);
    return result.stderr.toString().isNotEmpty ? result.stderr : result.stdout;
  }
}
