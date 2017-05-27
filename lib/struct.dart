library ebisu_rs.struct;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:id/id.dart';

// custom <additional imports>
// end <additional imports>

class Member {
  String id;
  String type;

  // custom <class Member>
  // end <class Member>

}

class Struct extends RsEntity {
  String id;
  List<Member> members = [];

  // custom <class Struct>

  Struct(id) : super(id);

  // end <class Struct>

}

// custom <library struct>

struct(id) => new Struct(id);

// end <library struct>
