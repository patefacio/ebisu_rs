library ebisu_rs.test_ebisu_rs;

import 'package:ebisu_rs/ebisu_rs.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:path/path.dart';
import 'package:ebisu/ebisu.dart';

// end <additional imports>

final Logger _logger = new Logger('test_ebisu_rs');

// custom <library test_ebisu_rs>

// end <library test_ebisu_rs>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  Logger.root.level = Level.INFO;
  test('export test', () {
    var r = repo('sample_repo')
      ..crates = [
        ///// Crate 1
        crate('crate_1')
          ..doc = 'This is the first crate'
          ..withCrateToml((crateToml) => crateToml
            ..deps = [
              // sample dep
              dependency('grep', '0.1.6')
            ]
            ..buildDeps = [dependency('log', '0.3')])
          ..withRootModule((rootModule) => rootModule
            ..doc = 'The root module'
            ..structs = [
              struct('rm_s1')
                ..doc = '''
First struct in root module.

# The first struct is most important
## All the rest are secondary
'''
                ..fields = [
                  field('rm_s1_m1')
                    ..doc = 'First field'
                    ..type = 'i32'
                ],
              struct('rm_s2')
                ..doc = 'Second struct in root module'
                ..fields = [
                  field('rm_s2_m1')..doc = 'hmm',
                  field('rm_s2_m2')
                    ..doc = 'bam'
                    ..isPub = true
                ],
            ]
            ..modules = [module('sub_mod_1'), module('sub_mod_2')]),

        //// Crate 2
        crate('crate_2', appCrate)
          ..doc = 'This is the second crate'
          ..loggerType = envLogger
          ..withCrateToml((crateToml) => crateToml
            ..addDep('clap', '^2.4.2')
            ..addDep('serde', '^1.0.8')
            ..deps.addAll([
              // sample dep
              dependency('serde_derive', '^1.0.9'),
              dependency('serde_json', '^1.0.2'),
            ]))
          ..withClap((Clap clap) => clap
            ..args = [
              //
              arg('foo_bar')
                ..short = 'f'
                ..doc = 'Must be fubared'
                ..argType = argString
                ..isRequired = true,
              //
              arg('goo_bardy')..defaultValue = 'goober',
              arg('a_f64')
                ..argType = argF64
                ..defaultValue = '3.14',
              arg('a_str_s')
                ..argType = argString
                ..isMultiple = true,
              arg('a_f64_s')
                ..argType = argF64
                ..isMultiple = true,
            ])
          ..withRootModule((Module rootModule) => rootModule
            ..importWithMacros('serde_derive')
            ..import(['serde', 'serde_json'])
            ..modules = [
              // sub_mod1
              module('sub_mod1', inlineModule)
                ..isPub = true
                ..structs = [struct('sm1_1'), struct('sm1_2')],
              // sub_mod2
              module('sub_mod2', fileModule)
                ..structs = [struct('sm2_1')..isPub = true, struct('sm2_2')],
              // sub_mod3
              module('sub_mod3', directoryModule)
                ..isPub = true
                ..structs = [struct('sm3_1'), struct('sm3_2')]
                ..modules = [
                  module('sub_module_3_dot_1', inlineModule)
                    ..isPub = true
                    ..modules = [
                      module('sub_module_3_dot_1_dot_1', inlineModule)
                        ..modules = [
                          module('nested'),
                        ]
                    ]
                ],
            ]),

        crate('crate_3')
          ..withRootModule((rootModule) => rootModule
            ..modules = [
              module('module_1')..modules = [module('module_1_1')],
              module('module_2')
            ]),
      ];

    r.rootPath = join(r.rootPath, 'sample_repo');
    print(r);
    r.generate();
    print(indentBlock(
        br(r.crates.last.rootModule.progeny.map((e) => e.detailedPath))));
  });

// end <main>
}
