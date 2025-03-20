import 'package:flutter_authkit/flutter_authkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterCubit extends Cubit<CommonState> {
  RegisterCubit({required this.authKit}) : super(InitialState());
  final FlutterAuthKit authKit;

  register<T>(
      {required String registerEndpoint,
      required Map<String, dynamic> params,
      required T Function(Map<String, dynamic>) fromJson}) async {
    try {
      emit(LoadingState());
      final res = await authKit.register<T>(
          registerEndpoint: registerEndpoint,
          params: params,
          fromJson: fromJson);
      emit(SuccessState<T>(data: res));
    } on Exception catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
