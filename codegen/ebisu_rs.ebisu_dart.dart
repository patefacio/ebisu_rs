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
        'package:ebisu_rs/entity.dart',
      ]),

      library('entity')
            ..doc = '''
Support for rust entity *recursive entity graph*.

All rust named items are *RsEntity* instances.'''
      ..imports = [
        'package:id/id.dart',
        'package:ebisu/ebisu.dart',
        'package:path/path.dart',
      ]
      ..enums = [
        enum_('crate_type')
        ..hasLibraryScopedValues = true
        ..values = [ 'lib_crate', 'app_crate' ],
        enum_('module_type')
        ..hasLibraryScopedValues = true
        ..values = [ 'root_module', 'inline_module', 'file_module', 'directory_module' ]
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
        ],

        class_('has_file_path')
        ..isAbstract = true,

        class_('has_code')
        ..isAbstract = true,

        class_('is_pub')
        ..members = [
          member('is_pub')..init = false,
        ]
      ],

      library('repo')
      ..doc = 'Library supporting generation of a rust repo'
      ..imports = commonIncludes()
      ..imports.addAll([
        'dart:io',
        'package:ebisu_rs/crate.dart',
        'package:path/path.dart',
      ])
      ..includesLogger = true
      ..classes = [
        class_('repo')
        ..doc = 'A rust repo consisting of one or more crates.'
        ..withClass(commonFeatures)
        ..members = [
          member('crates')..type = 'List<Crate>'..init = [],
          member('root_path')..access = WO,
        ]
      ],
      
      library('crate')
      ..imports = commonIncludes()
      ..includesLogger = true
      ..imports.addAll([
        'package:ebisu_rs/module.dart',
        'package:ebisu_rs/repo.dart',
        'package:path/path.dart',
      ])
      ..classes = [
        class_('crate')
        ..extend = 'RsEntity'
        ..implement = [ 'HasFilePath' ]
        ..members = [
          member('crate_type')..type = 'CrateType',
          member('root_module')..type = 'Module',
          member('file_path')..access = RO,
        ],
      ],

      library('module')
      ..imports = commonIncludes()
      ..imports.addAll([
        'package:path/path.dart',
        'package:ebisu_rs/struct.dart',
        'package:ebisu_rs/crate.dart',
      ])
      ..includesLogger = true
      ..classes = [
        class_('module')
        ..extend = 'RsEntity'
        ..implement = [ 'HasFilePath', 'HasCode' ]
        ..mixins = [ 'IsPub' ]
        ..members.addAll([
          member('file_path')..access = RO,
          member('module_type')..type = 'ModuleType'..access = RO,
          member('modules')..type = 'List<Module>'..init = [],
          member('structs')..type = 'List<Struct>'..init = [],
        ])
      ],
      library('struct')
      ..imports = commonIncludes()
      ..classes = [
        class_('member')
        ..implement = [ 'HasCode' ]
        ..mixins = [ 'IsPub' ]
        ..withClass(commonFeatures)        
        ..members = [
          member('type')..doc = 'Type of the member'..init = 'String',
        ],
        class_('struct')
        ..implement = [ 'HasCode' ]
        ..mixins = [ 'IsPub' ]
        ..withClass(commonFeatures)
        ..members.addAll([
          member('members')..type = 'List<Member>'..init = [],
        ])
        
      ]

    ];

  _logger.info("BOOd");
  ebisuRs.generate(generateDrudge:true);

  print('''
**** NON GENERATED FILES ****
${indentBlock(brCompact(nonGeneratedFiles))}
''');
}

String _topDir;
bool _enableLogging = false;
