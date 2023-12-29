import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:aurora_cli/cli_constants.dart';
import 'package:aurora_cli/cli_di.dart';
import 'package:aurora_cli/commands_psdk.dart';
import 'package:aurora_cli/extension_stream.dart';
import 'package:aurora_cli/helper.dart';
import 'package:mason_logger/mason_logger.dart';

import 'package:path/path.dart' as p;

enum CommandsFlutterEmbedderArg {
  installed,
  available,
  install,
  remove,
}

class CommandsFlutterEmbedder extends Command<int> {
  CommandsFlutterEmbedder() {
    argParser
      ..addFlag(
        'installed',
        negatable: false,
        help: 'Get list installed versions Flutter Embedder.',
      )
      ..addFlag(
        'available',
        negatable: false,
        help: 'Get list available versions Flutter Embedder.',
      )
      ..addFlag(
        'install',
        negatable: false,
        help: 'Install Flutter Embedder.',
      )
      ..addFlag(
        'remove',
        negatable: false,
        help: 'Remove Flutter Embedder.',
      );
  }

  @override
  String get description => 'Flutter Embedder helper for Aurora OS.';

  @override
  String get name => 'embedder';

  Logger get _logger => getIt<Logger>();

  CommandsFlutterEmbedderArg? _getArg(ArgResults? args) {
    final list = [];

    if (argResults?['installed'] == true) {
      list.add(CommandsFlutterEmbedderArg.installed);
    }

    if (argResults?['available'] == true) {
      list.add(CommandsFlutterEmbedderArg.available);
    }

    if (argResults?['install'] == true) {
      list.add(CommandsFlutterEmbedderArg.install);
    }

    if (argResults?['remove'] == true) {
      list.add(CommandsFlutterEmbedderArg.remove);
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
      case CommandsFlutterEmbedderArg.installed:
        stream = await _installed(logger: _logger);
        break;
      case CommandsFlutterEmbedderArg.available:
        stream = await _available(logger: _logger);
        break;
      case CommandsFlutterEmbedderArg.install:
        stream = await _install(logger: _logger);
        break;
      case CommandsFlutterEmbedderArg.remove:
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
    final versions =
        await (await CommandsPsdk().installed(data: true))?.loadList() ?? [];
    final index = Helper.indexQuery(
        versions.map((e) => p.basename(e).replaceAll('_', ' ')).toList());
    switch (index) {
      case IndexErrors.emptyList:
        logger?.info('Not found installed Platform SDK.');
        return null;
      case IndexErrors.wrongIndex:
        logger?.info('You specified the wrong index Platform SDK.');
        return null;
    }
    return await Helper.processStream(
      p.join(
        pathSnap,
        'scripts',
        'embedder_installed.sh',
      ),
      arguments: ['-f', versions[index]],
      environment: {'DATA_ONLY': data.toString()},
    );
  }

  Future<Stream<List<int>>?> _available(
      {Logger? logger = null, bool data = false}) async {
    return await Helper.processStream(
      p.join(
        pathSnap,
        'scripts',
        'embedder_available.sh',
      ),
      environment: {'DATA_ONLY': data.toString()},
    );
  }

  Future<Stream<List<int>>?> _install({Logger? logger = null}) async {
    final psdk =
        await (await CommandsPsdk().installed(data: true))?.loadList() ?? [];
    final indexPsdk = Helper.indexQuery(
        psdk.map((e) => p.basename(e).replaceAll('_', ' ')).toList());
    switch (indexPsdk) {
      case IndexErrors.emptyList:
        logger?.info('Not found installed Platform SDK.');
        return null;
      case IndexErrors.wrongIndex:
        logger?.info('You specified the wrong index Platform SDK.');
        return null;
    }

    final versions = await (await _available(data: true))?.loadList() ?? [];
    final indexVersion = Helper.indexQuery(versions
        .map(
            (e) => e.replaceAllMapped(RegExp(r'(\d+\.\d+\.\d+)-(.*)'), (match) {
                  return '(${match.group(1)}) ${match.group(2)}';
                }))
        .toList());
    switch (indexVersion) {
      case IndexErrors.emptyList:
        logger?.info('Not found awailable Flutter Embedder.');
        return null;
      case IndexErrors.wrongIndex:
        logger?.info('You specified the wrong index Flutter Embedder.');
        return null;
    }
    return await Helper.processStream(
      p.join(
        pathSnap,
        'scripts',
        'embedder_install.sh',
      ),
      arguments: [
        '-v',
        versions[indexVersion],
        '-p',
        psdk[indexPsdk],
      ],
    );
  }

  Future<Stream<List<int>>?> _remove({Logger? logger = null}) async {
    final psdk =
        await (await CommandsPsdk().installed(data: true))?.loadList() ?? [];
    final index = Helper.indexQuery(
        psdk.map((e) => p.basename(e).replaceAll('_', ' ')).toList());
    switch (index) {
      case IndexErrors.emptyList:
        logger?.info('Not found installed Platform SDK.');
        return null;
      case IndexErrors.wrongIndex:
        logger?.info('You specified the wrong index Platform SDK.');
        return null;
    }
    return await Helper.processStream(
      p.join(
        pathSnap,
        'scripts',
        'embedder_remove.sh',
      ),
      arguments: ['-p', psdk[index]],
    );
  }
}
