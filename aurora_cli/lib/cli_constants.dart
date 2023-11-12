import 'dart:io';

/// Constant name app
final cliName = Platform.environment['SNAP_NAME'] ?? 'aurora_cli';

/// Constant version app
final cliVersion = Platform.environment['SNAP_VERSION'] ?? 'dev';

/// Path to snap folder application
final pathSnap =
    Platform.environment['SNAP'] ?? '${Platform.environment['PWD']}/..';

/// Path to common folder application
final pathUserCommon =
    Platform.environment['SNAP_USER_COMMON'] ?? Platform.environment['PWD']!;
