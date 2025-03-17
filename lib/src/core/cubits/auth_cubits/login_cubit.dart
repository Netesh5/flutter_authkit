import 'package:flutter_authkit/flutter_authkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<CommonState> {
  LoginCubit() : super(InitialState());
  // TEMP

  // TO DO
  final FlutterAuthKit _authKit = FlutterAuthKit();
  // TO DO
  login<T>(String loginEndpoint, Map<String, dynamic> params,
      T Function(Map<String, dynamic>) fromJson) async {
    try {
      emit(LoadingState());
      final res = await _authKit.login<T>(
          loginEndpoint: loginEndpoint, params: params, fromJson: fromJson);
      emit(SuccessState<T>(data: res));
    } on Exception catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  // TO DO
}
