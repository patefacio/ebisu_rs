library ebisu_rs.struct;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/type.dart';
import 'package:id/id.dart';
import 'package:quiver/iterables.dart';

// custom <additional imports>
// end <additional imports>

class Member extends RsEntity with IsPub implements HasCode {
  /// Type of the member
  RsType get type => _type;

  // custom <class Member>

  get children => new Iterable.empty();

  onOwnershipEstablished() {
    print("^^^^^^^^Ownership of ${id}:${runtimeType}");
  }

  set type(type) =>
      _type = type is String ? _type = new UserDefinedType(type) : type;

  toString() => 'member($name:$type)';

  get name => id.snake;

  get code => brCompact([
        tripleSlashComment(doc ?? 'TODO: comment member'),
        '$pubDecl$name: ${type.scopedDecl},',
      ]);

  get lifetimes => type.lifetimes;

  // end <class Member>

  Member(id) : super(id);

  RsType _type = str;
}

class Struct extends RsEntity with IsPub implements HasCode {
  List<Member> members = [];

  // custom <class Struct>

  get children => new List<Member>.from(members, growable: false);

  toString() => 'struct($name)';

  get name => id.capCamel;

  @override
  onOwnershipEstablished() {
    print("---------Ownership of ${id}:${runtimeType}");
    for (final member in members) {
      if (member.type.isRef) {}
    }
  }

  get lifetimes =>
    new Set.from(concat(members.map((m) => m.lifetimes.map((lt) => "'$lt"))))
    .toList()
    ..sort();

  get template {
    var contents = chomp(brCompact([
      lifetimes.join(', '),
    ]));
    return contents.isNotEmpty ? '< $contents >' : '';
  }

  get code => brCompact([
        tripleSlashComment(doc ?? 'TODO: comment struct'),
        '${pubDecl}struct${template} $name {',
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
