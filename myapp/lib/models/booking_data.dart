class BookingData {
  final double latitude;
  final double longitude;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final String parkingSpotName;
  final String parkingSpotImage;

  BookingData({
    required this.latitude,
    required this.longitude,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.parkingSpotName,
    required this.parkingSpotImage,
  });

  bool isCurrentBooking() {
    DateTime now = DateTime.now();
    return now.isBefore(endDate);
  }

  int getDuration() {
    return endDate.difference(startDate).inHours;
  }
}
