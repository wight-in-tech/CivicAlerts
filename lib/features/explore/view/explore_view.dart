// import 'package:civicalerts/Theme/pallete.dart';
// import 'package:civicalerts/common/error_page.dart';
// import 'package:civicalerts/features/explore/controller/explore_controller.dart';
// import 'package:civicalerts/features/explore/widgets/search_tile.dart';
// import 'package:flutter/material.dart';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../../../common/loading_page.dart';
//
//
// class ExploreView extends ConsumerStatefulWidget {
//   const ExploreView({super.key});
//
//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _ExploreViewState();
// }
//
// class _ExploreViewState extends ConsumerState<ExploreView> {
//   final searchController = TextEditingController();
//   bool isShowUsers = false;
//
//   @override
//   void dispose() {
//     super.dispose();
//     searchController.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final appBarTextFieldBorder = OutlineInputBorder(
//       borderRadius: BorderRadius.circular(50),
//       borderSide: const BorderSide(
//         color: mainBlue,
//       ),
//     );
//     return Scaffold(
//       appBar: AppBar(
//         title: SizedBox(
//           height: 50,
//           child: TextField(
//             controller: searchController,
//             onSubmitted: (value) {
//               setState(() {
//                 isShowUsers = true;
//               });
//             },
//             decoration: InputDecoration(
//               contentPadding: const EdgeInsets.all(10).copyWith(
//                 left: 20,
//               ),
//               fillColor: Colors.white,
//               filled: true,
//               enabledBorder: appBarTextFieldBorder,
//               focusedBorder: appBarTextFieldBorder,
//               hintText: 'Search Civic',
//
//             ),
//           ),
//         ),
//       ),
//       body: isShowUsers
//           ? ref.watch(searchUserProvider(searchController.text)).when(
//         data: (users) {
//           return ListView.builder(
//             itemCount: users.length,
//             itemBuilder: (BuildContext context, int index) {
//               final user = users[index];
//               return SearchTile(userModel: user);
//             },
//           );
//         },
//         error: (error, st) => ErrorText(
//           error: error.toString(),
//         ),
//         loading: () => const Loader(),
//       )
//           : const SizedBox(),
//     );
//   }
// }


import 'package:civicalerts/Theme/pallete.dart';
import 'package:civicalerts/common/error_page.dart';
import 'package:civicalerts/features/explore/controller/explore_controller.dart';
import 'package:civicalerts/features/explore/widgets/search_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/loading_page.dart';

class ExploreView extends ConsumerStatefulWidget {
  const ExploreView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExploreViewState();
}

class _ExploreViewState extends ConsumerState<ExploreView>
    with TickerProviderStateMixin {
  final searchController = TextEditingController();
  final focusNode = FocusNode();
  bool isShowUsers = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      setState(() {
        isShowUsers = true;
      });
      _animationController.forward();
      focusNode.unfocus();
    }
  }

  void _clearSearch() {
    searchController.clear();
    setState(() {
      isShowUsers = false;
    });
    _animationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar with search
          SliverAppBar(
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: mainBlue,
            toolbarHeight: 80, // Compact but sufficient height
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    mainBlue.withOpacity(0.05),
                    Colors.white,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildSearchField(),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        focusNode: focusNode,
        onSubmitted: _onSearchSubmitted,
        onChanged: (value) {
          if (value.isEmpty && isShowUsers) {
            _clearSearch();
          }
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          fillColor: Colors.white,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: mainBlue,
              width: 2,
            ),
          ),
          hintText: 'Search for civic users...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey[500],
            size: 24,
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(
              Icons.clear_rounded,
              color: Colors.grey[500],
            ),
            onPressed: _clearSearch,
          )
              : null,
        ),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (!isShowUsers) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ref.watch(searchUserProvider(searchController.text)).when(
        data: (users) {
          if (users.isEmpty) {
            return _buildNoResultsState();
          }
          return _buildUsersList(users);
        },
        error: (error, st) => _buildErrorState(error.toString()),
        loading: () => _buildLoadingState(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'Discover Civic Users',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Search for users by name or username to connect with your community',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search_rounded,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with a different keyword',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(List users) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = users[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 100 + (index * 50)),
          curve: Curves.easeOutBack,
          child: EnhancedSearchTile(
            userModel: user,
            index: index,
          ),
        );
      },
    );
  }
}