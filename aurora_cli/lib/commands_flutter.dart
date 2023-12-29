import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:aurora_cli/cli_constants.dart';
import 'package:aurora_cli/cli_di.dart';
import 'package:aurora_cli/extension_stream.dart';
import 'package:aurora_cli/helper.dart';
import 'package:mason_logger/mason_logger.dart';

import 'package:path/path.dart' as p;

enum CommandsFlutterArg {
  installed,
  available,
  install,
  remove,
}

class CommandsFlutter extends Command<int> {
  CommandsFlutter() {
    argParser
      ..addFlag(
        'installed',
        negatable: false,
        help: 'Get list installed versions Flutter SDK.',
      )
      ..addFlag(
        'available',
        negatable: false,
        help: 'Get list available versions Flutter SDK.',
      )
      ..addFlag(
        'install',
        negatable: false,
        help: 'Install Flutter SDK.',
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

    if (argResults?['installed'] == true) {
      list.add(CommandsFlutterArg.installed);
    }

    if (argResults?['available'] == true) {
      list.add(CommandsFlutterArg.available);
    }

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
    Stream<List<int>>? stream;
    switch (_getArg(argResults)) {
      case CommandsFlutterArg.installed:
        stream = await _installed(logger: _logger);
        break;
      case CommandsFlutterArg.available:
        stream = await _available(logger: _logger);
        break;
      case CommandsFlutterArg.install:
        stream = await _install(logger: _logger);
        break;
      case CommandsFlutterArg.remove:
        stream = await _remove(logger: _logger);
        break;
      default:
        return ExitCode.usage.code;
    }
    if (stream == null) {
      return ExitCode.usage.code;
    } else {
      await stdout.addStream(stream);
      return ExitCode.success.code;
    }
  }

  Future<Stream<List<int>>?> _installed(
      {Logger? logger = null, bool data = false}) async {
    return await Helper.processStream(
      p.join(
        pathSnap,
        'scripts',
        'flutter_installed.sh',
      ),
      environment: {'DATA_ONLY': data.toString()},
    );
  }

  Future<Stream<List<int>>?> _available(
      {Logger? logger = null, bool data = false}) async {
    return await Helper.processStream(
      p.join(
        pathSnap,
        'scripts',
        'flutter_available.sh',
      ),
      environment: {'DATA_ONLY': data.toString()},
    );
  }

  Future<Stream<List<int>>?> _install({Logger? logger = null}) async {
    final versions = await (await _available(data: true))?.loadList() ?? [];
    final index = Helper.indexQuery(versions);
    switch (index) {
      case IndexErrors.emptyList:
        logger?.info('Not found awailable Flutter SDK.');
        return null;
      case IndexErrors.wrongIndex:
        logger?.info('You specified the wrong index Flutter SDK.');
        return null;
    }
    return await Helper.processStream(
      p.join(
        pathSnap,
        'scripts',
        'flutter_install.sh',
      ),
      arguments: ['-v', versions[index]],
    );
  }

  Future<Stream<List<int>>?> _remove({Logger? logger = null}) async {
    final versions = await (await _installed(data: true))?.loadList() ?? [];
    final index = Helper.indexQuery(versions);
    switch (index) {
      case IndexErrors.emptyList:
        logger?.info('Not found installed Flutter SDK.');
        return null;
      case IndexErrors.wrongIndex:
        logger?.info('You specified the wrong index Flutter SDK.');
        return null;
    }
    return await Helper.processStream(
      p.join(
        pathSnap,
        'scripts',
        'flutter_remove.sh',
      ),
      arguments: ['-v', versions[index]],
    );
  }
}
