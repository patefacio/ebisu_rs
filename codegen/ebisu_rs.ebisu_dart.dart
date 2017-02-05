#!/usr/bin/env dart
import 'dart:io';
import 'package:args/args.dart';
import 'package:ebisu/ebisu.dart';
import 'package:ebisu/ebisu_dart_meta.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';

final _logger = new Logger('ebisuRsDart');

main(List<String> args) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.INFO;
  useDartFormatter = true;
  String here = absolute(Platform.script.toFilePath());

  _topDir = dirname(dirname(here));
  final purpose = 'Support for generating rust code';
  useDartFormatter = true;
  System ebisuRs = system('ebisu_rs')
    ..license = 'boost'
    ..pubSpec.homepage = 'https://github.com/patefacio/ebisu_rs'
    ..pubSpec.version = '0.0.0'
    ..pubSpec.doc = purpose
    ..rootPath = _topDir
    ..doc = purpose
    ..scripts = [
    ];
  
  ebisuRs.generate(generateDrudge:false);

  print('''
**** NON GENERATED FILES ****
${indentBlock(brCompact(nonGeneratedFiles))}
''');
}

String _topDir;
bool _enableLogging = false;
