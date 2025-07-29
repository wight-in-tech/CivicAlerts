import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:civicalerts/Constants/appwriteconstants.dart';
import 'package:civicalerts/core/failure.dart';
import 'package:civicalerts/core/providers.dart';
import 'package:civicalerts/core/type_defs.dart';
import 'package:civicalerts/models/comment_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final commentAPIProvider = Provider((ref) {
  return CommentAPI(
    db: ref.watch(appwriteDatabaseProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
  );
});

abstract class ICommentAPI {
  FutureEither<Document> uploadComments(CommentModel comment);
  Future<List<Document>> getComments();
  Stream<RealtimeMessage> getLatestComments();
}

class CommentAPI extends ICommentAPI {
  final Databases _db;
  final Realtime _realtime;
  CommentAPI({required Databases db, required Realtime realtime})
      : _db = db,
        _realtime = realtime;

  @override
  FutureEither<Document> uploadComments(CommentModel comment) async {
    try {
      final document = await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.commentsCollections,
        documentId: ID.unique(),
        data: comment.toMap(),
      );
      return right(document);
    } on AppwriteException catch (e, stackTrace) {
      return left(Failure(
        e.toString(),
        stackTrace,
      ));
    } catch (e, stackTrace) {
      return left(
        Failure(
          e.toString(),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<List<Document>> getComments() async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.commentsCollections,
      queries: [
        Query.orderDesc('commentedAt'),
      ],
    );
    return documents.documents;
  }

  Future<int> getReplyCount(String repliedTo) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.commentsCollections,
      queries: [
        Query.equal('repliedTo', repliedTo),
      ],
    );
    return documents.total; // 'total' gives the count of documents
  }

  @override
  Stream<RealtimeMessage> getLatestComments() {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.commentsCollections}.documents'
    ]).stream;
  }
}