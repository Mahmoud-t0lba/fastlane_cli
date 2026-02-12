import 'dart:convert';
import 'dart:io';

import 'package:fastlane_configurator/fastlane_configurator.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('FastlaneConfiguratorCli', () {
    late List<String> logs;
    late List<String> errors;
    late FastlaneConfiguratorCli cli;

    setUp(() {
      logs = <String>[];
      errors = <String>[];
      cli = FastlaneConfiguratorCli(out: logs.add, err: errors.add);
    });

    test('setup generates fastlane and workflow files', () async {
      final tempDir = await Directory.systemTemp.createTemp('fl_config_setup_');
      addTearDown(() async => tempDir.delete(recursive: true));

      _writeFile(
        p.join(tempDir.path, 'ios', 'Runner.xcodeproj', 'project.pbxproj'),
        'PRODUCT_BUNDLE_IDENTIFIER = com.example.toolbox;\n',
      );
      _writeFile(
        p.join(tempDir.path, 'android', 'app', 'build.gradle.kts'),
        'android { defaultConfig { applicationId = "com.example.toolbox" } }\n',
      );

      final code = await cli.run(<String>[
        'setup',
        '--project-root',
        tempDir.path,
        '--overwrite',
      ]);

      expect(code, 0);
      expect(errors, isEmpty);
      expect(
        File(p.join(tempDir.path, 'fastlane', 'Fastfile')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(tempDir.path, 'fastlane', 'Appfile')).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(tempDir.path, '.github', 'workflows', 'mobile_delivery.yml'),
        ).existsSync(),
        isTrue,
      );

      final fastfileContent = File(
        p.join(tempDir.path, 'fastlane', 'Fastfile'),
      ).readAsStringSync();
      expect(fastfileContent, contains('lane :ci_android'));
      expect(fastfileContent, contains('lane :ci_ios'));
      expect(logs.join('\n'), contains('Setup complete'));
    });

    test('fetch-data writes JSON metadata without GitHub calls', () async {
      final tempDir = await Directory.systemTemp.createTemp('fl_config_fetch_');
      addTearDown(() async => tempDir.delete(recursive: true));

      _writeFile(
        p.join(tempDir.path, 'pubspec.yaml'),
        'name: demo_app\nversion: 2.1.0+13\n',
      );
      _writeFile(
        p.join(tempDir.path, 'ios', 'Runner.xcodeproj', 'project.pbxproj'),
        'PRODUCT_BUNDLE_IDENTIFIER = com.example.demo;\n',
      );
      _writeFile(
        p.join(tempDir.path, 'android', 'app', 'build.gradle.kts'),
        'android { defaultConfig { applicationId = "com.example.demo" } }\n',
      );

      final code = await cli.run(<String>[
        'fetch-data',
        '--project-root',
        tempDir.path,
        '--output-path',
        'fastlane/build_data.json',
        '--no-include-github',
      ]);

      expect(code, 0);
      expect(errors, isEmpty);

      final outputFile = File(
        p.join(tempDir.path, 'fastlane', 'build_data.json'),
      );
      expect(outputFile.existsSync(), isTrue);

      final payload =
          jsonDecode(outputFile.readAsStringSync()) as Map<String, dynamic>;
      final app = payload['app'] as Map<String, dynamic>;
      final identifiers = payload['identifiers'] as Map<String, dynamic>;

      expect(app['name'], 'demo_app');
      expect(app['version_name'], '2.1.0');
      expect(app['version_code'], '13');
      expect(identifiers['ios_bundle_id'], 'com.example.demo');
      expect(identifiers['android_package_name'], 'com.example.demo');
      expect(payload.containsKey('github'), isFalse);
      expect(logs.join('\n'), contains('Metadata written'));
    });
  });
}

void _writeFile(String path, String content) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(content);
}
