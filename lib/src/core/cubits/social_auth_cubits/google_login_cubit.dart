import 'package:flutter_authkit/flutter_authkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GoogleLoginCubit extends Cubit<CommonState> {
  GoogleLoginCubit() : super(InitialState());

  googleLogin() {
    emit(LoadingState());
    try {} catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
