import 'package:path/path.dart' as p;
import 'package:settings_yaml/settings_yaml.dart';
import 'package:yaml/yaml.dart';
import 'cli_constants.dart';

/// Read file yaml with configuration app
class Configuration {
  static final Map<String, dynamic> _data = SettingsYaml.load(
          pathToSettings: p.join(pathUserCommon, 'configuration.yaml'))
      .valueMap;

  static List<Map<String, dynamic>> keys() {
    final List<Map<String, dynamic>> result = [];

    if (_data['keys'] != null) {
      final devices = _data['keys'] as YamlList;
      for (final device in devices) {
        try {
          result.add({
            'name': device['name']!,
            'key': device['key']!,
            'cert': device['cert']!,
            'default': device['default'] == true,
          });
        } catch (e) {
          print('Get key: $e');
        }
      }
    }
    return result;
  }

  static List<Map<String, dynamic>> devices() {
    final List<Map<String, dynamic>> result = [];

    if (_data['devices'] != null) {
      final devices = _data['devices'] as YamlList;
      for (final device in devices) {
        try {
          result.add({
            'name': device['ip']!,
            'ip': device['ip']!,
            'port': (device['port'] ?? 22).toString(),
            'pass': device['pass']!,
          });
        } catch (e) {
          print('Get devices: $e');
        }
      }
    }
    return result;
  }

  static List<Map<String, dynamic>> psdk() {
    final List<Map<String, dynamic>> result = [];

    if (_data['psdk'] != null) {
      final psdk = _data['psdk'] as YamlList;
      for (final data in psdk) {
        try {
          final List<String> targets = [];
          for (final target in (data['targets'] as YamlList)) {
            targets.add(target.toString());
          }
          result.add({
            'version': p.basename(data['chroot']!).split('-').elementAt(1),
            'chroot': data['chroot']!,
            'tooling': data['tooling']!,
            'targets': targets,
          });
        } catch (e) {
          print('Get psdk: $e');
        }
      }
    }
    return result;
  }
}
