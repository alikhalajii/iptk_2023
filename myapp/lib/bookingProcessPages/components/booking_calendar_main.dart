import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart' as tc
    show StartingDayOfWeek;
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/globals.dart';
import '../core/booking_controller.dart';
import '../model/booking_service.dart';
import '../model/enums.dart' as bc;
import '../payingPage.dart';
import '../util/booking_util.dart';
import 'booking_dialog.dart';
import 'booking_explanation.dart';
import 'booking_slot.dart';
import 'common_button.dart';
import 'common_card.dart';

class BookingCalendarMain extends StatefulWidget {
  const BookingCalendarMain({
    Key? key,
    required this.getBookingStream,
    required this.convertStreamResultToDateTimeRanges,
    required this.uploadBooking,
    this.bookingExplanation,
    this.bookingGridCrossAxisCount,
    this.bookingGridChildAspectRatio,
    this.formatDateTime,
    this.bookingButtonText,
    this.bookingButtonColor,
    this.bookedSlotColor,
    this.selectedSlotColor,
    this.availableSlotColor,
    this.bookedSlotText,
    this.bookedSlotTextStyle,
    this.selectedSlotText,
    this.selectedSlotTextStyle,
    this.availableSlotText,
    this.availableSlotTextStyle,
    this.gridScrollPhysics,
    this.loadingWidget,
    this.errorWidget,
    this.uploadingWidget,
    this.wholeDayIsBookedWidget,
    this.pauseSlotColor,
    this.pauseSlotText,
    this.hideBreakTime = false,
    this.locale,
    this.startingDayOfWeek,
    this.disabledDays,
    this.disabledDates,
    this.lastDay,
  }) : super(key: key);

  final Stream<dynamic>? Function(
      {required DateTime start, required DateTime end}) getBookingStream;
  final Future<dynamic> Function({required BookingService newBooking})
      uploadBooking;
  final Future<List<DateTimeRange>> Function({required dynamic streamResult})
      convertStreamResultToDateTimeRanges;

  ///Customizable
  final Widget? bookingExplanation;
  final int? bookingGridCrossAxisCount;
  final double? bookingGridChildAspectRatio;
  final String Function(DateTime dt)? formatDateTime;
  final String? bookingButtonText;
  final Color? bookingButtonColor;
  final Color? bookedSlotColor;
  final Color? selectedSlotColor;
  final Color? availableSlotColor;
  final Color? pauseSlotColor;

//Added optional TextStyle to available, booked and selected cards.
  final String? bookedSlotText;
  final String? selectedSlotText;
  final String? availableSlotText;
  final String? pauseSlotText;

  final TextStyle? bookedSlotTextStyle;
  final TextStyle? availableSlotTextStyle;
  final TextStyle? selectedSlotTextStyle;

  final ScrollPhysics? gridScrollPhysics;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? uploadingWidget;

  final bool? hideBreakTime;
  final DateTime? lastDay;
  final String? locale;
  final bc.StartingDayOfWeek? startingDayOfWeek;
  final List<int>? disabledDays;
  final List<DateTime>? disabledDates;

  final Widget? wholeDayIsBookedWidget;

  @override
  State<BookingCalendarMain> createState() => _BookingCalendarMainState();
}

class _BookingCalendarMainState extends State<BookingCalendarMain> {
  late final _BookingCalendarMainState bookingCalendarMainState;

  late BookingController controller;
  final now = DateTime.now();
  List<DateTimeRange> dateTimeList = [];
  bool isLoaded = false;

  @override
  void initState() {
    loadDateTimeList();
    super.initState();
    controller = context.read<BookingController>();
    final firstDay = calculateFirstDay();

    startOfDay = firstDay.startOfDayService(controller.serviceOpening!);
    endOfDay = firstDay.endOfDayService(controller.serviceClosing!);
    _focusedDay = firstDay;
    _selectedDay = firstDay;
    controller.selectFirstDayByHoliday(startOfDay, endOfDay);
  }

