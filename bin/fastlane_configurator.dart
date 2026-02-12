import 'dart:io';

import 'package:fastlane_configurator/fastlane_configurator.dart';

Future<void> main(List<String> args) async {
  final cli = FastlaneConfiguratorCli();
  final code = await cli.run(args);
  exit(code);
}
