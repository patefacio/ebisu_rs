library ebisu_rs.test_ebisu_rs;

import 'package:ebisu_rs/ebisu_rs.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:path/path.dart';

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
          ..withRootModule((rootModule) => rootModule
            ..doc = 'The root module'
            ..structs = [
              struct('rm_s1')
                ..doc = '''
First struct in root module.

# The first struct is most important
## All the rest are secondary
'''
                ..members = [
                  member('rm_s1_m1')
                    ..doc = 'First member'
                    ..type = 'i32'
                ],
              struct('rm_s2')
                ..doc = 'Second struct in root module'
                ..members = [
                  member('rm_s2_m1'),
                  member('rm_s2_m2')..isPub = true
                ],
            ]
            ..modules = [module('sub_mod_1'), module('sub_mod_2')]),

        //// Crate 2
        crate('crate_2', appCrate)
          ..doc = 'This is the second crate'
          ..withRootModule((rootModule) => rootModule
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
                    ]
                ],
            ]),
      ];

    r.rootPath = join(r.rootPath, 'sample_repo');
    print(r);
    r.generate();
  });

// end <main>
}
