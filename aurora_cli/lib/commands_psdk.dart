import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:aurora_cli/cli_configuration.dart';
import 'package:aurora_cli/cli_constants.dart';
import 'package:aurora_cli/cli_di.dart';
import 'package:aurora_cli/helper.dart';
import 'package:mason_logger/mason_logger.dart';

import 'package:path/path.dart' as p;
import 'package:async/async.dart' show StreamGroup;

enum CommandsPsdkArg { sign, validate, install, remove }

class CommandsPsdk extends Command<int> {
  CommandsPsdk() {
    argParser
      ..addOption(
        'sign',
        help: 'Sign ( with re-sign) packages.',
        defaultsTo: null,
      )
      ..addOption(
        'validate',
        help: 'Validate RPM packages.',
        defaultsTo: null,
      )
      ..addFlag(
        'install',
        negatable: false,
        help: 'Install Aurora Platform SDK.',
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

  Future<List<Map<String, dynamic>>> _getFoldersPsdk() async {
    String home = Platform.environment['HOME']!;

    if (Platform.environment.containsKey('SNAP_USER_COMMON')) {
      home = '${Platform.environment['SNAP_USER_COMMON']}/../../..';
    }

    List<Map<String, dynamic>> folders = [];
    final Directory psdkTargets = Directory(home);
    final List<FileSystemEntity> entities = await psdkTargets.list().toList();

    for (final FileSystemEntity entity in entities.whereType<Directory>()) {
      if (!entity.path.contains('Aurora') ||
          !entity.path.contains('Platform')) {
        continue;
      }
      folders.add({
        'name': p.basename(entity.path),
        'path': entity.path,
      });
    }

    return folders;
  }

  CommandsPsdkArg? _getArg(ArgResults? args) {
    final list = [];

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
        final key = Helper.getItem(
          Configuration.keys(),
          'key',
          true,
          argResults?['index'],
          _logger,
        );
        if (key == null) {
          return ExitCode.usage.code;
        }
        await _sign(key);
        break;
      case CommandsPsdkArg.validate:
        await _validate();
        break;
      case CommandsPsdkArg.install:
        final psdk = Helper.getItem(
          Configuration.psdk(),
          'psdk',
          true,
          argResults?['index'],
          _logger,
        );
        if (psdk == null) {
          return ExitCode.usage.code;
        }
        await _install(psdk);
        break;
      case CommandsPsdkArg.remove:
        final folder = Helper.getItem(
          await _getFoldersPsdk(),
          'Platform SDK',
          true,
          argResults?['index'],
          _logger,
        );
        if (folder == null) {
          return ExitCode.usage.code;
        }
        await _remove(folder);
        break;
      default:
        return ExitCode.usage.code;
    }
    return ExitCode.success.code;
  }

  Future<void> _sign(Map<String, dynamic> key) async {
    final process = await Process.start(
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
    await stdout.addStream(StreamGroup.merge([
      process.stdout,
      process.stderr,
    ]));
  }

  Future<void> _validate() async {
    final process = await Process.start(
      p.join(
        pathSnap,
        'scripts',
        'psdk_validate.sh',
      ),
      [
        '-p',
        argResults!['validate'].toString(),
      ],
    );
    await stdout.addStream(StreamGroup.merge([
      process.stdout,
      process.stderr,
    ]));
  }

  Future<void> _install(Map<String, dynamic> psdk) async {
    _logger
      ..info('The installation has started, please wait.')
      ..info("It's not very fast, sometimes data doesn't download quickly...")
      ..info('');
    final process = await Process.start(
      p.join(
        pathSnap,
        'scripts',
        'psdk_install.sh',
      ),
      [
        '-n',
        psdk['name'],
        '-c',
        psdk['chroot'],
        '-t',
        psdk['tooling'],
        '-l',
        psdk['targets'].join(';'),
      ],
    );
    await stdout.addStream(StreamGroup.merge([
      process.stdout,
      process.stderr,
    ]));
  }

  Future<void> _remove(Map<String, dynamic> folder) async {
    final process = await Process.start(
      p.join(
        pathSnap,
        'scripts',
        'psdk_remove.sh',
      ),
      [
        '-f',
        folder['path'],
      ],
    );
    await stdout.addStream(StreamGroup.merge([
      process.stdout,
      process.stderr,
    ]));
  }
}
