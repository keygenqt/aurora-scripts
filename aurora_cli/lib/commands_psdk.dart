import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:aurora_cli/cli_configuration.dart';
import 'package:aurora_cli/cli_constants.dart';
import 'package:aurora_cli/cli_di.dart';
import 'package:mason_logger/mason_logger.dart';

import 'package:path/path.dart' as p;

enum CommandsPsdkArg { sign, install, remove }

class CommandsPsdk extends Command<int> {
  CommandsPsdk() {
    argParser
      ..addOption(
        'sign',
        help: 'Sign ( with re-sign) packages.',
        defaultsTo: null,
      )
      ..addFlag(
        'install',
        negatable: false,
        help: 'Install Aurora Platform SDK version 4.0.2.249.',
      )
      ..addFlag(
        'remove',
        negatable: false,
        help: 'Remove Aurora Platform SDK.',
      )
      ..addOption(
        'index',
        help: 'Select index.',
        defaultsTo: null,
      );
  }

  @override
  String get description => 'PSDK helper for Aurora OS.';

  @override
  String get name => 'psdk';

  Logger get _logger => getIt<Logger>();

  Map<String, dynamic>? _getKey() {
    final keys = Configuration.keys();

    if (keys.isEmpty) {
      _logger.info('Not a single key was found!');
      _logger.info(
          'Check configuration file: ${pathUserCommon}/configuration.yaml');
      return null;
    }

    final index = (int.tryParse(argResults?['index'] ?? '') ?? 0) - 1;

    if (argResults?['index'] != null && (index < 0 || index >= keys.length)) {
      _logger.info('You specified the wrong index!');
      return null;
    }

    if (index >= 0 && index < keys.length) {
      return keys[index];
    }

    _logger
      ..info('Keys that do this were found:')
      ..info('');

    for (final (index, key) in keys.indexed) {
      _logger.info('${index + 1}. Name: ${key['name']}');
    }

    _logger
      ..info('')
      ..info('Enter the index of the key:');

    final input = (int.tryParse(stdin.readLineSync() ?? '') ?? 0) - 1;

    _logger.info('');

    if (input >= 0 && input < keys.length) {
      return keys[input];
    } else {
      _logger.info('You specified the wrong index!');
      return null;
    }
  }

  CommandsPsdkArg? _getArg(ArgResults? args) {
    final list = [];

    if (argResults?['install'] == true) {
      list.add(CommandsPsdkArg.install);
    }

    if (argResults?['remove'] == true) {
      list.add(CommandsPsdkArg.remove);
    }

    if (argResults?['sign'] != null) {
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
    switch (_getArg(argResults)) {
      case CommandsPsdkArg.sign:
        final key = _getKey();
        if (key == null) {
          return ExitCode.usage.code;
        }
        _logger
          ..info(await _sign(key))
          ..detail('Show verbose sign');
        break;
      case CommandsPsdkArg.install:
        _logger.info(await _install());
        break;
      case CommandsPsdkArg.remove:
        _logger.info(await _remove());
        break;
      default:
        return ExitCode.usage.code;
    }
    return ExitCode.success.code;
  }

  Future<String> _sign(Map<String, dynamic> key) async {
    final result = await Process.run(
      p.join(
        pathSnap,
        'scripts',
        'psdk_sign.sh',
      ),
      [
        '-k',
        key['key']!,
        '-c',
        key['cert']!,
        '-p',
        argResults!['sign'].toString(),
      ],
    );
    return result.stderr.toString().isNotEmpty ? result.stderr : result.stdout;
  }

  Future<String> _install() async {
    _logger
      ..info('The installation has started, please wait.')
      ..info("It's not very fast, sometimes data doesn't download quickly...")
      ..info('');
    final result = await Process.run(
      p.join(
        pathSnap,
        'scripts',
        'psdk_install.sh',
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
        'psdk_remove.sh',
      ),
      [],
    );
    return result.stderr.toString().isNotEmpty ? result.stderr : result.stdout;
  }
}
