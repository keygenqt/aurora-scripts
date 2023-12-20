import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:aurora_cli/cli_configuration.dart';
import 'package:aurora_cli/cli_constants.dart';
import 'package:aurora_cli/cli_di.dart';
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

    Map<String, dynamic>? _getPsdk() {
    final psdk = Configuration.psdk();

    if (psdk.isEmpty) {
      _logger.info('Not a single psdk was found!');
      _logger.info(
          'Check configuration file: ${pathUserCommon}/configuration.yaml');
      return null;
    }

    final index = (int.tryParse(argResults?['index'] ?? '') ?? 0) - 1;

    if (argResults?['index'] != null && (index < 0 || index >= psdk.length)) {
      _logger.info('You specified the wrong index!');
      return null;
    }

    if (index >= 0 && index < psdk.length) {
      return psdk[index];
    }

    _logger
      ..info('Platform SDK that do this were found:')
      ..info('');

    for (final (index, item) in psdk.indexed) {
      _logger.info('${index + 1}. ${item['name']}');
    }

    _logger
      ..info('')
      ..info('Enter the index of the psdk:');

    final input = (int.tryParse(stdin.readLineSync() ?? '') ?? 0) - 1;

    _logger.info('');

    if (input >= 0 && input < psdk.length) {
      return psdk[input];
    } else {
      _logger.info('You specified the wrong index!');
      return null;
    }
  }

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

  Future<String?> _getFolderPsdk() async {

    String home = Platform.environment['HOME']!;

    if (Platform.environment.containsKey('SNAP_USER_COMMON')) {
      home = '${Platform.environment['SNAP_USER_COMMON']}/../../..';
    }

    final Directory psdkTargets = Directory(home);
    final List<FileSystemEntity> entities = await psdkTargets.list().toList();
    final List<FileSystemEntity> psdk = [];

    for (final FileSystemEntity entity in entities.whereType<Directory>()) {
      if (!entity.path.contains('Aurora') ||
          !entity.path.contains('Platform')) {
        continue;
      }
      psdk.add(entity);
    }

    if (psdk.isEmpty) {
      _logger.info('Not a single Platform SDK was found!');
      return null;
    }

    final index = (int.tryParse(argResults?['index'] ?? '') ?? 0) - 1;

    if (argResults?['index'] != null && (index < 0 || index >= psdk.length)) {
      _logger.info('You specified the wrong index!');
      return null;
    }

    if (index >= 0 && index < psdk.length) {
      return psdk[index].path;
    }

    _logger
      ..info('Platform SDK that do this were found:')
      ..info('');

    for (final (index, item) in psdk.indexed) {
      _logger.info('${index + 1}. ${p.basename(item.path)}');
    }

    _logger
      ..info('')
      ..info('Enter the index of the psdk:');

    final input = (int.tryParse(stdin.readLineSync() ?? '') ?? 0) - 1;

    _logger.info('');

    if (input >= 0 && input < psdk.length) {
      return psdk[input].path;
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
        final key = _getKey();
        if (key == null) {
          return ExitCode.usage.code;
        }
        await _sign(key);
        break;
      case CommandsPsdkArg.validate:
        await _validate();
        break;
      case CommandsPsdkArg.install:
        final psdk = _getPsdk();
        if (psdk == null) {
          return ExitCode.usage.code;
        }
        await _install(psdk);
        break;
      case CommandsPsdkArg.remove:
        final folder = await _getFolderPsdk();
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

  Future<void> _remove(String folder) async {
    final process = await Process.start(
      p.join(
        pathSnap,
        'scripts',
        'psdk_remove.sh',
      ),
      [
        '-f',
        folder,
      ],
    );
    await stdout.addStream(StreamGroup.merge([
      process.stdout,
      process.stderr,
    ]));
  }
}
