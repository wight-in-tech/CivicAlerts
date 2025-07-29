import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:civicalerts/core/core.dart';
import 'package:civicalerts/core/providers.dart';
import 'package:civicalerts/models/post_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../Constants/appwriteconstants.dart';

final PostApiProvider = Provider((ref) {
  return PostApi(
      db: ref.watch(
        appwriteDatabaseProvider,
      ),
      realtime: ref.watch(appwriteRealtimeProvider));
});

abstract class IPostApi {
  FutureEither<Document> sharePost(Post post);
  Future<List<Document>> getPosts();
  Stream<RealtimeMessage> getLatestPost();
  FutureEither<Document> likePost(Post post);
  Future<Document> getPostById(String id);

  Future<List<Document>> getUserPosts(String uid);
}

class PostApi implements IPostApi {
  final Databases _db;
  final Realtime _realtime;
  PostApi({required Databases db, required Realtime realtime})
      : _db = db,
        _realtime = realtime;
  @override
  FutureEither<Document> sharePost(Post post) async {
    try {
      final document = await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.postsCollection,
        documentId: ID.unique(),
        data: post.toMap(),
      );
      return right(document);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? "Unexpected Error occured", st));
    } catch (e, stacktrace) {
      return left(Failure(e.toString(), stacktrace));
    }
  }

  @override
  Future<List<Document>> getPosts() async {
    final documents = await _db.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.postsCollection,
        queries: [
          Query.orderDesc('createdAt')
        ],);
    return documents.documents;
  }

  @override
  Stream<RealtimeMessage> getLatestPost() {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections${AppwriteConstants.postsCollection}.documents'
    ]).stream;
  }

  @override
  FutureEither<Document> likePost(Post post) async {
    try {
      final document = await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.postsCollection,
        documentId: post.id,
        data: {'likes': post.likes},
      );
      return right(document);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? "Unexpected Error occured", st));
    } catch (e, stacktrace) {
      return left(Failure(e.toString(), stacktrace));
    }
  }

  @override
  Future<Document> getPostById(String id) async {
    return _db.getDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.postsCollection,
      documentId: id,
    );
  }

  @override
  Future<List<Document>> getUserPosts(String uid) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.postsCollection,
      queries: [
        Query.equal('uid', uid),
      ],
    );
    return documents.documents;
  }
}
