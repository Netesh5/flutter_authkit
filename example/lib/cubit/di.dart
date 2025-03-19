import 'package:example/cubit/fetch_user_info_cubit.dart';
import 'package:flutter_authkit/flutter_authkit.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

class DI {
  static init() {
    getIt.registerFactory(() => FetchUserInfoCubit(authKit: g()));
  }
}
