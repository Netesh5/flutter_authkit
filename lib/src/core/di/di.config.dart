// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_authkit/flutter_authkit.dart' as _i701;
import 'package:flutter_authkit/src/core/cubits/email_auth_cubits/login_cubit.dart'
    as _i444;
import 'package:flutter_authkit/src/core/cubits/email_auth_cubits/logout_cubit.dart'
    as _i531;
import 'package:flutter_authkit/src/core/cubits/social_auth_cubits/social_login_cubit.dart'
    as _i27;
import 'package:flutter_authkit/src/core/services/dio.dart' as _i8;
import 'package:flutter_authkit/src/core/services/token_service.dart' as _i691;
import 'package:flutter_authkit/src/flutter_authkit_impl.dart' as _i1024;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i691.TokenService>(() => _i691.TokenService());
    gh.lazySingleton<_i8.DioClient>(() => _i8.DioClient(
          gh<String>(instanceName: 'baseUrl'),
          gh<Map<String, dynamic>>(instanceName: 'headers'),
          gh<_i691.TokenService>(),
          gh<String>(instanceName: 'refreshEndpoint'),
        ));
    gh.lazySingleton<_i1024.FlutterAuthKit>(
        () => _i1024.FlutterAuthKit(tokenService: gh<_i701.TokenService>()));
    gh.factory<_i444.LoginCubit>(
        () => _i444.LoginCubit(authKit: gh<_i701.FlutterAuthKit>()));
    gh.factory<_i531.LogoutCubit>(
        () => _i531.LogoutCubit(authKit: gh<_i701.FlutterAuthKit>()));
    gh.factory<_i27.SocialLoginCubit>(() =>
        _i27.SocialLoginCubit(flutterAuthKit: gh<_i701.FlutterAuthKit>()));
    return this;
  }
}
