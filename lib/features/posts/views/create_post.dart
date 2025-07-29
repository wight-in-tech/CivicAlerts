import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:civicalerts/features/authentication/controller/auth_controller.dart';
import 'package:civicalerts/features/posts/controller/post_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../Theme/pallete.dart';
import '../../../common/loading_page.dart';
import '../../../core/utils.dart';
import '../../../models/user_model.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const CreatePostScreen());
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final contactController = TextEditingController();

  List<File> images = [];
  GoogleMapController? mapController;
  Position? _currentPosition;
  String? _locationString;
  int _currentImageIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();  // Using the correct type now

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    contactController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  void sharePost(){
    ref.read(PostControllerProvider.notifier).sharePost(images: images, title: titleController.text, description: descriptionController.text, contact: contactController.text, locationDescription: locationController.text, location: _locationString!, context: context);
  }

  Future<void> onPickImages() async {
    final pickedImages = await PickImages();
    if (pickedImages != null) {
      setState(() {
        images = pickedImages;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _locationString = '${position.latitude},${position.longitude}';
        });
      }
    } catch (e) {
      if (mounted) {
        showLocationErrorSnackBar(context);
        setState(() {
          _locationString = 'Location not available';
        });
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _initializeLocation() async {
    bool hasPermission = await requestLocationPermission();
    if (hasPermission) {
      await _getCurrentLocation();
    } else if (mounted) {
      showLocationPermissionSnackBar(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    final isLoading = ref.watch(PostControllerProvider);
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 20, color: Colors.black87),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () {
                sharePost();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: mainBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Post',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
      body: isLoading || currentUser == null
          ? const Loader()
          : SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfo(currentUser),
                const SizedBox(height: 28),
                _buildTitleField(),
                const SizedBox(height: 20),
                _buildDescriptionField(),
                const SizedBox(height: 28),
                if (images.isNotEmpty) ...[
                  _buildImageCarousel(),
                  const SizedBox(height: 28),
                ],
                _buildLocationAndContactInfo(),
                const SizedBox(height: 28),
                _buildImagePicker(),
                const SizedBox(height: 28),
                _buildLocationMap(primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(UserModel currentUser) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                mainBlue,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CircleAvatar(
            backgroundImage: NetworkImage(currentUser.profilePic),
            radius: 22,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentUser.name ?? 'User',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Reporting an issue',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: titleController,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: "Title your report",
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          counter: const SizedBox.shrink(),
        ),
        maxLength: 100,
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: descriptionController,
        maxLines: 5,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: "Share details about the road condition...",
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 16,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildLocationAndContactInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.location_on_outlined, color: mainBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    TextField(
                      controller: locationController,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "Add location details",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.phone_outlined, color: mainBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    TextField(
                      controller: contactController,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "Add contact information",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: onPickImages,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: mainBlue,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add photos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              'Upload images of the road condition',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Column(
      children: [
        Stack(
          children: [
            CarouselSlider(
              carouselController: _carouselController,
              items: images.map((file) {
                return Container(
                  height: 400,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(

                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      height: 400,
                      file,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                height: 240,
                enableInfiniteScroll: false,
                viewportFraction: 1.0,
                enlargeCenterPage: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () {
                  if (images.isNotEmpty && _currentImageIndex < images.length) {
                    setState(() {
                      images.removeAt(_currentImageIndex);
                      if (images.isEmpty) {
                        _currentImageIndex = 0;
                      } else if (_currentImageIndex >= images.length) {
                        _currentImageIndex = images.length - 1;
                      }
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 12),
          AnimatedSmoothIndicator(
            activeIndex: _currentImageIndex,
            count: images.length,
            effect: ExpandingDotsEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: mainBlue,
              dotColor: softBlue,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationMap(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.map_outlined,
              color: mainBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Your Current Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_currentPosition != null)
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                  zoom: 17,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('current_location'),
                    position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                  ),
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                mapToolbarEnabled: false,
                zoomControlsEnabled: true, // Set to true to keep zoom controls
                compassEnabled: false,
              ),
            ),
          )
        else
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Loader(),
            ),
          ),
      ],
    );
  }
}