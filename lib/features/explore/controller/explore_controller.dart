import 'package:civicalerts/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../apis/user_api.dart';

final exploreControllerProvider = StateNotifierProvider((ref) {
  return ExploreController(
    userAPI: ref.watch(userApiProvider),
  );
});

final searchUserProvider = FutureProvider.family((ref, String name) async {
  final exploreController = ref.watch(exploreControllerProvider.notifier);
  return exploreController.searchUser(name);
});

class ExploreController extends StateNotifier<bool> {
  final UserApi _userAPI;
  ExploreController({
    required UserApi userAPI,
  })  : _userAPI = userAPI,
        super(false);

  Future<List<UserModel>> searchUser(String name) async {
    final users = await _userAPI.searchUserByName(name);
    return users.map((e) => UserModel.fromMap(e.data)).toList();
  }
}