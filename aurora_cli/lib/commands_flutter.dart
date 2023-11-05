import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:aurora_cli/cli_di.dart';
import 'package:mason_logger/mason_logger.dart';

enum CommandsFlutterArg { install, version }

class CommandsFlutter extends Command<int> {
  CommandsFlutter() {
    argParser
      ..addFlag(
        'install',
        negatable: false,
        help: 'Install latest version Flutter.',
      )
      ..addFlag(
        'version',
        negatable: false,
        help: 'Print the current version Flutter.',
      );
  }

  @override
  String get description => 'Flutter helper for Aurora OS.';

  @override
  String get name => 'flutter';

  Logger get _logger => getIt<Logger>();

  CommandsFlutterArg? _getArg(ArgResults? args) {
    final list = [];
    if (argResults?['install'] == true) {
      list.add(CommandsFlutterArg.install);
    }
    if (argResults?['version'] == true) {
      list.add(CommandsFlutterArg.version);
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
      case CommandsFlutterArg.install:
        _logger
          ..info(await _install())
          ..detail('Show verbose install');
        break;
      case CommandsFlutterArg.version:
        _logger
          ..info('Run version')
          ..detail('Show verbose version');
        break;
      default:
        return ExitCode.usage.code;
    }
    return ExitCode.success.code;
  }

  Future<String> _install() async {
    var result = await Process.run(
        '/home/keygenqt/Documents/Home/aurora-scripts/scripts/install_flutter.sh',
        []);
    return result.stderr.toString().isNotEmpty ? result.stderr : result.stdout;
  }
}
