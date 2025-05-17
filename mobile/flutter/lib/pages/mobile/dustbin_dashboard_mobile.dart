import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:swms_administration/constants/colours.dart';
import 'package:swms_administration/constants/text_styles.dart';
import 'package:swms_administration/models/bin_model.dart';
import 'package:swms_administration/pages/subpages/take_a_trip_page.dart';
import 'package:swms_administration/router/router.dart';
import 'package:swms_administration/router/router_names.dart';
import 'package:swms_administration/services/bin_services.dart';
import 'package:flutter/foundation.dart';
import 'package:swms_administration/widgets/reusable/line_chart.dart';

class DustbinDashboardMobile extends StatefulWidget {
  const DustbinDashboardMobile({super.key});

  @override
  State<DustbinDashboardMobile> createState() => _DustbinDashboardMobileState();
}

class _DustbinDashboardMobileState extends State<DustbinDashboardMobile> {
  late BinServices _binServices;
  List<Bin> _allBins = [];
  LatLng? _currentLocation;
  List<Bin> _filledBins = [];
  List<Bin> _nonEmptyBins = [];
  List<Bin> _halfEmptyBins = [];
  List<Bin> _liveBins = [];
  List<Bin> _emptyBins = [];
  bool _isLoading = true;
  late Map<String, int> binStats = {
    'filled': 0,
    'live': 0,
    'empty': 0,
    'total': 0,
    'attention': 0,
  };
  StreamSubscription<QuerySnapshot>? _binsSubscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MapController _mapController = MapController();

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(
      _mapController.camera.center,
      currentZoom + 1,
    );
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(
      _mapController.camera.center,
      currentZoom - 1,
    );
  }

  void _initialLocation() {
    if (_currentLocation != null) {
      _mapController.move(
        _currentLocation!,
        17,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _binServices = BinServices();
    _allBins = _binServices.allBins;
    _binServices.addListener(_onBinsUpdated);
    _getCurrentLocation();
    getBinStats();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enable location services'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            content: Text('Location permissions are denied'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          content: Text(
              'Location permissions are permanently denied. Please enable them in settings.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Fetch the current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (context.mounted) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    }
  }

  void _onBinsUpdated() {
    _allBins = _binServices.allBins;
    _filledBins =
        _allBins.where((bin) => bin.fillLevel >= bin.capacity).toList();
    _liveBins = _allBins.where((bin) => bin.networkStatus == true).toList();
    _emptyBins = _allBins.where((bin) => bin.fillLevel == 0).toList();
    _nonEmptyBins = _allBins.where((bin) => bin.fillLevel > 0).toList();
    _halfEmptyBins =
        _allBins.where((bin) => bin.fillLevel > (bin.capacity / 2)).toList();
    getBinStats();
  }

  void _openFullScreenMap(LatLng location) {
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          body: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    maxZoom: 21,
                    minZoom: 1,
                    initialZoom: 17,
                    initialCenter: location,
                    interactionOptions: InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          appColours.mapFilterColour, BlendMode.overlay),
                      child: TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                    ),
                    MarkerLayer(
                      markers: [
                        if (_currentLocation != null)
                          Marker(
                            point: _currentLocation!,
                            width: 15,
                            height: 15,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: appColours.myLocationColour1,
                                  border: Border.all(
                                    color: appColours.mainWhiteColour,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: appColours.myLocationColour2
                                          .withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 20,
                                    ),
                                  ]),
                            ),
                          ),
                        ..._allBins.map((bin) {
                          return Marker(
                            point: LatLng(bin.latitude, bin.longitude),
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(bin.name),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Location: ${bin.location}'),
                                        Text(
                                            'Fill Level: ${(bin.fillLevel * 100).toStringAsFixed(1)}%'),
                                        Text('Capacity: ${bin.capacity}L'),
                                      ],
                                    ),
                                    backgroundColor:
                                        AppColours().mainWhiteColour,
                                    titleTextStyle: AppTextStyles()
                                        .subtitleStyleMobile
                                        .copyWith(
                                          color: AppColours().mainThemeColour,
                                        ),
                                    contentTextStyle:
                                        AppTextStyles().bodyTextStyle,
                                    actions: [
                                      TextButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                  AppColours().mainThemeColour),
                                          textStyle: WidgetStatePropertyAll(
                                            AppTextStyles()
                                                .buttonTextStyle
                                                .copyWith(
                                                    color: AppColours()
                                                        .mainWhiteColour),
                                          ),
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          'Close',
                                          style: GoogleFonts.poppins(
                                              textStyle: TextStyle(
                                            color: AppColours().mainWhiteColour,
                                          )),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.location_on,
                                color: bin.fillLevel > 0.75
                                    ? appColours.errorColour
                                    : bin.fillLevel > 0.5
                                        ? appColours.midBinColour
                                        : bin.fillLevel > 0.25
                                            ? appColours.fineBinColour
                                            : appColours.goodBinColour,
                                size: 30,
                              ),
                            ),
                          );
                        })
                      ],
                    )
                  ],
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: FloatingActionButton(
                  backgroundColor: AppColours().mainThemeColour,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  tooltip: 'Exit full-screen View',
                  heroTag: 'exitFullScreen',
                  mini: true,
                  child: Icon(
                    Icons.fullscreen_exit_rounded,
                    color: AppColours().mainWhiteColour,
                  ),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: Column(
                  children: [
                    if (_currentLocation != null)
                      FloatingActionButton(
                        backgroundColor: AppColours().mainThemeColour,
                        onPressed: _initialLocation,
                        tooltip: 'My Location',
                        heroTag: 'meLocate',
                        child: Icon(
                          Icons.my_location_outlined,
                          color: AppColours().mainWhiteColour,
                          size: 30,
                        ),
                      ),
                    SizedBox(
                      height: 8,
                    ),
                    FloatingActionButton(
                      backgroundColor: AppColours().mainThemeColour,
                      onPressed: _zoomIn,
                      tooltip: 'Zoom In',
                      heroTag: 'zoomIn',
                      child: Icon(
                        Icons.add,
                        color: AppColours().mainWhiteColour,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      backgroundColor: AppColours().mainThemeColour,
                      heroTag: 'zoomOut',
                      tooltip: 'Zoom Out',
                      onPressed: _zoomOut,
                      child: Icon(
                        Icons.remove,
                        color: AppColours().mainWhiteColour,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _binServices.removeListener(_onBinsUpdated);
    _binServices.dispose();
    super.dispose();
  }

  Future<void> _loadBinData() async {
    setState(() => _isLoading = true);

    try {
      _allBins = BinServices().allBins;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading bin data: $e');
      }
      _allBins = [];
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void getBinStats() {
    setUpBinsListener();
  }

  void setUpBinsListener() {
    _binsSubscription =
        _firestore.collection('Dustbins').snapshots().listen((snapshot) {
      _allBins.clear();
      for (var doc in snapshot.docs) {
        Map<String, dynamic> binData = doc.data() as Map<String, dynamic>;
        Bin bin = Bin(
          binData['mainBin'] ?? '',
          id: doc.id,
          name: binData['name'] ?? 'Unknown Bin',
          imageUrl: binData['imageUrl'] ?? 'assets/images/Pagama.png',
          fillLevel: (binData['fillLevel'] ?? 0).toDouble(),
          gasLevel: (binData['gasLevel'] ?? 0).toDouble(),
          humidity: (binData['humidity'] ?? 0).toDouble(),
          temperature: (binData['temperature'] ?? 0).toDouble(),
          precipitation: (binData['precipitation'] ?? 0).toDouble(),
          fillStatus: binData['fillStatus'] ?? false,
          isClosed: binData['isClosed'] ?? false,
          isControllerOnClosed: binData['isControllerOnClosed'] ?? false,
          networkStatus: binData['networkStatus'] ?? false,
          isManual: binData['isManual'] ?? true,
          type: binData['type'] ?? 'Unknown',
          capacity: (binData['capacity'] ?? 0).toDouble(),
          isSub: binData['isSub'] ?? false,
          location: binData['location'] ?? '',
          latitude: (binData['latitude'] ?? 6.904946).toDouble(),
          longitude: (binData['longitude'] ?? 79.861151).toDouble(),
        );
        _allBins.add(bin);
      }
      setState(() {
        binStats = {
          'filled':
              _allBins.where((bin) => bin.fillLevel >= bin.capacity).length,
          'live': _allBins.where((bin) => bin.networkStatus == true).length,
          'empty': _allBins.where((bin) => bin.fillLevel == 0).length,
          'total': _allBins.length,
          'attention': _allBins.where((bin) => bin.gasLevel > 649).length +
              _allBins
                  .where((bin) => bin.temperature > 45 || bin.temperature < 4)
                  .length,
        };
        _nonEmptyBins = _allBins.where((bin) => bin.fillLevel > 0).toList();
        _halfEmptyBins = _allBins
            .where((bin) => bin.fillLevel > (bin.capacity / 2))
            .toList();
      });
      _isLoading = false;
    });
  }

  final appColours = AppColours();
  Widget _buildStatCard(String title, int count, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appColours.containerShadowColour,
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
            color: appColours.mainBlackColour.withOpacity(0.1), width: 1),
        color: appColours.mainWhiteColour,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$title Bins',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  count.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: appColours.valueColour,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColours.mainWhiteColour,
      appBar: AppBar(
        toolbarHeight: 110,
        backgroundColor: appColours.mainWhiteColour,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dustbin Dashboard',
              style: AppTextStyles().pageTitleStyleMobile,
            ),
            const SizedBox(height: 6),
            Text(
              'Monitor your waste management system',
              style: AppTextStyles().pageHeadlineStyleMobile,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: appColours.mainTextColour),
            onPressed: _loadBinData,
            tooltip: 'Refresh data',
          ),
          // IconButton(
          //   icon: const Icon(Icons.more_vert, color: appColours.mainTextColour),
          //   onPressed: () {},
          // ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              elevation: 2,
              displacement: MediaQuery.of(context).size.height * 0.44 / 3,
              color: appColours.mainThemeColour,
              backgroundColor: appColours.mainThemeColour,
              onRefresh: _loadBinData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Stats grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                        children: [
                          _buildStatCard(
                              'Filled',
                              binStats['filled']!,
                              appColours.filledBinsColour,
                              FontAwesomeIcons.solidTrashCan),
                          _buildStatCard(
                              'Live',
                              binStats['live']!,
                              appColours.liveBinsColour,
                              Icons.signal_cellular_alt_rounded),
                          _buildStatCard(
                              'Empty',
                              binStats['empty']!,
                              appColours.emptyBinsColour,
                              FontAwesomeIcons.trashCan),
                          _buildStatCard('Total', binStats['total']!,
                              appColours.totalBinsColour, Icons.ballot_rounded),
                        ],
                      ),

                      const SizedBox(height: 24),
                      _nonEmptyBins.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: appColours.mainWhiteColour,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: appColours.containerShadowColour,
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.checkCircle,
                                      color: appColours.profilePageMembers1,
                                      size: 40,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'WooHoo! All the trash have been collected!',
                                      style: AppTextStyles()
                                          .subtitleStyleMobile
                                          .copyWith(
                                            color: AppColours()
                                                .profilePageMembers1,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: appColours.mainWhiteColour,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: appColours.containerShadowColour,
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.truckFast,
                                        color: appColours.profilePageMembers1,
                                      ),
                                      const SizedBox(width: 15),
                                      Text(
                                        'Collections',
                                        style:
                                            AppTextStyles().subtitleStyleMobile,
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              TakeATripPage(
                                            stops: _nonEmptyBins,
                                            title: 'System Cleaner',
                                            tripColour:
                                                AppColours().emptyBinsColour,
                                          ),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: ScaleTransition(
                                                scale: Tween<double>(
                                                  begin: 0.0,
                                                  end: 1.0,
                                                ).animate(animation),
                                                child: child,
                                              ),
                                            );
                                          },
                                          transitionDuration:
                                              Duration(milliseconds: 200),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width * 1,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons.broom,
                                                  color: appColours
                                                      .emptyBinsColour,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 16),
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    'System Cleaner',
                                                    style: AppTextStyles()
                                                        .subtitleStyleMobile
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                ),
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    'Empty all the bins in the system',
                                                    style: GoogleFonts.poppins(
                                                      color: appColours
                                                          .textColour2,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              TakeATripPage(
                                            stops: _halfEmptyBins,
                                            title: 'Daily Collection',
                                            tripColour:
                                                AppColours().totalBinsColour,
                                          ),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: ScaleTransition(
                                                scale: Tween<double>(
                                                  begin: 0.0,
                                                  end: 1.0,
                                                ).animate(animation),
                                                child: child,
                                              ),
                                            );
                                          },
                                          transitionDuration:
                                              Duration(milliseconds: 200),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width * 1,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons
                                                      .calendarCheck,
                                                  color: appColours
                                                      .totalBinsColour,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 16),
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    'Daily Collection',
                                                    style: AppTextStyles()
                                                        .subtitleStyleMobile
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                ),
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    'Collect half filled bins',
                                                    style: GoogleFonts.poppins(
                                                      color: appColours
                                                          .textColour2,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              TakeATripPage(
                                            stops: _filledBins,
                                            title: 'Eco Route',
                                            tripColour:
                                                AppColours().liveBinsColour,
                                          ),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: ScaleTransition(
                                                scale: Tween<double>(
                                                  begin: 0.0,
                                                  end: 1.0,
                                                ).animate(animation),
                                                child: child,
                                              ),
                                            );
                                          },
                                          transitionDuration:
                                              Duration(milliseconds: 200),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width * 1,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons.envira,
                                                  color:
                                                      appColours.liveBinsColour,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 16),
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    'Eco Route',
                                                    style: AppTextStyles()
                                                        .subtitleStyleMobile
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                ),
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    'Collect only the filled bins',
                                                    style: GoogleFonts.poppins(
                                                      color: appColours
                                                          .textColour2,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      SizedBox(
                        height: 24,
                      ),

                      // System status
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: appColours.mainWhiteColour,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: appColours.containerShadowColour,
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  color: appColours.liveBinsColour,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'System Status',
                                  style: AppTextStyles().subtitleStyleMobile,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildStatusItem(
                              binStats['live'] == 0
                                  ? 'No bins are in Live!'
                                  : 'System Operational',
                              'All services running normally',
                              binStats['live'] == 0
                                  ? Icons.error
                                  : Icons.check_circle_outline,
                              appColours.wellColour,
                            ),
                            const SizedBox(height: 12),
                            _buildStatusItem(
                              'Collection Status',
                              binStats['filled'] == 0
                                  ? 'No Bins in the Eco Route!'
                                  : _halfEmptyBins.length == 1
                                      ? 'There is only one half filled bin in the system!'
                                      : 'There are ${_halfEmptyBins.length} half empty bins now',
                              Icons.schedule,
                              appColours.collColour,
                            ),
                            const SizedBox(height: 12),
                            _buildStatusItem(
                              'Alerts',
                              binStats['attention'] == 0
                                  ? 'No Alerts!'
                                  : binStats['attention'] == 1
                                      ? 'One bin needs attention'
                                      : '${binStats['attention']} bins need attention',
                              Icons.warning_amber_outlined,
                              appColours.alertsColour,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      GestureDetector(
                        onDoubleTap: () {
                          _openFullScreenMap(_mapController.camera.center);
                        },
                        child: Container(
                          height: 300,
                          decoration: BoxDecoration(
                            color: appColours.mainWhiteColour,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: appColours.containerShadowColour,
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                            border: Border.all(
                              color:
                                  appColours.mainBlackColour.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(
                                    initialCenter: LatLng(
                                      _allBins.isNotEmpty
                                          ? _allBins.first.latitude
                                          : 6.904946, // Default latitude
                                      _allBins.isNotEmpty
                                          ? _allBins.first.longitude
                                          : 79.861151, // Default longitude
                                    ),
                                    initialZoom: 13,
                                  ),
                                  children: [
                                    ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                          appColours.mapFilterColour,
                                          BlendMode.overlay),
                                      child: TileLayer(
                                        urlTemplate:
                                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        subdomains: const ['a', 'b', 'c'],
                                      ),
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        if (_currentLocation != null)
                                          Marker(
                                            point: _currentLocation!,
                                            width: 15,
                                            height: 15,
                                            child: Container(
                                              width: 7,
                                              height: 7,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  color: appColours
                                                      .myLocationColour1,
                                                  border: Border.all(
                                                    color: appColours
                                                        .mainWhiteColour,
                                                    width: 1.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: appColours
                                                          .myLocationColour2
                                                          .withOpacity(0.5),
                                                      blurRadius: 20,
                                                      spreadRadius: 20,
                                                    ),
                                                  ]),
                                            ),
                                          ),
                                        ..._allBins.map((bin) {
                                          return Marker(
                                            point: LatLng(
                                                bin.latitude, bin.longitude),
                                            width: 40,
                                            height: 40,
                                            child: GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: Text(bin.name),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            'Location: ${bin.location}'),
                                                        Text(
                                                            'Fill Level: ${(bin.fillLevel * 100).toStringAsFixed(1)}%'),
                                                        Text(
                                                            'Capacity: ${bin.capacity}L'),
                                                      ],
                                                    ),
                                                    backgroundColor:
                                                        AppColours()
                                                            .mainWhiteColour,
                                                    titleTextStyle:
                                                        AppTextStyles()
                                                            .subtitleStyleMobile
                                                            .copyWith(
                                                              color: AppColours()
                                                                  .mainThemeColour,
                                                            ),
                                                    contentTextStyle:
                                                        AppTextStyles()
                                                            .bodyTextStyle,
                                                    actions: [
                                                      TextButton(
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              WidgetStatePropertyAll(
                                                                  AppColours()
                                                                      .mainThemeColour),
                                                          textStyle:
                                                              WidgetStatePropertyAll(
                                                            AppTextStyles()
                                                                .buttonTextStyle
                                                                .copyWith(
                                                                    color: AppColours()
                                                                        .mainWhiteColour),
                                                          ),
                                                        ),
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: Text(
                                                          'Close',
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  textStyle:
                                                                      TextStyle(
                                                            color: AppColours()
                                                                .mainWhiteColour,
                                                          )),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              child: Icon(
                                                Icons.location_on,
                                                color: bin.fillLevel > 0.75
                                                    ? appColours.errorColour
                                                    : bin.fillLevel > 0.5
                                                        ? appColours
                                                            .midBinColour
                                                        : bin.fillLevel > 0.25
                                                            ? appColours
                                                                .fineBinColour
                                                            : appColours
                                                                .goodBinColour,
                                                size: 30,
                                              ),
                                            ),
                                          );
                                        })
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 16,
                                right: 16,
                                child: FloatingActionButton(
                                  backgroundColor: AppColours().mainThemeColour,
                                  onPressed: () {
                                    _openFullScreenMap(
                                        _mapController.camera.center);
                                  },
                                  tooltip: 'Full-screen View',
                                  heroTag: 'fullScreen',
                                  mini: true,
                                  child: Icon(
                                    Icons.fullscreen_rounded,
                                    color: AppColours().mainWhiteColour,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 16,
                                bottom: 15,
                                child: Column(
                                  children: [
                                    if (_currentLocation != null)
                                      FloatingActionButton(
                                        backgroundColor:
                                            AppColours().mainThemeColour,
                                        onPressed: _initialLocation,
                                        tooltip: 'My Location',
                                        heroTag: 'meLocate',
                                        mini: true,
                                        child: Icon(
                                          Icons.my_location_outlined,
                                          color: AppColours().mainWhiteColour,
                                        ),
                                      ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    FloatingActionButton(
                                      backgroundColor:
                                          AppColours().mainThemeColour,
                                      onPressed: _zoomIn,
                                      tooltip: 'Zoom In',
                                      heroTag: 'zoomIn',
                                      mini: true,
                                      child: Icon(
                                        Icons.add,
                                        color: AppColours().mainWhiteColour,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    FloatingActionButton(
                                      backgroundColor:
                                          AppColours().mainThemeColour,
                                      heroTag: 'zoomOut',
                                      tooltip: 'Zoom Out',
                                      mini: true,
                                      onPressed: _zoomOut,
                                      child: Icon(
                                        Icons.remove,
                                        color: AppColours().mainWhiteColour,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Fill level distribution section
                      Text(
                        'Fill Level Distribution',
                        style: AppTextStyles().subtitleStyleMobile,
                      ),
                      const SizedBox(height: 12),
                      LineChartCard(
                        selectionColor:
                            appColours.filledBinsColour.withOpacity(0.8),
                        greyColor: appColours.valueColour.withOpacity(0.6),
                        title: 'Filled Bins',
                        isDesktop: false,
                        isFilled: true,
                      ),
                      const SizedBox(height: 12),
                      LineChartCard(
                        selectionColor:
                            appColours.emptyBinsColour.withOpacity(0.8),
                        greyColor: appColours.valueColour.withOpacity(0.6),
                        title: 'Empty Bins',
                        isDesktop: false,
                        isFilled: false,
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        hoverElevation: 50,
        elevation: 5,
        backgroundColor: appColours.mainThemeColour,
        onPressed: () {
          RouterClass.router.pushNamed(RouterNames().createbin);
        },
        tooltip: 'Add New Dustbin',
        child: Icon(
          Icons.add,
          color: appColours.mainWhiteColour,
        ),
      ),
    );
  }

  Widget _buildStatusItem(
      String title, String description, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles().subtitleStyleMobile.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: appColours.textColour2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
