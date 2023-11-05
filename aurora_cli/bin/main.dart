import 'dart:io';

import 'package:aurora_cli/cli_root_args.dart';

Future<void> main(List<String> args) async {
  await _flushThenExit(await CLIRootArgs().run(args));
}

Future<void> _flushThenExit(int? status) {
  return Future.wait<void>([stdout.close(), stderr.close()])
      .then<void>((_) => exit(status ?? 1));
}
