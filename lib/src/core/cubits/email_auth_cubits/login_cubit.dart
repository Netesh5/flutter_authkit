import 'package:flutter_authkit/flutter_authkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginCubit extends Cubit<CommonState> {
  LoginCubit({required this.authKit}) : super(InitialState());
  final FlutterAuthKit authKit;
  login<T>(
      {required String loginEndpoint,
      required Map<String, dynamic> params,
      required T Function(Map<String, dynamic>) fromJson}) async {
    try {
      emit(LoadingState());
      final res = await authKit.login<T>(
          loginEndpoint: loginEndpoint, params: params, fromJson: fromJson);
      emit(SuccessState<T>(data: res));
    } on Exception catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
