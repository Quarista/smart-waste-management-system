import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swms_administration/constants/colours.dart';
import 'package:swms_administration/pages/session_expired_page.dart';
import 'package:swms_administration/presentation/splash/splash_screen.dart';
import 'package:swms_administration/router/router.dart';
import 'package:swms_administration/services/bin_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyBuQojRghtJFFuHDUBD0nMtfFKm_AKVGz0",
            authDomain: "dustbin-management-system.firebaseapp.com",
            databaseURL:
                "https://dustbin-management-system-default-rtdb.firebaseio.com",
            projectId: "dustbin-management-system",
            storageBucket: "dustbin-management-system.firebasestorage.app",
            messagingSenderId: "938398765208",
            appId: "1:938398765208:web:100b3d6a36f17c09d080ed"));
  } else {
    await Firebase.initializeApp();
  }
  BinHistoryTracker.startTracking();
  runApp(ChangeNotifierProvider(
    create: (context) => AppColours(),
    child: const MyApp(),
  ));
}

//this is by Rihan Ekanayake Your team leader REply by WhatsApp If you saw this with a screenshot
//successfully done

final GlobalKey<_MyAppState> myAppKey = GlobalKey<_MyAppState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isSessionValid = false;
  String errorTitle = 'Session Expired';
  String errorText =
      'Your session for viewing this application is no longer valid due to privacy issues.';
  bool sessionInitialized = false;
  late StreamSubscription<DocumentSnapshot> _sessionSubscription;

  @override
  void initState() {
    super.initState();
    _startSessionListener();
  }

  @override
  void dispose() {
    _sessionSubscription.cancel();
    super.dispose();
  }

  void _startSessionListener() {
    final docRef = FirebaseFirestore.instance
        .collection("A1_SuperAdmin_QuaristaControl")
        .doc('quicklookSession');

    _sessionSubscription = docRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final isValid = data['isValid'] ?? false;
        final error = data['errortext'] ?? 'Session Expired';
        final mesg = data['errormessage'] ??
            'Your session for viewing this application is no longer valid due to privacy issues.';
        setState(() {
          isSessionValid = isValid;
          errorTitle = error;
          errorText = mesg;
          sessionInitialized = true;
        });
      } else {
        setState(() {
          sessionInitialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return sessionInitialized
        ? MaterialApp.router(
            key: myAppKey,
            title: "EquaBin",
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(alwaysUse24HourFormat: true),
                child: child!,
              );
            },
            debugShowCheckedModeBanner: false,
            routerConfig: RouterClass.router,
          )
        : MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SplashScreen(),
          );
  }
}
