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

class DustbinDashboardDesktop extends StatefulWidget {
  const DustbinDashboardDesktop({super.key});

  @override
  State<DustbinDashboardDesktop> createState() =>
      _DustbinDashboardDesktopState();
}

class _DustbinDashboardDesktopState extends State<DustbinDashboardDesktop> {
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
                          AppColours().mapFilterColour, BlendMode.overlay),
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
                                  color: AppColours().myLocationColour1,
                                  border: Border.all(
                                    color: AppColours().mainWhiteColour,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColours()
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
                                    ? AppColours().errorColour
                                    : bin.fillLevel > 0.5
                                        ? AppColours().midBinColour
                                        : bin.fillLevel > 0.25
                                            ? AppColours().fineBinColour
                                            : AppColours().goodBinColour,
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

  Widget _buildStatCard(
      String title, int count, Color accentColor, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColours().containerShadowColour,
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
            color: AppColours().mainBlackColour.withOpacity(0.1), width: 1),
        color: AppColours().mainWhiteColour,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accentColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  '$title Bins',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  count.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 65,
                    fontWeight: FontWeight.bold,
                    color: AppColours().valueColour,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'bins',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: AppColours().mainGreyColour,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(title),
                    color: accentColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String category) {
    switch (category) {
      case 'Filled':
        return Icons.delete_rounded;
      case 'Live':
        return Icons.signal_cellular_alt_rounded;
      case 'Empty':
        return Icons.restore_from_trash_rounded;
      case 'Total':
        return Icons.ballot_rounded;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final appColours = AppColours();

    return Scaffold(
      backgroundColor: AppColours().scaffoldColour,
      appBar: AppBar(
        toolbarHeight: 130,
        backgroundColor: AppColours().mainWhiteColour,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dustbin Dashboard',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColours().mainTextColour,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Monitor your waste management system',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColours().textColour2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColours().mainTextColour),
            onPressed: _loadBinData,
            tooltip: 'Refresh data',
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColours().mainThemeColour,
                    foregroundColor: AppColours().mainWhiteColour,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Bin'),
                  onPressed: () {
                    RouterClass.router.pushNamed(RouterNames().createbin);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.insights,
                            color: AppColours().mainThemeColour),
                        const SizedBox(width: 8),
                        Text(
                          'Key Statistics',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColours().mainTextColour,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: screenWidth < 1200 ? 2 : 4,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                            'Filled',
                            binStats['filled']!,
                            AppColours().filledBinsColour,
                            FontAwesomeIcons.solidTrashCan),
                        _buildStatCard(
                            'Live',
                            binStats['live']!,
                            AppColours().wellColour,
                            Icons.signal_cellular_alt_rounded),
                        _buildStatCard(
                            'Empty',
                            binStats['empty']!,
                            AppColours().emptyBinsColour,
                            FontAwesomeIcons.trashCan),
                        _buildStatCard('Total', binStats['total']!,
                            AppColours().totalBinsColour, Icons.ballot_rounded),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 1.5,
                      children: [
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.truckFast,
                                          color: appColours.profilePageMembers1,
                                        ),
                                        const SizedBox(width: 15),
                                        Text(
                                          'Collections',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      height: 0.5,
                                      color: AppColours()
                                          .mainGreyColour
                                          .withOpacity(0.2),
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
                                      child: _buildStatusItem(
                                        'System Cleaner',
                                        'Empty all the bins in the system',
                                        FontAwesomeIcons.broom,
                                        appColours.emptyBinsColour,
                                        true,
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
                                      child: _buildStatusItem(
                                        'Daily Collection',
                                        'Collect half filled bins',
                                        FontAwesomeIcons.calendarCheck,
                                        appColours.totalBinsColour,
                                        true,
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
                                      child: _buildStatusItem(
                                        'Eco Route',
                                        'Collect only the filled bins',
                                        FontAwesomeIcons.envira,
                                        appColours.liveBinsColour,
                                        true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                                color: AppColours()
                                    .mainBlackColour
                                    .withOpacity(0.1),
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
                                            AppColours().mapFilterColour,
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
                                                    color: AppColours()
                                                        .myLocationColour1,
                                                    border: Border.all(
                                                      color: AppColours()
                                                          .mainWhiteColour,
                                                      width: 1.5,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: AppColours()
                                                            .myLocationColour2,
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
                                                      ? AppColours().errorColour
                                                      : bin.fillLevel > 0.5
                                                          ? AppColours()
                                                              .midBinColour
                                                          : bin.fillLevel > 0.25
                                                              ? AppColours()
                                                                  .fineBinColour
                                                              : AppColours()
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
                                    backgroundColor:
                                        AppColours().mainThemeColour,
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
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColours().mainWhiteColour,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColours().mainBlackColour.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                color: AppColours().wellColour,
                                size: 27,
                              ),
                              const SizedBox(width: 15),
                              Text(
                                'System Status',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Divider(
                            height: 0.5,
                            color: AppColours().mainGreyColour.withOpacity(0.2),
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
                            AppColours().wellColour,
                            false,
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
                            AppColours().collColour,
                            false,
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
                            AppColours().alertsColour,
                            false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Icon(Icons.analytics_outlined,
                            color: AppColours().mainThemeColour),
                        const SizedBox(width: 8),
                        Text(
                          'Fill Level Distribution',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColours().mainTextColour,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LineChartCard(
                      selectionColor: AppColours().filledBinsColour,
                      isDesktop: true,
                      greyColor: AppColours().mainGreyColour,
                      title: 'Filled Bins',
                      isFilled: true,
                    ),
                    const SizedBox(height: 30),
                    LineChartCard(
                      selectionColor: AppColours().emptyBinsColour,
                      isDesktop: true,
                      greyColor: AppColours().mainGreyColour,
                      title: 'Empty Bins',
                      isFilled: false,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusItem(String title, String description, IconData icon,
      Color color, bool isCollect) {
    return Row(
      children: [
        Icon(icon, color: color, size: isCollect ? 23 : 21),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: isCollect ? 16 : 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: isCollect ? 14 : 13,
                  color: AppColours().textColour2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
