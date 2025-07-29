import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:civicalerts/core/core.dart';
import 'package:civicalerts/core/providers.dart';
import 'package:civicalerts/models/complain_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../Constants/appwriteconstants.dart';

final ComplainApiProvider = Provider((ref) {
  return ComplainApi(
    db: ref.watch(appwriteDatabaseProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
  );
});

abstract class IComplainApi {
  FutureEither<Document> shareComplain(Complain complain);
  Future<List<Document>> getComplains();
  Future<Document> getComplainsById(String id);
}

class ComplainApi implements IComplainApi {
  final Databases _db;
  final Realtime _realtime;

  ComplainApi({required Databases db, required Realtime realtime})
      : _db = db,
        _realtime = realtime;

  @override
  FutureEither<Document> shareComplain(Complain complain) async {
    try {
      final document = await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.complainsCollection,
        documentId: ID.unique(),
        data: complain.toMap(),
      );
      return right(document);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? "Unexpected error occurred", st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Future<List<Document>> getComplains() async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.complainsCollection,
      queries: [Query.orderDesc('createdAt')],
    );
    return documents.documents;
  }

  @override
  Future<Document> getComplainsById(String id) async {
    return _db.getDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.complainsCollection,
      documentId: id,
    );
  }
}
