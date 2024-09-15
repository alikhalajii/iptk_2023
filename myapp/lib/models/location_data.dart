import 'package:flutter/material.dart';

class CustomLocationData {
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final double price;
  String reviewScore;
  final List<dynamic> reviewList;
  final bool covered;
  final bool chargingStation;
  final bool handicappedAccess;
  final bool videoSurveillance;
  final String image;
  final List<List<bool>> availability;
  final String id;
  final String city;
  bool filtered = false;

  CustomLocationData(
      {required this.name,
      required this.city,
      required this.description,
      required this.latitude,
      required this.longitude,
      required this.price,
      required this.reviewScore,
      required this.reviewList,
      required this.covered,
      required this.chargingStation,
      required this.handicappedAccess,
      required this.videoSurveillance,
      required this.image,
      required this.availability,
      required this.id});
}

class CustomMarker extends StatelessWidget {
  final String price;

  const CustomMarker(this.price, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Speech bubble shape
        ClipPath(
          clipper: _BubbleClipper(),
          child: Container(
            width: 100, // Adjust according to your requirements
            height: 60, // Adjust according to your requirements
            color: Colors.white,
          ),
        ),
        // Price text
        Positioned.fill(
          child: Center(
            child: Text(
              price,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom clipper for the speech bubble shape
class _BubbleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width * 0.8, size.height);
    path.lineTo(size.width, size.height * 0.5);
    path.lineTo(size.width * 0.8, 0);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

List<List<bool>> availability1 = [
  [
    true,
    true,
    true,
    true,
    false,
    false,
    false,
    true,
    true,
    false,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true
  ],
  [
    true,
    true,
    true,
    true,
    false,
    false,
    false,
    true,
    true,
    false,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true
  ],
  [
    false,
    true,
    true,
    false,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true
  ],
];

String calculateReviewScore(List<dynamic> reviewList) {
  if (reviewList.isEmpty) {
    return "";
  }

  double score = 0;
  for (int i = 0; i < reviewList.length; i++) {
    score += reviewList[i]['score'];
  }
  return (score / reviewList.length).toStringAsFixed(1);
}
