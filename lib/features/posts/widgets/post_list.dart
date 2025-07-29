import 'package:civicalerts/Constants/civicalert_appbar.dart';
import 'package:civicalerts/common/error_page.dart';
import 'package:civicalerts/common/loading_page.dart';
import 'package:civicalerts/features/posts/controller/post_controller.dart';
import 'package:civicalerts/features/posts/widgets/post_card.dart';
import 'package:civicalerts/models/post_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';

// Create a state provider to maintain the accumulated posts
final accumulatedPostsProvider = StateNotifierProvider<PostsNotifier, List<Post>>((ref) {
  return PostsNotifier(ref);
});

// Notifier to handle post state
class PostsNotifier extends StateNotifier<List<Post>> {
  final Ref ref;

  PostsNotifier(this.ref) : super([]) {
    initialize();
  }

  Future<void> initialize() async {
    try {
      // Load initial posts
      final posts = await ref.read(GetPostsProvider.future);
      state = posts;

      // Listen for real-time updates
      ref.listen(realtimePostsProvider, (previous, next) {
        next.whenData((update) {
          if (update.events.contains('databases.*.collections.*.documents.*.create')) {
            final newPost = Post.fromMap(update.payload);
            if (!state.any((post) => post.id == newPost.id)) {
              state = [newPost, ...state];
            }
          }

          if (update.events.contains('databases.*.collections.*.documents.*.update')) {
            final updatedPost = Post.fromMap(update.payload);
            state = state.map((post) {
              return post.id == updatedPost.id ? updatedPost : post;
            }).toList();
          }
        });
      });
    } catch (e) {
      // Handle error if needed
      print('Error initializing posts: $e');
    }
  }

  Future<void> refresh() async {
    try {
      final posts = await ref.refresh(GetPostsProvider.future);
      state = posts;
    } catch (e) {
      print('Error refreshing posts: $e');
    }
  }
}

class PostList extends ConsumerWidget {
  const PostList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(accumulatedPostsProvider);
    final postsAsync = ref.watch(GetPostsProvider);

    return Scaffold(
      appBar: AppbarConstants.appbar(),
      body: postsAsync.when(
        data: (data) {
          // Use the accumulated posts from the notifier
          if (posts.isEmpty) {
            return const Center(
              child: Text(
                'No posts found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(accumulatedPostsProvider.notifier).refresh();
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: posts.length,
              itemBuilder: (BuildContext context, int index) {
                final post = posts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: PostCard(
                    post: post,
                  ),
                );
              },
            ),
          );
        },
        error: (error, stackTrace) => ErrorText(
          error: error.toString(),
        ),
        loading: () => const Center(child: Loader()),
      ),
    );
  }
}