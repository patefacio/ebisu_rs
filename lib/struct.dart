library ebisu_rs.struct;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:id/id.dart';

// custom <additional imports>
// end <additional imports>

class Member extends RsEntity {
  /// Type of the member
  String type;

  // custom <class Member>

  toString() => '$id $type';

  // end <class Member>

  Member(id) : super(id);
}

class Struct extends RsEntity {
  List<Member> members = [];

  // custom <class Struct>

  toString() => brCompact([id, members]);

  // end <class Struct>

  Struct(id) : super(id);
}

// custom <library struct>

struct(id) => new Struct(id);
member(id) => new Member(id);

// end <library struct>
