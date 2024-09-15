import '../model/booking_service.dart';
import '../util/booking_util.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class BookingController extends ChangeNotifier {
  BookingService bookingService;
  BookingController({required this.bookingService, this.pauseSlots}) {
    serviceOpening = bookingService.bookingStart;
    serviceClosing = bookingService.bookingEnd;
    pauseSlots = pauseSlots;
    if (serviceOpening!.isAfter(serviceClosing!)) {
      throw "Service closing must be after opening";
    }
    base = serviceOpening!;
    _generateBookingSlots();
  }

  late DateTime base;

  DateTime? serviceOpening;
  DateTime? serviceClosing;

  List<DateTime> _allBookingSlots = [];
  List<DateTime> get allBookingSlots => _allBookingSlots;

  List<DateTimeRange> bookedSlots = [];
  List<DateTimeRange>? pauseSlots = [];

  int _selectedSlot = (-1);
  List<int> selectedSlots = [];
  bool _isUploading = false;

  int get selectedSlot => _selectedSlot;
  bool get isUploading => _isUploading;

  bool _successfullUploaded = false;
  bool get isSuccessfullUploaded => _successfullUploaded;

  void initBack() {
    _isUploading = false;
    _successfullUploaded = false;
  }

  void selectFirstDayByHoliday(DateTime first, DateTime firstEnd) {
    serviceOpening = first;
    serviceClosing = firstEnd;
    base = first;
    _generateBookingSlots();
  }

  void _generateBookingSlots() {
    allBookingSlots.clear();
    _allBookingSlots = List.generate(
        _maxServiceFitInADay(),
            (index) => base
            .add(Duration(minutes: bookingService.serviceDuration) * index));
  }

  bool isWholeDayBooked() {
    bool isBooked = true;
    for (var i = 0; i < allBookingSlots.length; i++) {
      if (!isSlotBooked(i)) {
        isBooked = false;
        break;
      }
    }
    return isBooked;
  }

  int _maxServiceFitInADay() {
    ///if no serviceOpening and closing was provided we will calculate with 00:00-24:00
    int openingHours = 24;
    if (serviceOpening != null && serviceClosing != null) {
      openingHours = DateTimeRange(start: serviceOpening!, end: serviceClosing!)
          .duration
          .inHours+1;
    }

    ///round down if not the whole service would fit in the last hours
    return ((openingHours * 60) / bookingService.serviceDuration).floor();
  }

  bool isSlotBooked(int index) {
    DateTime checkSlot = allBookingSlots.elementAt(index);
    bool result = false;
    for (var slot in bookedSlots) {
      if (BookingUtil.isOverLapping(slot.start, slot.end, checkSlot,
          checkSlot.add(Duration(minutes: bookingService.serviceDuration)))) {
        result = true;
        break;
      }
    }
    return result;
  }

  bool isSlotPause(int index) {
    DateTime checkSlot = allBookingSlots.elementAt(index);
    bool result = false;
    for (var slot in pauseSlots!) {
      if (BookingUtil.isOverLapping(slot.start, slot.end, checkSlot,
          checkSlot.add(Duration(minutes: bookingService.serviceDuration)))) {
        result = true;
        break;
      }
    }
    return result;
  }

  bool isValidBookingDuration(int start, int end){
    for (var i = start; i < end; i++) {
      if(isSlotBooked(i) || isSlotPause(i)){
        return false;
      }
    }
    return true;
  }

  void addBookingDuration(int start, int end){
    for (var i = start+1; i < end+1; i++) {
      selectedSlots.add(i);
    }
  }

  void removeBookingDuration(int start, int end){
    for (var i = start+1; i < end+1; i++) {
      selectedSlots.remove(i);
    }
  }

  void selectSlot(int idx) {

    if(!selectedSlots.contains(idx)){
      int start = 0;
      int end = 0;
      if(selectedSlots.isNotEmpty){
        start = (selectedSlots.reduce(min)<idx)?selectedSlots.reduce(min):idx;
        end = (selectedSlots.reduce(max)>idx)?selectedSlots.reduce(max):idx;
        if(isValidBookingDuration(start, end)){
        addBookingDuration(start, end);
        }
      }
      else{
        selectedSlots.add(idx);
      }
    }
    else {
      if(selectedSlots.length == 1) {
        selectedSlots = [];
      }
      else {
        removeBookingDuration(idx, selectedSlots.reduce(max));
      }
    }
    notifyListeners();
  }

  void resetSelectedSlot() {
    _selectedSlot = -1;
    selectedSlots = [];
    notifyListeners();
  }

  void toggleUploading() {
    _isUploading = !_isUploading;
    notifyListeners();
  }

  Future<void> generateBookedSlots(List<DateTimeRange> data) async {
    bookedSlots.clear();
    _generateBookingSlots();

    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      bookedSlots.add(item);
    }
  }

  BookingService generateNewBookingForUploading() {
    final bookingDate = allBookingSlots.elementAt(selectedSlots.reduce(max));
    bookingService
      ..bookingStart = allBookingSlots.elementAt(selectedSlots.reduce(min))
      ..bookingEnd =
      (bookingDate.add(Duration(minutes: bookingService.serviceDuration)));
    return bookingService;
  }

  bool isSlotInPauseTime(DateTime slot) {
    bool result = false;
    if (pauseSlots == null) {
      return result;
    }
    for (var pauseSlot in pauseSlots!) {
      if (BookingUtil.isOverLapping(pauseSlot.start, pauseSlot.end, slot,
          slot.add(Duration(minutes: bookingService.serviceDuration)))) {
        result = true;
        break;
      }
    }
    return result;
  }
}