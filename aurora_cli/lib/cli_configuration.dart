import 'package:path/path.dart' as p;
import 'package:settings_yaml/settings_yaml.dart';
import 'package:yaml/yaml.dart';
import 'cli_constants.dart';

/// Read file yaml with configuration app
class Configuration {
  static final Map<String, dynamic> _data = SettingsYaml.load(
          pathToSettings: p.join(pathUserCommon, 'configuration.yaml'))
      .valueMap;

  static Map<String, Map<String, String>> sign() {
    final Map<String, Map<String, String>> result = {};
    if (_data['sign'] != null) {
      final sign = _data['sign'] as YamlMap;
      for (final key in sign.keys) {
        try {
          result[key] = {
            'key': sign.value[key]['key']!,
            'cert': sign.value[key]['cert']!,
          };
        } catch (e) {
          print('Get sign: $e');
        }
      }
    }
    return result;
  }

  static List<Map<String, String>> devices() {
    final List<Map<String, String>> result = [];

    if (_data['devices'] != null) {
      final devices = _data['devices'] as YamlList;
      for (final device in devices) {
        try {
          result.add({
            'ip': device['ip']!,
            'pass': device['pass']!,
          });
        } catch (e) {
          print('Get dvices: $e');
        }
      }
    }
    return result;
  }
}
