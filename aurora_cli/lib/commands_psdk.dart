import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:aurora_cli/cli_configuration.dart';
import 'package:aurora_cli/extension_stream.dart';
import 'package:aurora_cli/cli_constants.dart';
import 'package:aurora_cli/cli_di.dart';
import 'package:aurora_cli/helper.dart';
import 'package:mason_logger/mason_logger.dart';

import 'package:path/path.dart' as p;

enum CommandsPsdkArg {
  installed,
  available,
  install,
  remove,
  validate,
  sign,
}

class CommandsPsdk extends Command<int> {
  CommandsPsdk() {
    argParser
      ..addFlag(
        'installed',
        negatable: false,
        help: 'Get list installed versions Platform SDK.',
      )
      ..addFlag(
        'available',
        negatable: false,
        help: 'Get list available versions Platform SDK.',
      )
      ..addFlag(
        'install',
        negatable: false,
        help: 'Install Platform SDK.',
      )
      ..addFlag(
        'remove',
        negatable: false,
        help: 'Remove Platform SDK.',
      )
      ..addOption(
        'validate',
        help: 'Validate RPM packages.',
        defaultsTo: null,
      )
      ..addOption(
        'sign',
        help: 'Sign (with re-sign) packages.',
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

    if (argResults?['installed'] == true) {
      list.add(CommandsPsdkArg.installed);
    }

    if (argResults?['available'] == true) {
      list.add(CommandsPsdkArg.available);
    }

    if (argResults?['install'] == true) {
      list.add(CommandsPsdkArg.install);
    }

    if (argResults?['remove'] == true) {
      list.add(CommandsPsdkArg.remove);
    }

    if (argResults?['validate'] != null &&
        argResults!['validate'].toString().trim().isNotEmpty) {
      list.add(CommandsPsdkArg.validate);
    }

    if (argResults?['sign'] != null &&
        argResults!['sign'].toString().trim().isNotEmpty) {
      list.add(CommandsPsdkArg.sign);
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
      case CommandsPsdkArg.installed:
        stream = await installed(logger: _logger);
        break;
      case CommandsPsdkArg.available:
        _available(logger: _logger);
        return ExitCode.success.code;
      case CommandsPsdkArg.install:
        stream = await _install(logger: _logger);
        break;
      case CommandsPsdkArg.remove:
        stream = await _remove(logger: _logger);
        break;
      case CommandsPsdkArg.validate:
        stream = await _validate(logger: _logger);
        break;
      case CommandsPsdkArg.sign:
        stream = await _sign(logger: _logger);
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

  Future<Stream<List<int>>?> installed(
      {Logger? logger = null, bool data = false}) async {
    return await Helper.processStream(
      p.join(
        pathSnap,
        'scripts',
        'psdk_installed.sh',
      ),
      environment: {'DATA_ONLY': data.toString()},
    );
  }

  void _available({Logger? logger = null}) async {
    final confPSDK = Configuration.psdk();
    if (confPSDK.isEmpty) {
      logger
        ?..info('Not found installed Platfrom SDK.')
        ..info('Platfrom SDK must be specified in the configuration file.')
        ..info('Configuration file: ${pathUserCommon}/configuration.yaml');
    } else {
      logger
        ?..info('Available Platfrom SDK versions:\n')
        ..info(confPSDK.map((e) => e['version']).toList().join('\n'));
    }
  }

  Future<Stream<List<int>>?> _install({Logger? logger = null}) async {
    final config = Configuration.psdk();
    final versions = config.map((e) => e['version']).toList();
    final index = Helper.indexQuery(versions);
    switch (index) {
      case IndexErrors.emptyList:
        logger?.info('Not found awailable Platform SDK.');
        return null;
      case IndexErrors.wrongIndex:
        logger?.info('You specified the wrong index Platform SDK.');
        return null;
    }
    return await Helper.processStream(
      p.join(
        pathSnap,
        'scripts',
        'psdk_install.sh',
      ),
      arguments: [
        '-v',
        config[index]['version'],
        '-c',
        config[index]['chroot'],
        '-t',
        config[index]['tooling'],
        '-l',
        config[index]['targets'].join(';'),
      ],
    );
  }

  Future<Stream<List<int>>?> _remove({Logger? logger = null}) async {
    final versions = await (await installed(data: true))?.loadList() ?? [];

    if (versions.isNotEmpty) {
      logger?.info('\nBe careful, the directory will be deleted!!!\n');
    }

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
        'psdk_remove.sh',
      ),
      arguments: ['-f', versions[index]],
    );
  }

  Future<Stream<List<int>>?> _validate({Logger? logger = null}) async {
    return await Helper.processStream(
      p.join(
        pathSnap,
        'scripts',
        'psdk_validate.sh',
      ),
      arguments: [
        '-p',
        argResults!['validate'].toString(),
      ],
    );
  }

  Future<Stream<List<int>>?> _sign({Logger? logger = null}) async {
    final config = Configuration.keys();
    final names = config.map((e) => e['name']).toList();
    final index = Helper.indexQuery(names);
    switch (index) {
      case IndexErrors.emptyList:
        logger?.info('Not found keys.');
        return null;
      case IndexErrors.wrongIndex:
        logger?.info('You specified the wrong index key.');
        return null;
    }
    return await Helper.processStream(
      p.join(
        pathSnap,
        'scripts',
        'psdk_sign.sh',
      ),
      arguments: [
        '-k',
        config[index]['key']!,
        '-c',
        config[index]['cert']!,
        '-p',
        argResults!['sign'].toString(),
      ],
    );
  }
}