  loadDateTimeList() async {
    List<DateTimeRange> dateTimes = await FirebaseFirestore.instance
        .collection('parkingSpots')
        .doc(Globals.selectedLocation.id)
        .collection('bookingList')
        .get()
        .then((querySnapshot) {
      return querySnapshot.docs.map((documentSnapshot) {
        final start = documentSnapshot['start'].toDate();
        final end = documentSnapshot['end'].toDate();
        return DateTimeRange(start: start, end: end);
      }).toList();
    });
    setState(() {
      dateTimeList.clear();
      dateTimeList.add(
          DateTimeRange(start: DateTime.now().startOfDay, end: DateTime.now()));
      dateTimeList.addAll(dateTimes);
      isLoaded = true;
    });
  }

  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;

  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late DateTime startOfDay;
  late DateTime endOfDay;

  void selectNewDateRange() {
    startOfDay = _selectedDay.startOfDayService(controller.serviceOpening!);
    endOfDay = _selectedDay
        .add(const Duration(days: 1))
        .endOfDayService(controller.serviceClosing!);

    controller.base = startOfDay;
    controller.resetSelectedSlot();
  }

  DateTime calculateFirstDay() {
    final now = DateTime.now();
    if (widget.disabledDays != null) {
      return widget.disabledDays!.contains(now.weekday)
          ? now.add(Duration(days: getFirstMissingDay(now.weekday)))
          : now;
    } else {
      return DateTime.now();
    }
  }

  int getFirstMissingDay(int now) {
    for (var i = 1; i <= 7; i++) {
      if (!widget.disabledDays!.contains(now + i)) {
        return i;
      }
    }
    return -1;
  }

  void paymentSuccessful() async {
    Navigator.of(context).pop();
    controller.toggleUploading();
    await widget.uploadBooking(newBooking: controller.generateNewBookingForUploading());
    controller.toggleUploading();
    controller.resetSelectedSlot();
    loadDateTimeList();
  }

