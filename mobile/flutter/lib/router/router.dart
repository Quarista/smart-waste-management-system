import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:swms_administration/constants/colours.dart';
import 'package:swms_administration/main_page.dart';
import 'package:swms_administration/models/bin_model.dart';
import 'package:swms_administration/models/post_model.dart';
import 'package:swms_administration/pages/desktop/dustbin_dashboard_desktop.dart';
import 'package:swms_administration/pages/mobile/dustbin_dashboard_mobile.dart';
import 'package:swms_administration/pages/mobile/home_page_mobile.dart';
import 'package:swms_administration/pages/profile_page.dart';
import 'package:swms_administration/pages/session_expired_page.dart';
import 'package:swms_administration/pages/subpages/bin_details_page.dart';
import 'package:swms_administration/pages/subpages/create_new_bin_page.dart';
import 'package:swms_administration/pages/subpages/create_new_post_page.dart';
import 'package:swms_administration/pages/subpages/take_a_trip_page.dart';
import 'package:swms_administration/presentation/splash/splash_screen.dart';
import 'package:swms_administration/router/page_transitions.dart';
import 'package:swms_administration/router/router_names.dart';

class RouterClass {
  static final router = GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(),
    debugLogDiagnostics: true,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/',
        name: RouterNames().main,
        pageBuilder: (context, state) => buildMotionPage(
          name: 'AppLaunch',
          child: const MainPage(),
          intensity: 0.2,
          elevation: 2,
        ),
      ),
      GoRoute(
        path: '/loading',
        builder: (context, state) {
          return CircularProgressIndicator();
        },
      ),
      GoRoute(
        path: '/splash',
        name: RouterNames().splash,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/home',
        name: RouterNames().home,
        builder: (context, state) {
          return HomePageMobile();
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) {
          return DustbinDashboardMobile();
        },
      ),
      GoRoute(
        path: '/dashboardd',
        builder: (context, state) {
          return DustbinDashboardDesktop();
        },
      ),
      GoRoute(
        path: '/bin',
        name: RouterNames().bin,
        pageBuilder: (context, state) {
          final Map<String, String> bin = state.extra as Map<String, String>;
          final String id = bin['id']!;
          final String name = bin['name']!;
          final String location = bin['location']!;
          final double latitude = double.parse(bin['latitude']!);
          final double longitude = double.parse(bin['longitude']!);
          final double fillLevel = double.parse(bin['fillLevel']!);
          final double gasLevel = double.parse(bin['gasLevel']!);
          final double humidity = double.parse(bin['humidity']!);
          final double temperature = double.parse(bin['temperature']!);
          final double precipitation = double.parse(bin['precipitation']!);
          final bool fillStatus = bool.parse(bin['fillStatus']!);
          final bool isClosed = bool.parse(bin['isClosed']!);
          final bool isControllerOnClosed =
              bool.parse(bin['isControllerOnClosed']!);
          final String imageUrl = bin['imageUrl']!;
          final String type = bin['type']!;
          final double capacity = double.parse(bin['capacity']!);
          final bool isSub = bool.parse(bin['isSub']!);
          final bool networkStatus = bool.parse(bin['networkStatus']!);
          final bool isManual = bool.parse(bin['isManual']!);
          final String? mainBin = bin['mainBin'];
          return buildMotionPage(
            child: BinDetailsPage(
              bin: Bin(
                capacity: capacity,
                id: id,
                name: name,
                imageUrl: imageUrl,
                fillLevel: fillLevel,
                gasLevel: gasLevel,
                humidity: humidity,
                temperature: temperature,
                precipitation: precipitation,
                fillStatus: fillStatus,
                isClosed: isClosed,
                isControllerOnClosed: isControllerOnClosed,
                type: type,
                isSub: isSub,
                location: location,
                latitude: latitude,
                longitude: longitude,
                mainBin,
                networkStatus: networkStatus,
                isManual: isManual,
              ),
            ),
            intensity: 0.5, // More pronounced effect
            elevation: 2, // Stronger shadow
          );
        },
      ),
      GoRoute(
        path: '/bind',
        name: RouterNames().bind,
        pageBuilder: (context, state) {
          final Map<String, String> bin = state.extra as Map<String, String>;
          final String id = bin['id']!;
          final String name = bin['name']!;
          final String location = bin['location']!;
          final double latitude = double.parse(bin['latitude']!);
          final double longitude = double.parse(bin['longitude']!);
          final double fillLevel = double.parse(bin['fillLevel']!);
          final double gasLevel = double.parse(bin['gasLevel']!);
          final double humidity = double.parse(bin['humidity']!);
          final double temperature = double.parse(bin['temperature']!);
          final double precipitation = double.parse(bin['precipitation']!);
          final bool fillStatus = bool.parse(bin['fillStatus']!);
          final bool isClosed = bool.parse(bin['isClosed']!);
          final bool isControllerOnClosed =
              bool.parse(bin['isControllerOnClosed']!);
          final String imageUrl = bin['imageUrl']!;
          final String type = bin['type']!;
          final double capacity = double.parse(bin['capacity']!);
          final bool isSub = bool.parse(bin['isSub']!);
          final bool networkStatus = bool.parse(bin['networkStatus']!);
          final bool isManual = bool.parse(bin['isManual']!);
          final String? mainBin = bin['mainBin'];
          return buildMotionPage(
            child: BinDetailsPage(
              bin: Bin(
                capacity: capacity,
                id: id,
                name: name,
                imageUrl: imageUrl,
                fillLevel: fillLevel,
                gasLevel: gasLevel,
                humidity: humidity,
                temperature: temperature,
                precipitation: precipitation,
                fillStatus: fillStatus,
                isClosed: isClosed,
                isControllerOnClosed: isControllerOnClosed,
                type: type,
                isSub: isSub,
                location: location,
                latitude: latitude,
                longitude: longitude,
                mainBin,
                networkStatus: networkStatus,
                isManual: isManual,
              ),
            ),
            intensity: 0.5, // More pronounced effect
            elevation: 2, // Stronger shadow
          );
        },
      ),
      GoRoute(
        path: '/createpost',
        name: RouterNames().createpost,
        pageBuilder: (context, state) {
          final Map<Post, bool> newPost = state.extra as Map<Post, bool>;
          final Post post = newPost.keys.first;
          final bool isNew = newPost.values.first;
          return buildMotionPage(
            name: 'FadeUp',
            child: CreateNewPostPage(
              post: post,
              isNew: isNew,
            ),
            intensity: 0.2, // More pronounced effect
            elevation: 2, // Stronger shadow
          );
        },
      ),
      GoRoute(
        path: '/createbin',
        name: RouterNames().createbin,
        pageBuilder: (context, state) => buildMotionPage(
          child: CreateNewBinPage(),
          name: 'FadeUp',
          intensity: 0.5, // More pronounced effect
          elevation: 2, // Stronger shadow
        ),
      ),
      GoRoute(
        path: '/quarista',
        name: RouterNames().quarista,
        pageBuilder: (context, state) {
          return buildMotionPage(
            name: 'FadeDown',
            child: ProfilePage(),
            intensity: 0.2, // More pronounced effect
            elevation: 2, // Stronger shadow
          );
        },
      ),
      GoRoute(
        path: '/trip',
        name: RouterNames().trip,
        builder: (context, state) {
          final Map<String, List<Bin>> page =
              state.extra as Map<String, List<Bin>>;
          final List<Bin> stops = page.values.first;
          return TakeATripPage(
            stops: stops,
            title: page.keys.first,
            tripColour: AppColours().mainThemeColour,
          );
        },
      ),
    ],
  );
}
