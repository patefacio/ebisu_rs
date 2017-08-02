/// Support for macro related code
library ebisu_rs.macro;

import 'package:id/id.dart';

// custom <additional imports>
// end <additional imports>

class Derivable implements Comparable<Derivable> {
  static const Derivable EQ = const Derivable._(0);

  static const Derivable PARTIAL_EQ = const Derivable._(1);

  static const Derivable ORD = const Derivable._(2);

  static const Derivable PARTIAL_ORD = const Derivable._(3);

  static const Derivable CLONE = const Derivable._(4);

  static const Derivable COPY = const Derivable._(5);

  static const Derivable HASH = const Derivable._(6);

  static const Derivable DEFAULT_VALUE = const Derivable._(7);

  static const Derivable ZERO = const Derivable._(8);

  static const Derivable DEBUG = const Derivable._(9);

  static List<Derivable> get values => const <Derivable>[
        EQ,
        PARTIAL_EQ,
        ORD,
        PARTIAL_ORD,
        CLONE,
        COPY,
        HASH,
        DEFAULT_VALUE,
        ZERO,
        DEBUG
      ];

  final int value;

  int get hashCode => value;

  const Derivable._(this.value);

  Derivable copy() => this;

  int compareTo(Derivable other) => value.compareTo(other.value);

  String toString() {
    switch (this) {
      case EQ:
        return "Eq";
      case PARTIAL_EQ:
        return "PartialEq";
      case ORD:
        return "Ord";
      case PARTIAL_ORD:
        return "PartialOrd";
      case CLONE:
        return "Clone";
      case COPY:
        return "Copy";
      case HASH:
        return "Hash";
      case DEFAULT_VALUE:
        return "DefaultValue";
      case ZERO:
        return "Zero";
      case DEBUG:
        return "Debug";
    }
    return null;
  }

  static Derivable fromString(String s) {
    if (s == null) return null;
    switch (s) {
      case "Eq":
        return EQ;
      case "PartialEq":
        return PARTIAL_EQ;
      case "Ord":
        return ORD;
      case "PartialOrd":
        return PARTIAL_ORD;
      case "Clone":
        return CLONE;
      case "Copy":
        return COPY;
      case "Hash":
        return HASH;
      case "DefaultValue":
        return DEFAULT_VALUE;
      case "Zero":
        return ZERO;
      case "Debug":
        return DEBUG;
      default:
        return null;
    }
  }

  String toJson() => toString();

  static Derivable fromJson(dynamic v) {
    return (v is String)
        ? fromString(v)
        : (v is int) ? values[v] : v as Derivable;
  }
}

/// Convenient access to Derivable.EQ with *EQ* see [Derivable].
///
const Derivable Eq = Derivable.EQ;

/// Convenient access to Derivable.PARTIAL_EQ with *PARTIAL_EQ* see [Derivable].
///
const Derivable PartialEq = Derivable.PARTIAL_EQ;

/// Convenient access to Derivable.ORD with *ORD* see [Derivable].
///
const Derivable Ord = Derivable.ORD;

/// Convenient access to Derivable.PARTIAL_ORD with *PARTIAL_ORD* see [Derivable].
///
const Derivable PartialOrd = Derivable.PARTIAL_ORD;

/// Convenient access to Derivable.CLONE with *CLONE* see [Derivable].
///
const Derivable Clone = Derivable.CLONE;

/// Convenient access to Derivable.COPY with *COPY* see [Derivable].
///
const Derivable Copy = Derivable.COPY;

/// Convenient access to Derivable.HASH with *HASH* see [Derivable].
///
const Derivable Hash = Derivable.HASH;

/// Convenient access to Derivable.DEFAULT_VALUE with *DEFAULT_VALUE* see [Derivable].
///
const Derivable DefaultValue = Derivable.DEFAULT_VALUE;

/// Convenient access to Derivable.ZERO with *ZERO* see [Derivable].
///
const Derivable Zero = Derivable.ZERO;

/// Convenient access to Derivable.DEBUG with *DEBUG* see [Derivable].
///
const Derivable Debug = Derivable.DEBUG;

class Derives {
  List<Derivable> derive = [];

  // custom <class Derives>

  String get derives => derive.isEmpty
      ? null
      : '#[derive(${derive.map((d) => idFromString(d.toString()).capCamel).join(", ")})]';

  // end <class Derives>

}

// custom <library macro>
// end <library macro>
