import 'package:system_info/system_info.dart';

final bool _is64 = SysInfo.userSpaceBitness == 64;

class IntHelper {
  static int get intMinFinite => _is64 ? (-2e62).toInt() : (-2e30).toInt();

  static int get intMaxFinite => _is64 ? (2e62).toInt() - 1 : (2e30).toInt() - 1;
}

typedef Predicate<T> = bool Function(T?);