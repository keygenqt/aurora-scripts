import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:aurora_cli/cli_configuration.dart';
import 'package:aurora_cli/cli_constants.dart';
import 'package:aurora_cli/cli_di.dart';
import 'package:mason_logger/mason_logger.dart';

import 'package:path/path.dart' as p;

enum CommandsDeviceArg { ssh_copy, command, upload, install, run }

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
      ..addFlag(
        'upload',
        help: 'Upload file to Download directory device.',
        negatable: false,
      )
      ..addFlag(
        'install',
        help: 'Install RPM package in device.',
        negatable: false,
      )
      ..addFlag(
        'run',
        help: 'Run application in device.',
        negatable: false,
      );
  }

  @override
  String get description => 'Device helper for Aurora OS.';

  @override
  String get name => 'device';

  Logger get _logger => getIt<Logger>();

  Map<String, String>? _getDevice() {
    final devices = Configuration.devices();

    if (devices.isEmpty) {
      _logger.info('Not a single device was found!');
      _logger.info(
          'Check configuration file: ${pathUserCommon}/configuration.yaml');
      return null;
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

    if (argResults?['command'] != null) {
      list.add(CommandsDeviceArg.command);
    }

    if (argResults?['upload'] == true) {
      list.add(CommandsDeviceArg.upload);
    }

    if (argResults?['install'] == true) {
      list.add(CommandsDeviceArg.install);
    }

    if (argResults?['run'] == true) {
      list.add(CommandsDeviceArg.run);
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
          _logger.info(await _ssh_copy(device));
          break;
        case CommandsDeviceArg.command:
          _logger.info(await _command(device));
          break;
        case CommandsDeviceArg.upload:
          _logger.info(await _ssh_copy(device));
          break;
        case CommandsDeviceArg.install:
          _logger.info(await _ssh_copy(device));
          break;
        case CommandsDeviceArg.run:
          _logger.info(await _ssh_copy(device));
          break;
      }
    } else {
      return ExitCode.usage.code;
    }
    return ExitCode.success.code;
  }

  Future<String> _ssh_copy(Map<String, String> device) async {
    final result = await Process.run(
      p.join(
        pathSnap,
        'scripts',
        'device_ssh_copy.sh',
      ),
      [
        '-i',
        device['ip']!,
      ],
    );
    return result.stderr.toString().isNotEmpty ? result.stderr : result.stdout;
  }

  Future<String> _command(Map<String, String> device) async {
    final result = await Process.run(
      p.join(
        pathSnap,
        'scripts',
        'device_command.sh',
      ),
      [
        '-i',
        device['ip']!,
        '-c',
        argResults?['command'],
      ],
    );
    return result.stderr.toString().isNotEmpty ? result.stderr : result.stdout;
  }
}