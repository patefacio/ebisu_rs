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
      ..withCustomBlock(
          (blk) => blk.snippets.add('${cls.name}(id) : super(id);'));
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
    ..scripts = []
    ..testLibraries = [
      library('test_struct')..imports = ['package:ebisu_rs/struct.dart'],
      library('test_repo')..imports = ['package:ebisu_rs/repo.dart'],
      library('test_crate')..imports = ['package:ebisu_rs/crate.dart'],
      library('test_module')..imports = ['package:ebisu_rs/module.dart'],
      library('test_ebisu_rs')..imports = ['package:ebisu_rs/ebisu_rs.dart'],
    ]
    ..libraries = [
      library('ebisu_rs')
        ..importAndExportAll([
          'package:ebisu_rs/repo.dart',
          'package:ebisu_rs/crate.dart',
          'package:ebisu_rs/module.dart',
          'package:ebisu_rs/struct.dart',
          'package:ebisu_rs/entity.dart',
          'package:ebisu_rs/trait.dart',
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
            ..values = ['lib_crate', 'app_crate'],
          enum_('module_type')
            ..hasLibraryScopedValues = true
            ..values = [
              'root_module',
              'inline_module',
              'file_module',
              'directory_module'
            ]
        ]
        ..classes = [
          class_('rs_entity')
            ..doc = 'Rust entity'
            ..mixins = ['Entity']
            ..isAbstract = true
            ..members = [
              member('id')
                ..doc = 'Id for the [RsEntity]'
                ..type = 'Id',
            ],
          class_('has_file_path')..isAbstract = true,
          class_('has_code')..isAbstract = true,
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
              member('crates')
                ..type = 'List<Crate>'
                ..init = [],
              member('root_path')..access = WO,
            ]
        ],
      library('crate')
        ..imports = commonIncludes()
        ..includesLogger = true
        ..imports.addAll([
          'package:ebisu_rs/module.dart',
          'package:ebisu_rs/repo.dart',
          'package:ebisu_rs/struct.dart',
          'package:path/path.dart',
        ])
        ..enums = [
          enum_('arg_type')
            ..hasLibraryScopedValues = true
            ..values = [
              'string',
              'i8',
              'i16',
              'i32',
              'i64',
              'u8',
              'u16',
              'u32',
              'u64',
              'isize',
              'usize',
              'f32',
              'f64'
            ].map((primitive) => 'arg_$primitive')
        ]
        ..classes = [
          class_('arg')
            ..doc = '*clap* arg'
            ..members = [
              member('id')
                ..type = 'Id'
                ..access = RO,
              member('doc')..doc = 'Documentation for arg',
              member('short')..doc = 'Short version of argument',
              member('help'),
              member('is_required')..init = false,
              member('is_multiple')..init = false,
              member('takes_value')
                ..type = 'bool'
                ..access = WO,
              member('default_value')..doc = 'Sets default value for arg',
              member('arg_type')
                ..type = 'ArgType'
                ..init = 'argString',
            ],
          class_('command')
            ..doc =
                'Collection of arguments and common features to satisfy *main* and subcommands'
            ..hasCtorSansNew = true
            ..members = [
              member('id')
                ..type = 'Id'
                ..access = RO,
              member('doc')
                ..doc = 'Documentation for app to override default generated',
              member('version'),
              member('author'),
              member('about'),
              member('args')
                ..type = 'List<Arg>'
                ..init = [],
            ],
          class_('clap')
            ..doc = 'Models command line args per *clap* crate'
            ..members = [
              member('crate')..type = 'Crate',
              member('pull_args')
                ..doc = 'Create struct to store args and pull from matches'
                ..init = true,
              member('doc')
                ..doc = 'Documentation for app to override default generated',
              member('args')
                ..type = 'List<Arg>'
                ..init = [],
              member('command')..type = 'Command'..access = RO,
              member('sub_commands')
                ..type = 'List<Command>'
                ..init = [],
            ],
          class_('dependency')
            ..hasCtorSansNew = true
            ..members = [
              member('crate')..ctors = [''],
              member('version')..ctors = [''],
              member('is_build_dependency')..init = false,
              member('path'),
            ],
          class_('crate_toml')
            ..members = [
              member('crate')..type = 'Crate',
              member('deps')
                ..type = 'List<Dependency>'
                ..init = [],
              member('build_deps')
                ..type = 'List<Dependency>'
                ..init = [],
              member('authors')
                ..type = 'List<String>'
                ..init = [],
              member('version')..init = '0.0.1',
              member('license')..init = 'MIT',
              member('homepage'),
              member('description'),
              member('repository'),
              member('documentation'),
              member('keywords')
                ..type = 'List<String>'
                ..init = [],
              member('readme'),
              member('categories')
                ..type = 'List<String>'
                ..init = [],
            ],
          class_('crate')
            ..extend = 'RsEntity'
            ..implement = ['HasFilePath']
            ..members = [
              member('crate_type')..type = 'CrateType',
              member('root_module')..type = 'Module',
              member('file_path')..access = RO,
              member('crate_toml')
                ..type = 'CrateToml'
                ..access = IA,
              member('clap')
                ..doc = 'For app crates a command line argument processor'
                ..type = 'Clap'
                ..access = RO
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
            ..implement = ['HasFilePath', 'HasCode']
            ..mixins = ['IsPub']
            ..members.addAll([
              member('file_path')..access = RO,
              member('module_type')
                ..type = 'ModuleType'
                ..access = RO,
              member('modules')
                ..type = 'List<Module>'
                ..init = [],
              member('structs')
                ..type = 'List<Struct>'
                ..init = [],
              member('code_block')
                ..type = 'CodeBlock'
                ..access = IA
            ])
        ],
      library('trait')
        ..imports = commonIncludes()
        ..classes = [
          class_('type')
            ..implement = ['HasCode']
            ..members.addAll([member('type')]),
          class_('parm')
            ..implement = ['HasCode']
            ..withClass(commonFeatures)
            ..members.addAll([
              member('type')..type = 'Type',
            ]),
          class_('fn')
            ..implement = ['HasCode']
            ..mixins = ['IsPub']
            ..withClass(commonFeatures)
            ..members.addAll([
              member('parms')
                ..type = 'List<Parm>'
                ..init = [],
              member('return_type')..type = 'Type',
            ]),
          class_('trait')
            ..implement = ['HasCode']
            ..mixins = ['IsPub']
            ..withClass(commonFeatures)
            ..members.addAll([
              member('functions')
                ..type = 'List<Fn>'
                ..init = [],
            ])
        ],
      library('struct')
        ..imports = commonIncludes()
        ..classes = [
          class_('member')
            ..implement = ['HasCode']
            ..mixins = ['IsPub']
            ..withClass(commonFeatures)
            ..members = [
              member('type')
                ..doc = 'Type of the member'
                ..init = 'String',
            ],
          class_('struct')
            ..implement = ['HasCode']
            ..mixins = ['IsPub']
            ..withClass(commonFeatures)
            ..members.addAll([
              member('members')
                ..type = 'List<Member>'
                ..init = [],
            ]),
          class_('tuple_struct')
            ..doc = 'Tuple struct'
            ..implement = ['HasCode']
            ..mixins = ['IsPub']
            ..withClass(commonFeatures)
            ..members.addAll([]),
          class_('unit_struct')
            ..doc = 'Unit struct'
            ..implement = ['HasCode']
            ..mixins = ['IsPub']
            ..withClass(commonFeatures)
            ..members.addAll([]),
        ]
    ];

  _logger.info("BOOd");
  ebisuRs.generate(generateDrudge: true);

  print('''
**** NON GENERATED FILES ****
${indentBlock(brCompact(nonGeneratedFiles))}
''');
}

String _topDir;
bool _enableLogging = false;
