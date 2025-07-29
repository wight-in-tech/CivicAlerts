import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Constants/appwriteconstants.dart';

final appwriteClientProvider = Provider((ref) {
  Client client = Client();
  return client
      .setEndpoint(AppwriteConstants.endPoint)
      .setProject(AppwriteConstants.projectId)
      .setSelfSigned(status: true);
});

final appwriteAccountProvider = Provider((ref){
  final client = ref.watch(appwriteClientProvider);
  return Account(client);
});

final appwriteDatabaseProvider = Provider((ref){
  final client = ref.watch(appwriteClientProvider);
  return Databases(client);
});

final appwriteStorageProvider = Provider((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Storage(client);
});

final appwriteRealtimeProvider = Provider((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Realtime(client);
});

final realtimePostsProvider = StreamProvider.autoDispose((ref) {
  final realtime = ref.watch(appwriteRealtimeProvider);
  final subscription = realtime.subscribe([
    'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.postsCollection}.documents'
  ]);

  ref.onDispose(() {
    subscription.close();
  });

  return subscription.stream;
});