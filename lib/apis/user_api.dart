import 'dart:collection';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as model;
import 'package:civicalerts/Constants/appwriteconstants.dart';
import 'package:civicalerts/core/providers.dart';
import 'package:civicalerts/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../core/core.dart';

final userApiProvider = Provider((ref) {
  return UserApi(db: ref.watch(appwriteDatabaseProvider,),
    realtime: ref.watch(appwriteRealtimeProvider),);
});

abstract class IUserApi {
  FutureEitherVoid saveUserData(UserModel usermodel);
  Future<model.Document> getUserData(String uid);
  Future<List<model.Document>> searchUserByName(String name);
  Stream<RealtimeMessage> getLatestUserProfileData();
  FutureEitherVoid updateUserData(UserModel userModel);
  FutureEitherVoid followUser(UserModel user);
  FutureEitherVoid addToFollowing(UserModel user);
}

class UserApi implements IUserApi {
  final Databases _db;
  final Realtime _realtime;
  UserApi({required Databases db,    required Realtime realtime,
  }) : _realtime = realtime,_db = db;
  @override
  FutureEitherVoid saveUserData(UserModel usermodel) async {
    // TODO: implement saveUserData
    try {
      await _db.createDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.usersCollection,
          documentId: usermodel.uid,
          data: usermodel.toMap());

      return right(null);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? "Unexpected Error occured", st));
    } catch (e, stacktrace) {
      return left(Failure(e.toString(), stacktrace));
    }
  }

  @override
  Future<model.Document> getUserData(String uid) {
    // TODO: implement getUserData
    return _db.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: uid);
  }

  @override
  Future<List<model.Document>> searchUserByName(String name) async {
    //throw UnimplementedError();

    final documents = await _db.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        queries: [Query.search('name',name),],
    );

    return documents.documents;
  }

  @override
  Stream<RealtimeMessage> getLatestUserProfileData() {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.usersCollection}.documents'
    ]).stream;
  }

  @override
  FutureEitherVoid followUser(UserModel user) async {
    try {
      await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: user.uid,
        data: {
          'followers': user.followers,
        },
      );
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(
        Failure(
          e.message ?? 'Some unexpected error occurred',
          st,
        ),
      );
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEitherVoid updateUserData(UserModel userModel) async{
    try {
      await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: userModel.uid,
        data: userModel.toMap(),
      );
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(
        Failure(
          e.message ?? 'Some unexpected error occurred',
          st,
        ),
      );
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEitherVoid addToFollowing(UserModel user) async {
    try {
      await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: user.uid,
        data: {
          'following': user.following,
        },
      );
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(
        Failure(
          e.message ?? 'Some unexpected error occurred',
          st,
        ),
      );
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }
}
