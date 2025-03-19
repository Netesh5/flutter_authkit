import 'package:example/model/user_model.dart';
import 'package:flutter_authkit/flutter_authkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FetchUserInfoCubit extends Cubit<CommonState> {
  FetchUserInfoCubit({required this.authKit}) : super(InitialState());
  final FlutterAuthKit authKit;

  fetchUserInfo() async {
    emit(LoadingState());
    final res = await authKit.request(
      endPoint: "/user/me",
      method: RequestType.GET,
      fromJson: (json) => UserModel.fromMap(json),
    );
    emit(SuccessState<UserModel>(data: res));
  }
}
