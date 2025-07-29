import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';

class CarouselImage extends StatefulWidget {
  final List<String> imageLinks;
  final double height;
  final double indicatorSize;
  final Color activeIndicatorColor;
  final Color inactiveIndicatorColor;
  final double borderRadius;
  final BoxFit imageFit;
  final double viewportFraction;

  const CarouselImage({
    super.key,
    required this.imageLinks,
    this.height = 300,
    this.indicatorSize = 6,
    this.activeIndicatorColor = Colors.white,
    this.inactiveIndicatorColor = Colors.grey,
    this.borderRadius = 0, // Reddit uses square corners
    this.imageFit = BoxFit.contain, // Reddit uses contain to show full image
    this.viewportFraction = 1.0, // Full width
  });

  @override
  State<CarouselImage> createState() => _CarouselImageState();
}

class _CarouselImageState extends State<CarouselImage> {
  int _current = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Main image with black background (like Reddit)
        CarouselSlider(
          carouselController: _carouselController,
          items: widget.imageLinks.map((link) {
            return Container(
              color: Colors.black,
              child: Center(
                child: Image.network(
                  link,
                  fit: widget.imageFit,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(widget.activeIndicatorColor),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[900],
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 50,
                      ),
                    );
                  },
                ),
              ),
            );
          }).toList(),
          options: CarouselOptions(
            height: widget.height,
            viewportFraction: widget.viewportFraction,
            enlargeCenterPage: false, // Reddit doesn't enlarge center
            enableInfiniteScroll: false, // Reddit doesn't infinite scroll
            autoPlay: false, // No auto-play in Reddit
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
        ),

        // Position indicator (matches Reddit's style)
        if (widget.imageLinks.length > 1)
          Positioned(
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.imageLinks.asMap().entries.map((entry) {
                  return Container(
                    width: widget.indicatorSize,
                    height: widget.indicatorSize,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current == entry.key
                          ? widget.activeIndicatorColor
                          : widget.inactiveIndicatorColor,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}