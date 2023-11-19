import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:aurora_cli/cli_configuration.dart';
import 'package:aurora_cli/cli_constants.dart';
import 'package:aurora_cli/cli_di.dart';
import 'package:mason_logger/mason_logger.dart';

import 'package:path/path.dart' as p;
import 'package:async/async.dart' show StreamGroup;

enum CommandsDeviceArg { ssh_copy, command, upload, install, run, firejail }

class CommandsDevice extends Command<int> {
  CommandsDevice() {
    argParser
      ..addFlag(
        'ssh-copy',
        help: 'Add ssh key to device.',
        negatable: false,
      )
      ..addOption(
        'command',
        help: 'Execute the command on the device.',
        defaultsTo: null,
      )
      ..addOption(
        'upload',
        help: 'Upload file to Download directory device.',
        defaultsTo: null,
      )
      ..addOption(
        'install',
        help: 'Install RPM package in device.',
        defaultsTo: null,
      )
      ..addOption(
        'run',
        help: 'Run application in device.',
        defaultsTo: null,
      )
      ..addOption(
        'firejail',
        help: 'Run application in device with firejail in container.',
        defaultsTo: null,
      )
      ..addOption(
        'index',
        help: 'Select index.',
        defaultsTo: null,
      );
  }

  @override
  String get description => 'Device helper for Aurora OS.';

  @override
  String get name => 'device';

  Logger get _logger => getIt<Logger>();

  Map<String, dynamic>? _getDevice() {
    final devices = Configuration.devices();

    if (devices.isEmpty) {
      _logger.info('Not a single device was found!');
      _logger.info(
          'Check configuration file: ${pathUserCommon}/configuration.yaml');
      return null;
    }

    final index = (int.tryParse(argResults?['index'] ?? '') ?? 0) - 1;

    if (argResults?['index'] != null &&
        (index < 0 || index >= devices.length)) {
      _logger.info('You specified the wrong index!');
      return null;
    }

    if (index >= 0 && index < devices.length) {
      _logger.info('');
      return devices[index];
    }

    _logger
      ..info('Devices that do this were found:')
      ..info('');

    for (final (index, device) in devices.indexed) {
      _logger.info('${index + 1}. IP: ${device['ip']}');
    }

    _logger
      ..info('')
      ..info('Enter the index of the device:');

    final input = (int.tryParse(stdin.readLineSync() ?? '') ?? 0) - 1;

    _logger.info('');

    if (input >= 0 && input < devices.length) {
      return devices[input];
    } else {
      _logger.info('You specified the wrong index!');
      return null;
    }
  }

  CommandsDeviceArg? _getArg(ArgResults? args) {
    final list = [];

    if (argResults?['ssh-copy'] == true) {
      list.add(CommandsDeviceArg.ssh_copy);
    }

    if (argResults?['command'] != null &&
        argResults!['command'].toString().trim().isNotEmpty) {
      list.add(CommandsDeviceArg.command);
    }

    if (argResults?['upload'] != null &&
        argResults!['upload'].toString().trim().isNotEmpty) {
      list.add(CommandsDeviceArg.upload);
    }

    if (argResults?['install'] != null &&
        argResults!['install'].toString().trim().isNotEmpty) {
      list.add(CommandsDeviceArg.install);
    }

    if (argResults?['run'] != null &&
        argResults!['run'].toString().trim().isNotEmpty) {
      list.add(CommandsDeviceArg.run);
    }

    if (argResults?['firejail'] != null &&
        argResults!['firejail'].toString().trim().isNotEmpty) {
      list.add(CommandsDeviceArg.firejail);
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
    final arg = _getArg(argResults);
    if (arg != null) {
      final device = _getDevice();

      if (device == null) {
        return ExitCode.usage.code;
      }

      switch (arg) {
        case CommandsDeviceArg.ssh_copy:
          await _ssh_copy(device);
          break;
        case CommandsDeviceArg.command:
          await _command(device);
          break;
        case CommandsDeviceArg.upload:
          await _upload(device);
          break;
        case CommandsDeviceArg.install:
          await _install(device);
          break;
        case CommandsDeviceArg.run:
          await _run(device);
          break;
        case CommandsDeviceArg.firejail:
          await _firejail(device);
          break;
      }
    } else {
      return ExitCode.usage.code;
    }
    return ExitCode.success.code;
  }

  Future<void> _ssh_copy(Map<String, dynamic> device) async {
    final process = await Process.start(
      p.join(
        pathSnap,
        'scripts',
        'device_ssh_copy.sh',
      ),
      [
        '-i',
        device['ip']!,
        '-p',
        device['port']!,
      ],
    );
    await stdout.addStream(StreamGroup.merge([
      process.stdout,
      process.stderr,
    ]));
  }

  Future<void> _command(Map<String, dynamic> device) async {
    final process = await Process.start(
      p.join(
        pathSnap,
        'scripts',
        'device_command.sh',
      ),
      [
        '-i',
        device['ip']!,
        '-p',
        device['port']!,
        '-c',
        argResults?['command'],
      ],
    );
    await stdout.addStream(StreamGroup.merge([
      process.stdout,
      process.stderr,
    ]));
  }

  Future<void> _upload(Map<String, dynamic> device) async {
    final process = await Process.start(
      p.join(
        pathSnap,
        'scripts',
        'device_upload.sh',
      ),
      [
        '-i',
        device['ip']!,
        '-p',
        device['port']!,
        '-u',
        argResults!['upload'].toString(),
      ],
    );
    await stdout.addStream(StreamGroup.merge([
      process.stdout,
      process.stderr,
    ]));
  }

  Future<void> _install(Map<String, dynamic> device) async {
    final process = await Process.start(
      p.join(
        pathSnap,
        'scripts',
        'device_install.sh',
      ),
      [
        '-i',
        device['ip']!,
        '-p',
        device['port']!,
        '-r',
        argResults!['install'].toString(),
        '-s',
        device['pass']!,
      ],
    );
    await stdout.addStream(StreamGroup.merge([
      process.stdout,
      process.stderr,
    ]));
  }

  Future<void> _run(Map<String, dynamic> device) async {
    final process = await Process.start(
      p.join(
        pathSnap,
        'scripts',
        'device_app_run.sh',
      ),
      [
        '-i',
        device['ip']!,
        '-p',
        device['port']!,
        '-a',
        argResults?['run'],
      ],
    );
    await stdout.addStream(StreamGroup.merge([
      process.stdout,
      process.stderr,
    ]));
  }

  Future<void> _firejail(Map<String, dynamic> device) async {
    final process = await Process.start(
      p.join(
        pathSnap,
        'scripts',
        'device_app_run_firejail.sh',
      ),
      [
        '-i',
        device['ip']!,
        '-p',
        device['port']!,
        '-a',
        argResults?['firejail'],
      ],
    );
    await stdout.addStream(StreamGroup.merge([
      process.stdout,
      process.stderr,
    ]));
  }
}
