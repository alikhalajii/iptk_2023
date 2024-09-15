// ignore_for_file: unused_field, library_private_types_in_public_api

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:myapp/generalPages/chats_page.dart';
import 'package:myapp/historyPages/history.dart';
import 'package:myapp/homePages/entering_page.dart';
import 'package:myapp/homePages/homepage.dart';
import 'package:myapp/recommendationPages/recommendation.dart';
// ignore: library_prefixes
import 'package:myapp/settingsPages/settings.dart' as MyAppSettings;
import 'firebase_options.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'models/globals.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //initOneSignal();

  //Service bookingService = Service();
  //bookingService.listenToBookings();

  runApp(
    ChangeNotifierProvider(
      create: (_) => DarkThemeProvider(),
      child: const MyApp(),
    ),
  );
  print("initOneSignal loading...");
  initOneSignal();
  //Service bookingService = Service();
  // bookingService.listenToBookings();
}

class DarkThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  bool _isLogged = false;
  bool _isLoaded = false;
  String initialRoute = '/enteringPage';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          navigatorKey.currentState?.pushReplacementNamed('/home');
          break;
        case 1:
          navigatorKey.currentState?.pushReplacementNamed('/recommendation');
          break;
        case 2:
          navigatorKey.currentState?.pushReplacementNamed('/history');
          break;
        case 3:
          navigatorKey.currentState?.pushReplacementNamed('/chatsPage');
          break;
        case 4:
          navigatorKey.currentState?.pushReplacementNamed('/settings');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    giveContext();
    // todo
    //final firebaseApi = FirebaseApi(navigatorKey: navigatorKey);
    //firebaseApi?.initNotifications();

    DarkThemeProvider darkThemeProvider =
    Provider.of<DarkThemeProvider>(context);
    return _isLoaded? MaterialApp(
      title: 'spaceXchange',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            color: Colors.grey.shade700, // Set your desired text color here
          ),
          bodyMedium: TextStyle(
            color: Colors.grey.shade700, // Set your desired text color here
          ),
          bodySmall: TextStyle(
            color: Colors.grey.shade700, // Set your desired text color here
          ),
        ),
        //textTheme: TextTheme(:),
        brightness:
        darkThemeProvider.isDarkMode ? Brightness.dark : Brightness.light,
      ),
      routes: {
        '/home': (context) =>
            HomePage(onTap: _onItemTapped, selectedIndex: _selectedIndex),
        '/recommendation': (context) =>
            Recommendation(onTap: _onItemTapped, selectedIndex: _selectedIndex),
        '/history': (context) =>
            History(onTap: _onItemTapped, selectedIndex: _selectedIndex),
        '/chatsPage': (context) =>
            ChatsPage(onTap: _onItemTapped, selectedIndex: _selectedIndex),
        '/settings': (context) => MyAppSettings.Settings(
            onTap: _onItemTapped,
            selectedIndex: _selectedIndex), // Add this line
        '/entering': (context) => const EnteringPage(),
      },
      initialRoute: initialRoute,
    )
    : const Center(child: CircularProgressIndicator());
  }

  Future<void> _checkLoginStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await Globals.convertFutureToList();
      setState(() {
        _isLogged = true;
        _isLoaded = true;
        initialRoute = '/home';
      });
      navigatorKey.currentState?.pushReplacementNamed('/home');
    } else {
      setState(() {
        _isLogged = false;
        _isLoaded = true;
        initialRoute = '/entering';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  Context giveContext() {
    return context;
  }
}


Future<void> initOneSignal() async {
  try {
    await OneSignal.shared.setAppId("bfb06766-6f6e-4c95-a8d0-df830b7e7f8f");
    final status = await OneSignal.shared.getDeviceState();
    final String? osUserID = status?.userId;
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    await storeOneSignalUserIdInFirestore(userId, osUserID);

    ///
    await OneSignal.shared.promptUserForPushNotificationPermission(
      fallbackToSettings: true,
    );
    OneSignal.shared.setNotificationWillShowInForegroundHandler(
      handleForegroundNotifications,
    );
    OneSignal.shared.setNotificationOpenedHandler(handleBackgroundNotification);
  } catch (error) {
    log('Error');
  }
}

Future<void> storeOneSignalUserIdInFirestore(
    String? userId, String? oneSignalUserId) async {
  if (userId != null && oneSignalUserId != null) {
    var userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    await userRef.update({'oneSignal': oneSignalUserId});
  }
}

// Method to handle foreground notifications
void handleForegroundNotifications(OSNotificationReceivedEvent event) {
  // navigateToPage(event.notification);
}

// Method to handle background notifications
void handleBackgroundNotification(OSNotificationOpenedResult result) {
  navigateToPage(result.notification);
}

void navigateToPage(OSNotification notification) {
  print("Navigator caught a Route!");
  if (notification.additionalData != null) {
    String pageToOpen = notification.additionalData!['page'];
    print("Route is: $pageToOpen");
    // Add a switch statement to handle different pages
    switch (pageToOpen) {
      case '/history':
        navigatorKey.currentState?.pushReplacementNamed('/history');
        break;
      case '/chats_page':
        navigatorKey.currentState?.pushReplacementNamed('/chatsPage');
        break;
    }
  }
}
