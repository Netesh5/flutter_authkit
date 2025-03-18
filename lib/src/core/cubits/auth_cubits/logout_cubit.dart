import 'package:flutter_authkit/flutter_authkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class LogoutCubit extends Cubit<CommonState> {
  LogoutCubit({required this.authKit}) : super(InitialState());
  // TEMP

  // TO DO
  final FlutterAuthKit authKit;

  logOut<T>({
    String? loginEndpoint,
  }) async {
    try {
      emit(LoadingState());
      final _ = await authKit.logout();
      emit(SuccessState<void>(data: null));
    } on Exception catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