  @override
  Widget build(BuildContext context) {
    controller = context.watch<BookingController>();

    return isLoaded
        ? Consumer<BookingController>(
      builder: (_, controller, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: (controller.isUploading)
            ? widget.uploadingWidget ?? const BookingDialog()
            : Column(
          children: [
            CommonCard(
              child: TableCalendar(
                startingDayOfWeek:
                widget.startingDayOfWeek?.toTC() ??
                    tc.StartingDayOfWeek.monday,
                holidayPredicate: (day) {
                  if (widget.disabledDates == null) return false;

                  bool isHoliday = false;
                  for (var holiday in widget.disabledDates!) {
                    if (isSameDay(day, holiday)) {
                      isHoliday = true;
                    }
                  }
                  return isHoliday;
                },
                enabledDayPredicate: (day) {
                  if (widget.disabledDays == null &&
                      widget.disabledDates == null) return true;

                  bool isEnabled = true;
                  if (widget.disabledDates != null) {
                    for (var holiday in widget.disabledDates!) {
                      if (isSameDay(day, holiday)) {
                        isEnabled = false;
                      }
                    }
                    if (!isEnabled) return false;
                  }
                  if (widget.disabledDays != null) {
                    isEnabled =
                    !widget.disabledDays!.contains(day.weekday);
                  }

                  return isEnabled;
                },
                locale: widget.locale,
                firstDay: calculateFirstDay(),
                lastDay: widget.lastDay ??
                    DateTime.now().add(const Duration(days: 1000)),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                calendarStyle:
                const CalendarStyle(isTodayHighlighted: true),
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    selectNewDateRange();
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
            ),
            const SizedBox(height: 8),
            widget.bookingExplanation ??
                Wrap(
                  alignment: WrapAlignment.spaceAround,
                  spacing: 8.0,
                  runSpacing: 8.0,
                  direction: Axis.horizontal,
                  children: [
                    BookingExplanation(
                        color: widget.availableSlotColor ??
                            Colors.greenAccent,
                        text: widget.availableSlotText ??
                            "Available"),
                    BookingExplanation(
                        color: widget.selectedSlotColor ??
                            Colors.orangeAccent,
                        text:
                        widget.selectedSlotText ?? "Selected"),
                    BookingExplanation(
                        color: widget.bookedSlotColor ??
                            Colors.redAccent,
                        text: widget.bookedSlotText ?? "Booked"),
                    if (widget.hideBreakTime != null &&
                        widget.hideBreakTime == false)
                      BookingExplanation(
                          color:
                          widget.pauseSlotColor ?? Colors.grey,
                          text: widget.pauseSlotText ?? "Break"),
                  ],
                ),
            const SizedBox(height: 8),
            StreamBuilder<dynamic>(
              stream: widget.getBookingStream(
                  start: startOfDay, end: endOfDay),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return widget.errorWidget ??
                      Center(
                        child: Text(snapshot.error.toString()),
                      );
                }

                if (!snapshot.hasData) {
                  return widget.loadingWidget ??
                      const Center(
                          child: CircularProgressIndicator());
                }

                ///this snapshot should be converted to List<DateTimeRange>
                controller.generateBookedSlots(dateTimeList);

                return Expanded(
                  child: (widget.wholeDayIsBookedWidget != null &&
                      controller.isWholeDayBooked())
                      ? widget.wholeDayIsBookedWidget!
                      : GridView.builder(
                    physics: widget.gridScrollPhysics ??
                        const BouncingScrollPhysics(),
                    itemCount:
                    controller.allBookingSlots.length,
                    itemBuilder: (context, index) {
                      TextStyle? getTextStyle() {
                        if (controller.isSlotBooked(index)) {
                          return widget.bookedSlotTextStyle;
                        } else if (controller.selectedSlots
                            .contains(index)) {
                          return widget.selectedSlotTextStyle;
                        } else {
                          return widget
                              .availableSlotTextStyle;
                        }
                      }

                      final slot = controller.allBookingSlots
                          .elementAt(index);
                      return BookingSlot(
                        hideBreakSlot: widget.hideBreakTime,
                        pauseSlotColor: widget.pauseSlotColor,
                        availableSlotColor:
                        widget.availableSlotColor,
                        bookedSlotColor:
                        widget.bookedSlotColor,
                        selectedSlotColor:
                        widget.selectedSlotColor,
                        isPauseTime: controller
                            .isSlotInPauseTime(slot),
                        isBooked:
                        controller.isSlotBooked(index),
                        isSelected: controller.selectedSlots
                            .contains(index),
                        onTap: () =>
                            controller.selectSlot(index),
                        child: Center(
                          child: Text(
                            widget.formatDateTime
                                ?.call(slot) ??
                                BookingUtil.formatDateTime(
                                    slot),
                            style: getTextStyle(),
                          ),
                        ),
                      );
                    },
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                      widget.bookingGridCrossAxisCount ??
                          3,
                      childAspectRatio: widget
                          .bookingGridChildAspectRatio ??
                          1.5,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: CommonButton(
                      text: widget.bookingButtonText ?? 'BOOK',
                      onTap: () async {
                        navigateToPayingPage(context);
                      },
                      isDisabled: controller.selectedSlots.isEmpty,
                      buttonActiveColor: widget.bookingButtonColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: CommonButton(
                      text: 'Demo',
                      onTap: () async {
                        showAlertDialog(context);
                      },
                      isDisabled: controller.selectedSlots.isEmpty,
                      buttonActiveColor: widget.bookingButtonColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        : const Center(
      child: CircularProgressIndicator(),
    );
  }


  showAlertDialog(BuildContext context) {
    Widget continueButton = TextButton(
      child: const Text("Continue"),
      onPressed: () async {
        Navigator.of(context).pop();
        controller.toggleUploading();
        await widget.uploadBooking(
            newBooking: controller.generateNewBookingForUploading());
        controller.toggleUploading();
        controller.resetSelectedSlot();
        loadDateTimeList();
      },
    );

    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        controller.resetSelectedSlot();
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Confirm Booking"),
      content: Text(
          "Are you sure you want to book this slot for a price of ${(Globals.selectedLocation.price * (controller.selectedSlots.last - controller.selectedSlots.first + 1)).toStringAsFixed(2)}€?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void navigateToPayingPage(BuildContext context) async {
    if (controller.selectedSlots.isNotEmpty) {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String spotOwnerUserId = "";

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PayingPage(
            bookingStart: _selectedDay,
            bookingEnd: _selectedDay,
            // totalPrice: totalPrice,
            totalPrice: Globals.selectedLocation.price * (controller.selectedSlots.last - controller.selectedSlots.first + 1),
            userId: userId,
            spotOwnerUserId: spotOwnerUserId,
            bookingHourStart: controller.selectedSlots.first,
            bookingHourEnd: controller.selectedSlots.last,
          ),
        ),
      );
    }
  }
}


