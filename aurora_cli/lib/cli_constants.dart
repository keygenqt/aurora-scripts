import 'dart:io';

/// Constant name app
final cliName = Platform.environment['SNAP_NAME']!;

/// Constant version app
final cliVersion = Platform.environment['SNAP_VERSION']!;

/// Path to snap folder application
final pathSnap = Platform.environment['SNAP']!;

/// Path to common folder application
final pathUserCommon = Platform.environment['SNAP_USER_COMMON']!;
