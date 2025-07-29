import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as model;
import 'package:civicalerts/core/core.dart';
import 'package:civicalerts/core/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

// Provider for AuthApi
final authApiProvider = Provider((ref) {
  final account = ref.watch(appwriteAccountProvider);
  return AuthApi(account: account);
});

// Interface for AuthApi
abstract class IAuthApi {
  FutureEither<model.User> signUp({required String email, required String password});
  FutureEither<model.Session> login({required String email, required String password});
  Future<model.User?>CurrentUserAccount();
  FutureEitherVoid logout();
}

// Implementation of AuthApi
class AuthApi implements IAuthApi {
  final Account _account;
  AuthApi({required Account account}) : _account = account;

  @override
  Future<model.User?> CurrentUserAccount() async {
    // TODO: implement CurrentUserAccount
    try{
      return await _account.get();
    }
        catch(e){
      return null;

        }
  }

  @override
  FutureEither<model.User> signUp({required String email, required String password}) async {
    try {
      // Create a new account using Appwrite
      final account = await _account.create(userId: ID.unique(), email: email, password: password);
      return right(account); // Return success
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace)); // Return failure
    }
  }
 @override
  FutureEither<model.Session>login({required String email, required String password}) async {
    try {
      // Create a new account using Appwrite
      final session = await _account.createEmailPasswordSession(email: email, password: password);
      return right(session); // Return success
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace)); // Return failure
    }

  }

  @override
  FutureEitherVoid logout() async {

    try {
      await _account.deleteSession(
        sessionId: 'current',
      );
      return right(null);
    } on AppwriteException catch (e, stackTrace) {
      return left(
        Failure(e.message ?? 'Some unexpected error occurred', stackTrace),
      );
    } catch (e, stackTrace) {
      return left(
        Failure(e.toString(), stackTrace),
      );
    }
  }




  }