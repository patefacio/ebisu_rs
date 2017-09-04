library ebisu_rs.test_enumeration;

import 'package:ebisu_rs/enumeration.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
import 'package:ebisu/ebisu.dart';
// end <additional imports>

final Logger _logger = new Logger('test_enumeration');

// custom <library test_enumeration>
// end <library test_enumeration>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  test('c-style enum', () {
    var e = enum_('color', [
      'red',
      uv('green')
        ..doc = 'The color of grass'
        ..value = 22,
      'blue',
    ])
      ..derive = [Clone, Debug]
      ..doc = 'A c-style enum';

    expect(darkMatter(e.code), darkMatter('''
/// A c-style enum
#[derive(Clone, Debug)]
enum Color {
    /// TODO: comment red
    Red,
    /// The color of grass
    Green = 22,
    /// TODO: comment blue
    Blue,
}
    '''));
  });

  test('tuple variants', () {
    var e = enum_('tv_e', [
      tv('tv', [
        'i32',
        tf('[char;5]')..doc = 'Field is a str',
        'f64',
      ])
    ])
      ..doc = 'A tuple variant enum';

    expect(darkMatter(e.code), darkMatter('''
/// A tuple variant enum
enum TvE {
    Tv(
      /// TODO: comment
      i32,
      /// Field is a str
      [char;5],
      /// TODO: comment
      f64,
    ),
}
        '''));
  });

  test('struct variants', () {
    var e = enum_('sv_e', [
      uv('bam')..value = 32,
      sv('sv', [
        'A',
      ])
        ..doc = 'An sv'
    ])
      ..derive = [Clone, Debug]
      ..doc = 'A struct variant enum';

    expect(darkMatter(e.code), darkMatter('''
/// A struct variant enum
#[derive(Clone, Debug)]
enum SvE {
    /// TODO: comment bam
    Bam = 32,
    /// An sv
    Sv{
      /// TODO: comment field
      a: String,
    },
}
        '''));
    expect(e.code.contains('pub enum SvE'), false);
    e.isPub = true;
    expect(e.code.contains('pub enum SvE'), true);

    expect(e.code.contains('use self::SvE::*;'), false);
    e.useSelf = true;
    expect(e.code.contains('use self::SvE::*;'), true);
  });

// end <main>
}
