import 'package:flutter_authkit/flutter_authkit.dart';
import 'package:flutter_authkit/src/core/di/di.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final g = GetIt.instance;

@InjectableInit()
void injectDependecies() {
  g.init();
  g<FlutterAuthKit>().init(
    baseUrl: "https://dummyjson.com/auth",
  );
}
