import 'package:flutter_authkit/flutter_authkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class SocialLoginCubit extends Cubit<CommonState> {
  SocialLoginCubit({required this.flutterAuthKit}) : super(InitialState());

  final FlutterAuthKit flutterAuthKit;

  Future<void> socialLogin<T>({
    required SocialAuthTypes type,
    required String endpoint,
    Map<String, dynamic>? params,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      emit(LoadingState());

      final res = await _handleSocialLogin<T>(
        type: type,
        endpoint: endpoint,
        params: params,
        fromJson: fromJson,
      );

      emit(SuccessState<T>(data: res));
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  Future<T> _handleSocialLogin<T>({
    required SocialAuthTypes type,
    required String endpoint,
    Map<String, dynamic>? params,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    switch (type) {
      case SocialAuthTypes.google:
        return flutterAuthKit.loginWithGoogle<T>(
          googleEndpoint: endpoint,
          params: params,
          fromJson: fromJson,
        );
      case SocialAuthTypes.facebook:
        return flutterAuthKit.loginWithFacebook<T>(
          facebookEndpoint: endpoint,
          params: params,
          fromJson: fromJson,
        );
      case SocialAuthTypes.apple:
        return flutterAuthKit.loginWithApple<T>(
          appleEndpoint: endpoint,
          params: params,
          fromJson: fromJson,
        );
      default:
        throw UnsupportedError('Unsupported social auth type: $type');
    }
  }
}
