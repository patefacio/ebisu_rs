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

  commonIncludes() => [
    'package:id/id.dart',
    'package:ebisu/ebisu.dart',
    'package:ebisu_rs/entity.dart',
  ];

  commonFeatures(cls) {
    cls
      ..extend = 'RsEntity'
      ..withCustomBlock((blk) => blk.snippets.add('${cls.name}(id) : super(id);'));
  }

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
      ..imports = [ 'package:ebisu_rs/struct.dart' ],
      library('test_repo')
      ..imports = [ 'package:ebisu_rs/repo.dart' ],
      library('test_crate')
      ..imports = [ 'package:ebisu_rs/crate.dart' ],
      library('test_module')
      ..imports = [ 'package:ebisu_rs/module.dart' ],
      library('test_ebisu_rs')
      ..imports = [ 'package:ebisu_rs/ebisu_rs.dart' ],
    ]
    ..libraries = [

      library('ebisu_rs')
      ..importAndExportAll([
        'package:ebisu_rs/repo.dart',
        'package:ebisu_rs/crate.dart',
        'package:ebisu_rs/module.dart',
        'package:ebisu_rs/struct.dart',
      ]),

      library('entity')
      ..imports = [
        'package:id/id.dart',
        'package:ebisu/ebisu.dart',
      ]
      ..classes = [
        class_('rs_entity')
        ..doc = 'Rust entity'
        ..mixins = [ 'Entity' ]
        ..isAbstract = true
        ..members = [
          member('id')
          ..doc = 'Id for the [RsEntity]'
          ..type = 'Id',
        ]
      ],

      library('repo')
      ..imports = commonIncludes()
      ..imports.addAll([
        'dart:io',
        'package:ebisu_rs/crate.dart',
        'package:path/path.dart',
      ])
      ..classes = [
        class_('repo')
        ..withClass(commonFeatures)
        ..members = [
          member('crates')..type = 'List<Crate>'..init = [],
          member('root_path')..access = WO,
        ]
      ],
      
      library('crate')
      ..imports = commonIncludes()
      ..imports.addAll([
        'package:ebisu_rs/module.dart',
      ])
      ..classes = [
        class_('crate')
        ..withClass(commonFeatures)
        ..members = [
          member('root_module')..type = 'Module',
        ],
      ],

      library('module')
      ..imports = commonIncludes()
      ..classes = [
        class_('module')
        ..withClass(commonFeatures)
        ..members.addAll([
          member('modules')..type = 'List<Module>'..init = [],
        ])
      ],
      library('struct')
      ..imports = commonIncludes()
      ..classes = [
        class_('member')
        ..withClass(commonFeatures)        
        ..members = [
          member('type')..doc = 'Type of the member',
        ],
        class_('struct')
        ..withClass(commonFeatures)
        ..members.addAll([
          member('members')..type = 'List<Member>'..init = [],
        ])
        
      ]

    ];

  _logger.info("BOO");
  ebisuRs.generate(generateDrudge:false);

  print('''
**** NON GENERATED FILES ****
${indentBlock(brCompact(nonGeneratedFiles))}
''');
}

String _topDir;
bool _enableLogging = false;
