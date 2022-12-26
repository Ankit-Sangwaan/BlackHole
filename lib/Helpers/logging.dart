import 'dart:developer';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initializeLogging() async {
  final Directory tempDir = await getTemporaryDirectory();
  final File logFile = File('${tempDir.path}/logs/logs.log');
  if (!await logFile.exists()) {
    await logFile.create(recursive: true);
  }
  await logFile.writeAsString('');
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) async {
    log('${record.level.name}: ${record.time}: record.message: ${record.message}\nrecord.error: ${record.error}\nrecord.stackTrace: ${record.stackTrace}\n\n');
    await logFile.writeAsString(
      '${record.level.name}: ${record.time}: record.message: ${record.message}\nrecord.error: ${record.error}\nrecord.stackTrace: ${record.stackTrace}\n\n',
      mode: FileMode.append,
    );
  });
}
