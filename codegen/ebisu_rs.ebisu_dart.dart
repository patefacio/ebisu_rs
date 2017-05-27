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

  makeCtor(klass) => klass.withCustomBlock((blk) => blk.snippets.add('''
${klass.name}(id) : super(id);
'''));
  
  _topDir = dirname(dirname(here));
  final purpose = 'Support for generating rust code';
  System ebisuRs = system('ebisu_rs')
    ..license = 'boost'
    ..pubSpec.homepage = 'https://github.com/patefacio/ebisu_rs'
    ..pubSpec.version = '0.0.0'
    ..pubSpec.doc = purpose
    ..rootPath = _topDir
    ..doc = purpose
    ..scripts = [
    ]
    ..testLibraries = [
      library('test_struct')
      ..imports = [ 'package:ebisu_rs/rs_struct.dart' ],
    ]
    ..libraries = [
      library('ebisu_rs')
      ..includesLogger = true
      ..imports = [
      ],

      library('rs_module'),
      library('rs_struct')
      ..imports = [
        'package:id/id.dart',
        'package:ebisu/ebisu.dart',
      ]
      ..classes = [
        class_('member')
        ..members = [
          member('id'),
          member('type'),
        ],
        class_('struct')
        ..extend = 'Entity'
        ..hasCtorSansNew = true
        ..withClass(makeCtor)
        ..members = [
          member('id'),
          member('members')..type = 'List<Member>'..init = [],
        ]
        
      ]
    ];
  
  ebisuRs.generate(generateDrudge:false);

  print('''
**** NON GENERATED FILES ****
${indentBlock(brCompact(nonGeneratedFiles))}
''');
}

String _topDir;
bool _enableLogging = false;
