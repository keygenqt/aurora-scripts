import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:aurora_cli/cli_constants.dart';
import 'package:aurora_cli/cli_di.dart';
import 'package:mason_logger/mason_logger.dart';

import 'package:path/path.dart' as p;

enum CommandsFlutterArg { install, remove }

class CommandsFlutter extends Command<int> {
  CommandsFlutter() {
    argParser
      ..addFlag(
        'install',
        negatable: false,
        help: 'Install latest Flutter SDK.',
      )
      ..addFlag(
        'remove',
        negatable: false,
        help: 'Remove Flutter SDK.',
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

    if (argResults?['remove'] == true) {
      list.add(CommandsFlutterArg.remove);
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
      case CommandsFlutterArg.install:
        _logger.info(await _install());
        break;
      case CommandsFlutterArg.remove:
        _logger.info(await _remove());
        break;
      default:
        return ExitCode.usage.code;
    }
    return ExitCode.success.code;
  }

  Future<String> _install() async {
    _logger.info('The installation has started, please wait...');
    final result = await Process.run(
      p.join(
        pathSnap,
        'scripts',
        'flutter_install.sh',
      ),
      [],
    );
    return result.stderr.toString().isNotEmpty ? result.stderr : result.stdout;
  }

  Future<String> _remove() async {
    final result = await Process.run(
      p.join(
        pathSnap,
        'scripts',
        'flutter_remove.sh',
      ),
      [],
    );
    return result.stderr.toString().isNotEmpty ? result.stderr : result.stdout;
  }
}