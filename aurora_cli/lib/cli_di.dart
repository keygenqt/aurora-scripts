import 'package:get_it/get_it.dart';
import 'package:mason_logger/mason_logger.dart';

final getIt = GetIt.instance;

void initDI() {
  getIt.registerSingleton<Logger>(Logger());
}
