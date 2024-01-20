import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:aurora_cli/cli_configuration.dart';
import 'package:aurora_cli/cli_constants.dart';
import 'package:aurora_cli/cli_di.dart';
import 'package:aurora_cli/helper.dart';
import 'package:mason_logger/mason_logger.dart';

import 'package:path/path.dart' as p;

enum CommandsDeviceArg {
  ssh_copy,
  command,
  upload,
  install,
  run,
}

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
        help: 'Run application in device in container.',
        defaultsTo: null,
      )
      ..addOption(
        'index',
        help: 'Select index.',
        defaultsTo: null,
      )
      ..addFlag(
        'all',
        negatable: false,
        help: 'Select all devices.',
      );
  }

  @override
  String get description => 'Device helper for Aurora OS.';

  @override
  String get name => 'device';

  Logger get _logger => getIt<Logger>();

  Future<List<Map<String, dynamic>>> _getDevices() async {
    final devices = Configuration.devices();

    String home = Platform.environment['HOME']!;

    if (Platform.environment.containsKey('SNAP_USER_COMMON')) {
      home = '${Platform.environment['SNAP_USER_COMMON']}/../../..';
    }

    final emulatorDir = await Directory('$home/AuroraOS/emulator/');

    if (await emulatorDir.exists() && argResults?['ssh-copy'] != true) {
      final emulator = emulatorDir.listSync()
          .where((e) => p.basename(e.path).contains('AuroraOS'))
          .firstOrNull;
      if (emulator != null) {
        devices.insert(0, {
          'name': p.basename(emulator.path),
          'ip': p.basename(emulator.path),
          'port': '2223',
          'pass': '-',
        });
      }
    }
    return devices;
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
    final arg = _getArg(argResults);
    if (arg != null) {
      final devices = await _getDevices();

      if (argResults?['all'] != true) {
        final index = Helper.indexQuery(
          devices.map((e) => e['name']).toList(),
          index: argResults?['index'],
        );
        switch (index) {
          case IndexErrors.emptyList:
            _logger.info('Not found installed Platform SDK.');
            return ExitCode.usage.code;
          case IndexErrors.wrongIndex:
            _logger.info('You specified the wrong index Platform SDK.');
            return ExitCode.usage.code;
        }
        final device = devices[index];
        devices.clear();
        devices.add(device);
      }

      if (devices.isEmpty) {
        return ExitCode.usage.code;
      }

      for (final device in devices) {
        if (devices.length > 1) {
          _logger
            ..info('')
            ..info('-> Run "${arg.name}", device: ${device['ip']}...')
            ..info('');
        }
        switch (arg) {
          case CommandsDeviceArg.ssh_copy:
            stream = await _ssh_copy(device);
            break;
          case CommandsDeviceArg.command:
            stream = await _command(device);
            break;
          case CommandsDeviceArg.upload:
            stream = await _upload(device);
            break;
          case CommandsDeviceArg.install:
            stream = await _install(device);
            break;
          case CommandsDeviceArg.run:
            stream = await _run(device);
            break;
        }

        if (stream == null) {
          return ExitCode.usage.code;
        } else {
          await stdout.addStream(stream);
        }
      }
    } else {
      return ExitCode.usage.code;
    }
    return ExitCode.success.code;
  }

  Future<Stream<List<int>>?> _ssh_copy(Map<String, dynamic> device) async {
    return await Helper.processStream(
      p.join(
        pathSnap,
        'scripts',
        'device_ssh_copy.sh',
      ),
      arguments: [
        '-i',
        device['ip']!,
        '-p',
        device['port']!,
      ],
    );
  }

  Future<Stream<List<int>>?> _command(Map<String, dynamic> device) async {
    return await Helper.processStream(
      p.join(
        pathSnap,
        'scripts',
        'device_command.sh',
      ),
      arguments: [
        '-i',
        device['ip']!,
        '-p',
        device['port']!,
        '-c',
        argResults?['command'],
      ],
    );
  }

  Future<Stream<List<int>>?> _upload(Map<String, dynamic> device) async {
    return await Helper.processStream(
      p.join(
        pathSnap,
        'scripts',
        'device_upload.sh',
      ),
      arguments: [
        '-i',
        device['ip']!,
        '-p',
        device['port']!,
        '-u',
        argResults!['upload'].toString(),
      ],
    );
  }

  Future<Stream<List<int>>?> _install(Map<String, dynamic> device) async {
    return await Helper.processStream(
      p.join(
        pathSnap,
        'scripts',
        'device_install.sh',
      ),
      arguments: [
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
  }

  Future<Stream<List<int>>?> _run(Map<String, dynamic> device) async {
    return await Helper.processStream(
      p.join(
        pathSnap,
        'scripts',
        'device_app_run.sh',
      ),
      arguments: [
        '-i',
        device['ip']!,
        '-p',
        device['port']!,
        '-a',
        argResults?['run'],
      ],
    );
  }
}
