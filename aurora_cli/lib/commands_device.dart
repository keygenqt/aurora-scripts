import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:aurora_cli/cli_configuration.dart';
import 'package:aurora_cli/cli_constants.dart';
import 'package:aurora_cli/cli_di.dart';
import 'package:mason_logger/mason_logger.dart';

import 'package:path/path.dart' as p;
import 'package:async/async.dart' show StreamGroup;

enum CommandsDeviceArg {
  ssh_copy,
  command,
  upload,
  install,
  run,
  firejail,
  firejail_dbus
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
        help: 'Run application in device.',
        defaultsTo: null,
      )
      ..addOption(
        'firejail',
        help: 'Run application in device with firejail in container.',
        defaultsTo: null,
      )
      ..addOption(
        'firejail-dbus',
        help: 'Firejail for Aurora OS 5.0.',
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

  Future<List<Map<String, dynamic>>> _getDevice() async {
    final devices = Configuration.devices();

    String home = Platform.environment['HOME']!;

    if (Platform.environment.containsKey('SNAP_USER_COMMON')) {
      home = '${Platform.environment['SNAP_USER_COMMON']}/../../..';
    }

    final emulator =
        await Directory('$home/AuroraOS/emulator/').listSync().firstOrNull;

    if (emulator != null && argResults?['ssh-copy'] != true) {
      devices.insert(0, {
        'ip': p.basename(emulator.path),
        'port': '2223',
        'pass': '-',
      });
    }

    if (devices.isEmpty) {
      _logger.info('Not a single device was found!');
      _logger.info(
          'Check configuration file: ${pathUserCommon}/configuration.yaml');
      return [];
    }

    if (argResults?['all'] == true) {
      return devices;
    }

    final index = (int.tryParse(argResults?['index'] ?? '') ?? 0) - 1;

    if (argResults?['index'] != null &&
        (index < 0 || index >= devices.length)) {
      _logger.info('You specified the wrong index!');
      return [];
    }

    if (index >= 0 && index < devices.length) {
      _logger.info('');
      return [devices[index]];
    }

    _logger
      ..info('Devices that do this were found:')
      ..info('');

    for (final (index, device) in devices.indexed) {
      _logger.info('${index + 1}. ${device['ip']}');
    }

    _logger
      ..info('')
      ..info('Enter the index of the device:');

    final input = (int.tryParse(stdin.readLineSync() ?? '') ?? 0) - 1;

    _logger.info('');

    if (input >= 0 && input < devices.length) {
      return [devices[input]];
    } else {
      _logger.info('You specified the wrong index!');
      return [];
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

    if (argResults?['firejail-dbus'] != null &&
        argResults!['firejail-dbus'].toString().trim().isNotEmpty) {
      list.add(CommandsDeviceArg.firejail_dbus);
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
      final devices = await _getDevice();

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
          case CommandsDeviceArg.firejail_dbus:
            await _firejail_dbus(device);
            break;
        }
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

  Future<void> _firejail_dbus(Map<String, dynamic> device) async {
    final process = await Process.start(
      p.join(
        pathSnap,
        'scripts',
        'device_app_run_firejail_dbus.sh',
      ),
      [
        '-i',
        device['ip']!,
        '-p',
        device['port']!,
        '-a',
        argResults?['firejail-dbus'],
      ],
    );
    await stdout.addStream(StreamGroup.merge([
      process.stdout,
      process.stderr,
    ]));
  }
}
