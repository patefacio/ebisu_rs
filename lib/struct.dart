library ebisu_rs.struct;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:id/id.dart';

// custom <additional imports>
// end <additional imports>

class Member extends RsEntity with IsPub implements HasCode {
  /// Type of the member
  String type = 'String';

  // custom <class Member>

  get children => new Iterable.empty();

  toString() => 'member($name:$type)';

  get name => id.snake;

  get code => brCompact([
        tripleSlashComment(doc ?? 'TODO: comment member'),
        '$pubDecl$name: $type,',
      ]);

  // end <class Member>

  Member(id) : super(id);
}

class Struct extends RsEntity with IsPub implements HasCode {
  List<Member> members = [];

  // custom <class Struct>

  get children => new List<Member>.from(members, growable: false);

  toString() => 'struct($name)';

  get name => id.capCamel;

  get code => brCompact([
        tripleSlashComment(doc ?? 'TODO: comment struct'),
        '${pubDecl}struct $name {',
        indentBlock(br(members.map((m) => m.code))),
        '}'
      ]);

  // end <class Struct>

  Struct(id) : super(id);
}

/// Tuple struct
class TupleStruct extends RsEntity with IsPub implements HasCode {
  // custom <class TupleStruct>

  get children => new Iterable.empty();

  get code => brCompact([
        tripleSlashComment(doc),
        'struct $name {',
        '}',
      ]);

  get name => id.capCamel;

  // end <class TupleStruct>

  TupleStruct(id) : super(id);
}

/// Unit struct
class UnitStruct extends RsEntity with IsPub implements HasCode {
  // custom <class UnitStruct>

  get children => new Iterable.empty();

  get code => brCompact([tripleSlashComment(doc), 'struct $name;']);

  get name => id.capCamel;

  // end <class UnitStruct>

  UnitStruct(id) : super(id);
}

// custom <library struct>

struct(id) => new Struct(id);
member(id) => new Member(id);

// end <library struct>
