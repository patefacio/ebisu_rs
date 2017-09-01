#!/usr/bin/env dart
import 'dart:io';
import 'package:ebisu/ebisu.dart';
import 'package:ebisu/ebisu_dart_meta.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';

final _logger = new Logger('ebisuRsDart');

main(List<String> args) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
  useDartFormatter = true;
  String here = absolute(Platform.script.toFilePath());

  commonIncludes() => [
        'package:ebisu/ebisu.dart',
        'package:ebisu_rs/entity.dart',
      ];

  commonFeatures(cls) {
    cls
      ..extend = 'RsEntity'
      ..withCustomBlock(
          (blk) => blk.snippets.add('${cls.name}(dynamic id) : super(id);'));
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
      library('test_attribute')..imports = ['package:ebisu_rs/attribute.dart'],
      library('test_type')..imports = ['package:ebisu_rs/type.dart'],
      library('test_struct')..imports = ['package:ebisu_rs/struct.dart'],
      library('test_repo')..imports = ['package:ebisu_rs/repo.dart'],
      library('test_crate')..imports = ['package:ebisu_rs/crate.dart'],
      library('test_module')..imports = ['package:ebisu_rs/module.dart'],
      library('test_trait')..imports = ['package:ebisu_rs/trait.dart'],
      library('test_impl')..imports = ['package:ebisu_rs/impl.dart'],
      library('test_generic')..imports = ['package:ebisu_rs/generic.dart'],
      library('test_enumeration')
        ..imports = ['package:ebisu_rs/enumeration.dart'],
      library('test_ebisu_rs')..imports = ['package:ebisu_rs/ebisu_rs.dart'],
      library('test_dependency')
        ..imports = ['package:ebisu_rs/dependency.dart'],
    ]
    ..libraries = [
      library('ebisu_rs')
        ..exports.addAll([
          'package:ebisu_rs/attribute.dart',
          'package:ebisu_rs/dependency.dart',
          'package:ebisu_rs/enumeration.dart',
          'package:ebisu_rs/field.dart',
          'package:ebisu_rs/generic.dart',
          'package:ebisu_rs/macro.dart',
          'package:ebisu_rs/type.dart',
          'package:ebisu_rs/repo.dart',
          'package:ebisu_rs/crate.dart',
          'package:ebisu_rs/module.dart',
          'package:ebisu_rs/struct.dart',
          'package:ebisu_rs/entity.dart',
          'package:ebisu_rs/trait.dart',
          'package:ebisu_rs/impl.dart',
        ]),
      library('entity')
        ..doc = '''
Support for rust entity *recursive entity graph*.

All rust named items are *RsEntity* instances.'''
        ..includesLogger = true
        ..imports = [
          'package:id/id.dart',
          'package:ebisu/ebisu.dart',
          'package:glob/glob.dart',
          'dart:mirrors',
          'dart:io',
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
            ],
          class_('has_code_block')
            ..isAbstract = true
            ..members = [member('code_block')..type = 'CodeBlock']
        ],

      library('generic')
        ..imports = [
          'package:ebisu_rs/trait.dart',
        ]
        ..importAndExportAll([
          'package:id/id.dart',
          'package:ebisu_rs/entity.dart',
          'package:ebisu_rs/type.dart',
          'package:quiver/iterables.dart',
        ])
        ..classes = [
          class_('lifetime')
            ..extend = 'RsEntity'
            ..defaultMemberAccess = RO
            ..implement = ['HasCode', 'Comparable<Lifetime>']
            ..members = [],
          class_('type_parm')
            ..withClass(commonFeatures)
            ..implement = ['HasCode']
            ..members = [
              member('bounds')
                ..type = 'List<dynamic>'
                ..init = []
                ..access = RO,
            ],
          class_('generic')
            ..defaultMemberAccess = RO
            ..members = [
              member('lifetimes')
                ..type = 'List<Lifetime>'
                ..init = [],
              member('type_parms')
                ..type = 'List<TypeParm>'
                ..init = [],
            ],
          class_('generic_type')
            ..extend = 'RsType'
            ..members = [
              member('type')..type = 'RsType',
              member('lifetimes')
                ..type = 'List<Id>'
                ..access = RO
                ..init = [],
              member('type_args')
                ..type = 'List<RsType>'
                ..access = RO
                ..init = [],
            ],
        ],

      library('enumeration')
        ..doc = 'Library for enums'
        ..imports = commonIncludes()
        ..importAndExportAll([
          'package:ebisu_rs/field.dart',
          'package:ebisu_rs/macro.dart',
          'package:ebisu_rs/type.dart',
        ])
        ..classes = [
          class_('variant')
            ..isAbstract = true
            ..implement = ['HasCode']
            ..defaultMemberAccess = RO
            ..withClass(commonFeatures)
            ..members = [],
          class_('unit_variant')
            ..extend = 'Variant'
            ..members = [member('value')..type = 'dynamic'],
          class_('tuple_variant')
            ..extend = 'Variant'
            ..implement = ['HasCode']
            ..members = [
              member('fields')
                ..type = 'List<TupleField>'
                ..access = RO
                ..init = [],
            ],
          class_('struct_variant')
            ..extend = 'Variant'
            ..members = [
              member('fields')
                ..type = 'List<Field>'
                ..access = RO
                ..init = []
            ],
          class_('enum')
            ..implement = ['HasCode']
            ..mixins = ['IsPub', 'Derives']
            ..defaultMemberAccess = RO
            ..withClass(commonFeatures)
            ..members = [
              member('variants')
                ..type = 'List<Variant>'
                ..init = [],
              member('use_self')
                ..init = false
                ..access = RW
                ..doc = 'If self includes *use self::<name>::*;'
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

      // dependency library
      library('dependency')
        ..imports = ['package:ebisu/ebisu.dart']
        ..includesLogger = true
        ..enums = [
          enum_('compare_op')
            ..hasLibraryScopedValues = true
            ..values = ['gt', 'lt', 'ge', 'le', 'eq', 'tilda', 'caret']
        ]
        ..classes = [
          class_('version')
            ..doc =
                'Models a [*Semantic Versioning*](http://semver.org/) version'
            ..members = [
              member('major')..type = 'int',
              member('minor')..type = 'int',
              member('patch')..type = 'int',
            ],
          class_('version_constraint')
            ..doc = 'Models single constriant in *VersionSpec*'
            ..members = [
              member('compare_op')..type = 'CompareOp',
              member('version')..type = 'Version',
            ],
          class_('version_spec')
            ..doc =
                'Models a crate verion spec (eg containing caret, constraints)'
            ..members = [
              member('constraints')
                ..type = 'List<VersionConstraint>'
                ..init = []
            ],
          class_('dependency')
            ..members = [
              member('crate'),
              member('version')
                ..type = 'VersionSpec'
                ..access = RO,
              member('path'),
              member('optional')..init = false,
              member('is_build_dependency')..init = false,
            ],
        ],

      // crate library
      library('crate')
        ..imports = commonIncludes()
        ..includesLogger = true
        ..imports.addAll([
          'package:id/id.dart',
          'package:quiver/iterables.dart',
        ])
        ..importAndExportAll([
          'package:ebisu_rs/enumeration.dart',
          'package:ebisu_rs/module.dart',
          'package:ebisu_rs/repo.dart',
          'package:ebisu_rs/struct.dart',
          'package:ebisu_rs/type.dart',
          'package:path/path.dart',
        ])
        ..importAndExportAll(['package:ebisu_rs/dependency.dart'])
        ..enums = [
          enum_('arg_type')
            ..hasLibraryScopedValues = true
            ..values = [
              'bool',
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
            ].map((primitive) => 'arg_$primitive'),
          enum_('logger_type')
            ..hasLibraryScopedValues = true
            ..values = ['env_logger', 'flexi_logger']
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
              member('default_value')..doc = 'Sets default value for arg',
              member('arg_type')
                ..type = 'ArgType'
                ..init = 'argString',
            ],
          class_('command')
            ..doc =
                'Collection of arguments and common features to satisfy *main* and subcommands'
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
              member('command')
                ..type = 'Command'
                ..access = RO,
              member('sub_commands')
                ..type = 'List<Command>'
                ..init = [],
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
              member('root_module')
                ..type = 'Module'
                ..access = RO,
              member('file_path')..access = RO,
              member('logger_type')..type = 'LoggerType',
              member('crate_toml')
                ..type = 'CrateToml'
                ..access = IA,
              member('clap')
                ..doc = 'For app crates a command line argument processor'
                ..type = 'Clap'
                ..access = RO
            ],
        ],
      library('attribute')
        ..imports = ['package:id/id.dart', 'package:ebisu_rs/entity.dart']
        ..classes = [
          class_('attr')
            ..isAbstract = true
            ..members = [],
          class_('str_attr')
            ..extend = 'Attr'
            ..members = [
              member('attr')
                ..access = RO
                ..doc = 'Value of attribute',
            ],
          class_('id_attr')
            ..extend = 'Attr'
            ..members = [
              member('value')
                ..doc = 'Value of attribute'
                ..type = 'Id',
            ],
          class_('key_value_attr')
            ..extend = 'Attr'
            ..members = [
              member('key')
                ..type = 'Id'
                ..doc = 'Key if form is key/value',
              member('value')..doc = 'Value of attribute'
            ],
          class_('and')
            ..extend = 'Attr'
            ..members = [
              member('attrs')
                ..type = 'List<Attr>'
                ..init = [],
            ],
          class_('has_attributes')
            ..isAbstract = true
            ..members = [
              member('attrs')
                ..type = 'List<Attr>'
                ..init = [],
            ]
        ],
      library('module')
        ..imports = commonIncludes()
        ..importAndExportAll([
          'package:path/path.dart',
          'package:ebisu_rs/attribute.dart',
          'package:ebisu_rs/struct.dart',
          'package:ebisu_rs/crate.dart',
          'package:ebisu_rs/trait.dart',
          'package:ebisu_rs/impl.dart',
          'package:quiver/iterables.dart',
          'dart:io',
        ])
        ..includesLogger = true
        ..enums = [
          enum_('main_code_block')
            ..hasLibraryScopedValues = true
            ..values = [
              enumValue(id('main_open'))
                ..doc =
                    'The custom block appearing just after *main* is opened',
              enumValue(id('main_close'))
                ..doc =
                    'The custom block appearing just after *main* is closed',
            ],
          enum_('module_code_block')
            ..hasLibraryScopedValues = true
            ..values = [
              enumValue(id('module_top'))
                ..doc =
                    'The custom block appearing just after imports, mod statements and usings',
              enumValue(id('module_bottom'))
                ..doc = 'The custom block appearing at end of module',
            ],
        ]
        ..classes = [
          class_('import')
            ..members = [
              member('import')
                ..doc = 'Name of crate to import'
                ..access = RO
                ..isFinal = true,
              member('uses_macros')..init = false
            ],
          class_('module')
            ..extend = 'RsEntity'
            ..implement = ['HasFilePath', 'HasCode']
            ..mixins = ['IsPub', 'HasAttributes', 'HasTypeAliases']
            ..members.addAll([
              member('file_path')..access = RO,
              member('module_type')..type = 'ModuleType',
              member('modules')
                ..type = 'List<Module>'
                ..init = [],
              member('imports')
                ..type = 'List<Import>'
                ..init = []
                ..access = RO,
              member('enums')
                ..type = 'List<Enum>'
                ..init = [],
              member('structs')
                ..type = 'List<Struct>'
                ..init = [],
              member('traits')
                ..type = 'List<Trait>'
                ..init = [],
              member('impls')
                ..type = 'List<Impl>'
                ..init = [],
              member('module_code_blocks')
                ..type = 'Map<ModuleCodeBlock, CodeBlock>'
                ..init = {}
                ..access = RO,
              member('main_code_blocks')
                ..type = 'Map<MainCodeBlock, CodeBlock>'
                ..init = {}
                ..access = RO,
              member('use_clippy')
                ..doc = 'Include *clippy* support'
                ..init = false,
              member('uses')
                ..doc = 'List of use symbols for module'
                ..init = [],
            ])
        ],

      // trait library
      library('trait')
        ..imports.add('"package:ebisu/ebisu.dart" hide codeBlock')
        ..importAndExportAll([
          'package:ebisu_rs/entity.dart',
          'package:ebisu_rs/attribute.dart',
          'package:ebisu_rs/generic.dart',
          'package:ebisu_rs/type.dart',
        ])
        ..classes = [
          class_('parm')
            ..extend = 'RsEntity'
            ..implement = ['HasCode']
            ..members.addAll([
              member('type')
                ..type = 'RsType'
                ..isFinal = true,
              member('is_mutable')..init = false,
            ]),
          class_('self_parm')..extend = 'Parm',
          class_('self_ref_parm')..extend = 'Parm',
          class_('self_ref_mutable_parm')..extend = 'Parm',
          class_('fn')
            ..extend = 'RsEntity'
            ..implement = ['HasCode']
            ..mixins = ['IsPub', 'Generic', 'HasAttributes', 'HasCodeBlock']
            ..members.addAll([
              member('parms')
                ..access = RO
                ..type = 'List<Parm>'
                ..init = [],
              member('return_type')
                ..access = RO
                ..type = 'RsType'
                ..init = 'UnitType',
              member('return_doc')..doc = 'Document return type',
            ]),
          class_('trait')
            ..extend = 'RsEntity'
            ..implement = ['HasCode']
            ..mixins = [
              'IsPub',
              'Generic',
              'HasAttributes',
              'HasAssociatedTypes',
              'HasCodeBlock'
            ]
            ..members.addAll([
              member('functions')
                ..type = 'List<Fn>'
                ..init = [],
              member('sub_traits')
                ..doc = 'List of subtraits - either as String or modeled Trait'
                ..type = 'List<dynamic>'
                ..init = [],
            ])
        ],

      library('impl')
        ..imports.add('"package:ebisu/ebisu.dart" hide codeBlock')
        ..importAndExportAll([
          'package:ebisu_rs/entity.dart',
          'package:ebisu_rs/trait.dart',
        ])
        ..classes = [
          class_('impl')
            ..extend = 'RsEntity'
            ..mixins = ['HasCode', 'Generic', 'HasTypeAliases', 'HasCodeBlock']
            ..members = [
              member('trait')
                ..type = 'Trait'
                ..access = RO,
              member('type')
                ..type = 'RsType'
                ..access = RO,
              member('functions')
                ..type = 'List<Fn>'
                ..init = [],
            ]
        ],

      library('type')
        ..includesMain = true
        ..imports = ['dart:mirrors', 'package:ebisu/ebisu.dart']
        ..importAndExportAll([
          'package:quiver/iterables.dart',
          'package:ebisu_rs/entity.dart',
          'package:ebisu_rs/generic.dart',
        ])
        ..classes = [
          class_('rs_type')
            ..implement = ['HasCode']
            ..isAbstract = true,
          class_('built_in_type')
            ..extend = 'RsType'
            ..isCopyable = true
            ..members = [member('type_name')..isFinal = true],
          class_('user_defined_type')
            ..extend = 'RsType'
            ..isCopyable = true
            ..members = [
              member('name')..isFinal = true,
            ],
          class_('ref_type')
            ..extend = 'RsType'
            ..isCopyable = true
            ..members = [
              member('referent')
                ..type = 'RsType'
                ..isFinal = true,
              member('lifetime')
                ..type = 'Lifetime'
                ..access = RO,
            ],
          class_('ref')
            ..extend = 'RefType'
            ..members = [],
          class_('mref')
            ..extend = 'RefType'
            ..members = [],
          class_('type_alias')
            ..doc = 'Rust type alias'
            ..extend = 'RsEntity'
            ..mixins = ['IsPub', 'Generic', 'HasCode']
            ..members = [member('aliased')..type = 'RsType'],
          class_('has_type_aliases')
            ..isAbstract = true
            ..members = [
              member('type_aliases')
                ..type = 'List<TypeAlias>'
                ..init = [],
            ],
          class_('associated_type')
            ..doc = 'Rust type alias'
            ..extend = 'RsEntity'
            ..mixins = ['IsPub', 'Generic', 'HasCode'],
          class_('has_associated_types')
            ..isAbstract = true
            ..members = [
              member('associated_types')
                ..access = RO
                ..type = 'List<AssociatedType>'
                ..init = [],
            ]
        ],

      library('field')
        ..imports = commonIncludes()
        ..includesLogger = true
        ..imports.addAll([
          'package:ebisu_rs/attribute.dart',
          'package:ebisu_rs/type.dart',
        ])
        ..classes = [
          class_('field')
            ..extend = 'RsEntity'
            ..implement = ['HasCode']
            ..mixins = ['IsPub', 'HasAttributes']
            ..members = [
              member('type')
                ..doc = 'Type of the field'
                ..type = 'RsType'
                ..init = 'string'
                ..access = RO,
            ],
          class_('tuple_field')
            ..doc = 'A field with type but no name, whose access is indexed'
            ..implement = ['HasCode']
            ..members = [
              member('type')..type = 'RsType',
              member('doc')..type = 'String',
            ],
        ],

      library('macro')
        ..doc = 'Support for macro related code'
        ..imports = [
          'package:id/id.dart',
        ]
        ..enums = [
          enum_('derivable')
            ..libraryScopedValuesCase = capCamelCase
            ..hasJsonSupport = true
            ..values = [
              'eq',
              'partial_eq',
              'ord',
              'partial_ord',
              'clone',
              'copy',
              'hash',
              'default_value',
              'zero',
              'debug',

              // Serde,
              'serialize',
              'deserialize'
            ]
        ]
        ..classes = [
          class_('Derives')
            ..members = [
              member('derive')
                ..type = 'List<Derivable>'
                ..init = []
            ],
        ],

      library('struct')
        ..imports = commonIncludes()
        ..includesLogger = true
        ..importAndExportAll([
          'package:ebisu_rs/macro.dart',
          'package:ebisu_rs/type.dart',
          'package:ebisu_rs/field.dart',
          'package:ebisu_rs/generic.dart',
          'package:quiver/iterables.dart',
        ])
        ..classes = [
          class_('struct')
            ..implement = ['HasCode']
            ..mixins = ['IsPub', 'Derives', 'Generic']
            ..withClass(commonFeatures)
            ..members.addAll([
              member('fields')
                ..type = 'List<Field>'
                ..init = [],
            ]),
          class_('tuple_struct')
            ..doc = 'Tuple struct'
            ..implement = ['HasCode']
            ..mixins = ['IsPub', 'Derives', 'Generic']
            ..withClass(commonFeatures)
            ..members.addAll([]),
          class_('unit_struct')
            ..doc = 'Unit struct'
            ..implement = ['HasCode']
            ..mixins = ['IsPub', 'Derives']
            ..withClass(commonFeatures)
            ..members.addAll([]),
        ]
    ];

  ebisuRs.generate(generateDrudge: true);

  print('''
**** NON GENERATED FILES ****
${indentBlock(brCompact(nonGeneratedFiles))}
''');
}

String _topDir;
bool _enableLogging = false;
