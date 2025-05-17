import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:swms_administration/constants/colours.dart';
import 'package:swms_administration/models/bin_model.dart';
import 'package:swms_administration/utils/responsive.dart';
import 'package:url_launcher/url_launcher.dart';

class BinDetailsPage extends StatefulWidget {
  final Bin bin;
  const BinDetailsPage({
    super.key,
    required this.bin,
  });

  @override
  State<BinDetailsPage> createState() => _BinDetailsPageState();
}

class _BinDetailsPageState extends State<BinDetailsPage> {
  int counter = 0;
  LatLng? _currentLocation;
  String status = "Idle";
  late Bin _bin;
  StreamSubscription<DocumentSnapshot>? _binSubscription;
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
    _mapController.move(
      LatLng(
        _bin.latitude,
        _bin.longitude,
      ),
      17,
    );
  }

  void _myLocation() {
    if (_currentLocation != null) {
      _mapController.move(
        LatLng(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
        ),
        17,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _bin = widget.bin;
    _setupBinListener();
    _getCurrentLocation();
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
            content: Text('Location permissions are denied'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
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

  void _setupBinListener() {
    _binSubscription = FirebaseFirestore.instance
        .collection('Dustbins')
        .doc(widget.bin.id)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _bin = Bin.fromFirestore(snapshot);
        });
      }
    });
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
                        if (kIsWeb)
                          Marker(
                            point: LatLng(
                              _bin.latitude,
                              _bin.longitude,
                            ),
                            child: Icon(
                              Icons.location_on,
                              size: 40,
                              color: AppColours().mainThemeColour,
                            ),
                          ),
                        if (!kIsWeb)
                          Marker(
                            point: LatLng(
                              _bin.latitude,
                              _bin.longitude,
                            ),
                            width: MediaQuery.of(context).size.height * 0.045,
                            height: MediaQuery.of(context).size.height * 0.074,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.height *
                                      0.005,
                                ),
                                Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/Map Marker.png',
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.04,
                                      width:
                                          MediaQuery.of(context).size.height *
                                              0.04,
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.034,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
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
                bottom: 15,
                left: 25,
                child: SizedBox(
                  height: 56,
                  width: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Tooltip(
                          message: 'View in Google Maps',
                          child: GestureDetector(
                            onTap: () async {
                              await _launchUrl(
                                  'https://www.google.com/maps?q=${_bin.latitude},${_bin.longitude}&z=17');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 2),
                              height: 40,
                              width: 200,
                              decoration: BoxDecoration(
                                color: AppColours().googleColour1,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColours().googleColour2),
                              ),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.map,
                                        color: AppColours().googleColour3),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      'View in Google Maps',
                                      style: TextStyle(
                                        color: AppColours().googleColour3,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                        onPressed: _myLocation,
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
                      onPressed: _initialLocation,
                      tooltip: 'Locate Bin',
                      heroTag: 'binLocate',
                      child: Icon(
                        FontAwesomeIcons.solidTrashCan,
                        color: AppColours().mainWhiteColour,
                        size: 24,
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
                    SizedBox(
                      height: 8,
                    ),
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

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $uri';
    }
  }

  @override
  void dispose() {
    // Set _bin.isManual to false in Firestore
    FirebaseFirestore.instance
        .collection('Dustbins')
        .doc(_bin.id)
        .update({'isManual': false}).catchError((error) {
      print('Failed to automate the bin: $error');
    });

    _binSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    void changeLidState(bool isControllerOnClosed) {
      setState(() {
        FirebaseFirestore.instance.collection('Dustbins').doc(_bin.id).update(
            {'isControllerOnClosed': isControllerOnClosed}).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update lid state: $error'),
              backgroundColor: AppColours().errorColour,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        });
      });
    }

    void changeLidControlState(bool isManual) {
      setState(() {
        FirebaseFirestore.instance
            .collection('Dustbins')
            .doc(_bin.id)
            .update({'isManual': isManual}).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update lid control state: $error'),
              backgroundColor: AppColours().errorColour,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        });
      });
    }

    return isDesktop
        ? Scaffold(
            backgroundColor: AppColours().scaffoldColour,
            appBar: AppBar(
              backgroundColor: AppColours().scaffoldColour,
              elevation: 0.5,
              toolbarHeight: 80, // Taller for desktop
              title: Padding(
                padding: const EdgeInsets.only(left: 40.0), // Wider left margin
                child: Text(
                  _bin.name,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 26, // Slightly larger for desktop
                      fontWeight: FontWeight.w600,
                      color: AppColours().contColour4,
                      letterSpacing: 0.5, // Improved readability
                    ),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0), // Symmetrical wide margin
                  child: _bin.mainBin == ''
                      ? Container(
                          width:
                              width * 0.12, // Proportionally smaller on desktop
                          height: 36, // Fixed height for consistency
                          decoration: BoxDecoration(
                            color: AppColours().mainWhiteColour,
                            borderRadius:
                                BorderRadius.circular(20), // Slightly rounded
                            border: Border.all(
                              color: AppColours()
                                  .mainGreyColour
                                  .withOpacity(0.15), // More subtle border
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColours()
                                    .mainBlackColour
                                    .withOpacity(0.03), // Lighter shadow
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0), // Horizontal padding
                              child: AutoSizeText(
                                _bin.type,
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColours().dustbinCardColour1,
                                  ),
                                ),
                                maxLines: 1,
                                minFontSize: 10,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width:
                              width * 0.18, // Proportionally smaller on desktop
                          height: 36, // Fixed height for consistency
                          decoration: BoxDecoration(
                            color: AppColours().mainWhiteColour,
                            borderRadius:
                                BorderRadius.circular(20), // Slightly rounded
                            border: Border.all(
                              color: AppColours()
                                  .mainGreyColour
                                  .withOpacity(0.15), // More subtle border
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColours()
                                    .mainBlackColour
                                    .withOpacity(0.03), // Lighter shadow
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0), // Horizontal padding
                              child: AutoSizeText(
                                '${_bin.type} of ${_bin.mainBin}',
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColours().dustbinCardColour1,
                                  ),
                                ),
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                minFontSize: 10,
                              ),
                            ),
                          ),
                        ),
                )
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 20,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.insights,
                                      color: AppColours().mainThemeColour),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Bin Details',
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
                                crossAxisCount: 2,
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 24,
                                childAspectRatio: 1.5,
                                children: [
                                  _buildStatCard(
                                    'Fill Status',
                                    '${_bin.fillLevel.toStringAsFixed(0)} L/${_bin.capacity.toStringAsFixed(0)} L',
                                    _bin.fillStatus ? 'Filled' : 'Available',
                                    _bin.fillStatus
                                        ? AppColours().closedColour
                                        : AppColours().wellColour,
                                    FontAwesomeIcons.solidTrashCan,
                                  ),
                                  _buildStatCard(
                                    'Lid State',
                                    _bin.isClosed ? 'Closed' : 'Open',
                                    '',
                                    _bin.isClosed
                                        ? AppColours().closedColour
                                        : AppColours().wellColour,
                                    _bin.isClosed
                                        ? Icons.lock_outline
                                        : FontAwesomeIcons.lockOpen,
                                  ),
                                  _buildStatCard(
                                    'Gas Level',
                                    '${_bin.gasLevel.toStringAsFixed(0)} ppm',
                                    _bin.gasLevel > 649
                                        ? 'Attention Needed!'
                                        : _bin.gasLevel < 650 &&
                                                _bin.gasLevel > 399
                                            ? 'Bad Smell'
                                            : _bin.gasLevel < 400 &&
                                                    _bin.gasLevel > 199
                                                ? 'Fine Smell'
                                                : 'Smells Good',
                                    _bin.gasLevel > 649
                                        ? AppColours().gasColour1
                                        : _bin.gasLevel < 650 &&
                                                _bin.gasLevel > 399
                                            ? AppColours().closedColour
                                            : _bin.gasLevel < 400 &&
                                                    _bin.gasLevel > 199
                                                ? AppColours().fineColour
                                                : AppColours().wellColour,
                                    Icons.air,
                                  ),
                                  _buildStatCard(
                                    'Precipitation',
                                    '${_bin.precipitation.toStringAsFixed(0)} %',
                                    _bin.precipitation > 70
                                        ? 'Heavy Rain'
                                        : _bin.precipitation < 71 &&
                                                _bin.precipitation > 30
                                            ? 'Moderate Rain'
                                            : _bin.precipitation < 31 &&
                                                    _bin.precipitation > 2
                                                ? 'Drizzle'
                                                : _bin.precipitation < 3 &&
                                                        _bin.precipitation > 0
                                                    ? 'Dew'
                                                    : 'No Rain',
                                    _bin.precipitation > 70
                                        ? AppColours().closedColour
                                        : _bin.precipitation < 71 &&
                                                _bin.precipitation > 30
                                            ? AppColours().alertsColour
                                            : _bin.precipitation < 31 &&
                                                    _bin.precipitation > 2
                                                ? AppColours().collColour
                                                : _bin.precipitation < 3 &&
                                                        _bin.precipitation > 0
                                                    ? AppColours().googleColour2
                                                    : AppColours().contColour3,
                                    _bin.precipitation > 70
                                        ? FontAwesomeIcons.cloudShowersWater
                                        : _bin.precipitation < 71 &&
                                                _bin.precipitation > 30
                                            ? FontAwesomeIcons.cloudShowersHeavy
                                            : _bin.precipitation < 31 &&
                                                    _bin.precipitation > 2
                                                ? FontAwesomeIcons.cloudRain
                                                : _bin.precipitation < 3 &&
                                                        _bin.precipitation > 0
                                                    ? Icons.water_drop
                                                    : Icons.cloud_off_outlined,
                                  ),
                                  _buildStatCard(
                                    'Temperature',
                                    '${_bin.temperature} °C',
                                    '',
                                    AppColours().temperatureColour,
                                    _bin.temperature > 34
                                        ? FontAwesomeIcons.temperatureHigh
                                        : _bin.temperature > 20 &&
                                                _bin.temperature < 35
                                            ? FontAwesomeIcons.temperatureHalf
                                            : _bin.temperature < 20 &&
                                                    _bin.temperature > 3
                                                ? FontAwesomeIcons
                                                    .temperatureLow
                                                : _bin.temperature < 4
                                                    ? FontAwesomeIcons.snowflake
                                                    : Icons.thermostat,
                                  ),
                                  _buildStatCard(
                                    'Humidity',
                                    '${_bin.humidity} %',
                                    '',
                                    AppColours().humidityColour,
                                    Icons.water,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Spacer(
                          flex: 1,
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 20,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      color: AppColours().mainThemeColour),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Location',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: AppColours().mainTextColour,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColours().mainWhiteColour,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColours()
                                          .mainBlackColour
                                          .withOpacity(0.1),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: FlutterMap(
                                        mapController: _mapController,
                                        options: MapOptions(
                                          maxZoom: 21,
                                          minZoom: 1,
                                          initialZoom: 17,
                                          initialCenter: LatLng(
                                            _bin.latitude,
                                            _bin.longitude,
                                          ),
                                          interactionOptions:
                                              InteractionOptions(
                                            flags: InteractiveFlag.all,
                                          ),
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
                                                            BorderRadius
                                                                .circular(100),
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
                                                                .myLocationColour2
                                                                .withOpacity(
                                                                    0.5),
                                                            blurRadius: 20,
                                                            spreadRadius: 20,
                                                          ),
                                                        ]),
                                                  ),
                                                ),
                                              Marker(
                                                point: LatLng(
                                                  _bin.latitude,
                                                  _bin.longitude,
                                                ),
                                                child: Icon(
                                                  Icons.location_on,
                                                  size: 40,
                                                  color: AppColours()
                                                      .mainThemeColour,
                                                ),
                                              ),
                                            ],
                                          )
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
                                      bottom: 60,
                                      child: Column(
                                        children: [
                                          if (_currentLocation != null)
                                            FloatingActionButton(
                                              backgroundColor:
                                                  AppColours().mainThemeColour,
                                              onPressed: _myLocation,
                                              tooltip: 'My Location',
                                              heroTag: 'meLocate',
                                              mini: true,
                                              child: Icon(
                                                Icons.my_location_outlined,
                                                color: AppColours()
                                                    .mainWhiteColour,
                                              ),
                                            ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          FloatingActionButton(
                                            backgroundColor:
                                                AppColours().mainThemeColour,
                                            onPressed: _initialLocation,
                                            tooltip: 'Locate Bin',
                                            heroTag: 'binLocate',
                                            mini: true,
                                            child: Icon(
                                              FontAwesomeIcons.solidTrashCan,
                                              color:
                                                  AppColours().mainWhiteColour,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 8,
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
                                              color:
                                                  AppColours().mainWhiteColour,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          FloatingActionButton(
                                            backgroundColor:
                                                AppColours().mainThemeColour,
                                            heroTag: 'zoomOut',
                                            tooltip: 'Zoom Out',
                                            mini: true,
                                            onPressed: _zoomOut,
                                            child: Icon(
                                              Icons.remove,
                                              color:
                                                  AppColours().mainWhiteColour,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PositionedDirectional(
                                      start: 100,
                                      bottom: 20,
                                      end: 20,
                                      child: Row(
                                        children: [
                                          Spacer(
                                            flex: 4,
                                          ),
                                          Flexible(
                                            fit: FlexFit.tight,
                                            flex: 3,
                                            child: GestureDetector(
                                              onTap: () async {
                                                await _launchUrl(
                                                    'https://www.google.com/maps?q=${_bin.latitude},${_bin.longitude}&z=17');
                                              },
                                              child: Tooltip(
                                                message: 'View in Google Maps',
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.35,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.04,
                                                  decoration: BoxDecoration(
                                                    color: AppColours()
                                                        .googleColour4,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                      color: AppColours()
                                                          .googleColour5,
                                                      width: 1.2,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Flexible(
                                                          fit: FlexFit.tight,
                                                          flex: 2,
                                                          child: Icon(
                                                            Icons
                                                                .my_location_outlined,
                                                            size: 20,
                                                            color: AppColours()
                                                                .mainBlackColour
                                                                .withOpacity(
                                                                    0.7),
                                                          ),
                                                        ),
                                                        Flexible(
                                                          fit: FlexFit.tight,
                                                          flex: 6,
                                                          child: Text(
                                                            'View Location',
                                                            style: GoogleFonts
                                                                .poppins(
                                                              textStyle:
                                                                  TextStyle(
                                                                color: AppColours()
                                                                    .mainBlackColour
                                                                    .withOpacity(
                                                                        0.7),
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8.0, bottom: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _bin.isManual
                                        ? Container(
                                            height: height * 0.125,
                                            width: width * 0.236,
                                            decoration: BoxDecoration(
                                              color:
                                                  AppColours().mainWhiteColour,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: AppColours()
                                                    .mainGreyColour
                                                    .withOpacity(0.2),
                                                width: 1.0,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColours()
                                                      .mainBlackColour
                                                      .withOpacity(0.05),
                                                  blurRadius: 8,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Flexible(
                                                    fit: FlexFit.tight,
                                                    flex: 1,
                                                    child: AutoSizeText(
                                                      _bin.isControllerOnClosed
                                                          ? 'Closed'
                                                          : 'Open',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        textStyle: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: _bin
                                                                  .isControllerOnClosed
                                                              ? AppColours()
                                                                  .closedColour
                                                              : AppColours()
                                                                  .openColour,
                                                        ),
                                                      ),
                                                      maxLines: 1,
                                                      minFontSize: 10,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Flexible(
                                                    fit: FlexFit.tight,
                                                    flex: 1,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Flexible(
                                                          fit: FlexFit.tight,
                                                          flex: 5,
                                                          child: FlutterSwitch(
                                                            activeSwitchBorder:
                                                                Border.all(
                                                              color: AppColours()
                                                                  .openColour
                                                                  .withOpacity(
                                                                      0.3),
                                                              width: 1.0,
                                                            ),
                                                            inactiveSwitchBorder:
                                                                Border.all(
                                                              color: AppColours()
                                                                  .errorColour
                                                                  .withOpacity(
                                                                      0.3),
                                                              width: 1.0,
                                                            ),
                                                            width: width * 0.08,
                                                            height: 36,
                                                            toggleSize: 20,
                                                            value: !_bin
                                                                .isControllerOnClosed,
                                                            onToggle: (value) {
                                                              changeLidState(
                                                                  !value);
                                                            },
                                                            activeColor:
                                                                AppColours()
                                                                    .openColour2
                                                                    .withOpacity(
                                                                        0.2),
                                                            inactiveColor:
                                                                AppColours()
                                                                    .closedColour
                                                                    .withOpacity(
                                                                        0.2),
                                                            activeToggleColor:
                                                                AppColours()
                                                                    .openColour,
                                                            inactiveToggleColor:
                                                                AppColours()
                                                                    .closedColour,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : SizedBox(
                                            height: height * 0.125,
                                            width: width * 0.236,
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  left: 0,
                                                  top: 1,
                                                  bottom: 1,
                                                  child: Container(
                                                    height: height * 0.125,
                                                    width: width * 0.236,
                                                    decoration: BoxDecoration(
                                                      color: AppColours()
                                                          .mainWhiteColour,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                        color: AppColours()
                                                            .mainGreyColour
                                                            .withOpacity(0.2),
                                                        width: 1.0,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: AppColours()
                                                              .mainBlackColour
                                                              .withOpacity(
                                                                  0.05),
                                                          blurRadius: 8,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 12,
                                                                vertical: 5),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Flexible(
                                                              fit:
                                                                  FlexFit.tight,
                                                              flex: 1,
                                                              child:
                                                                  AutoSizeText(
                                                                _bin.isControllerOnClosed
                                                                    ? 'Closed'
                                                                    : 'Open',
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  textStyle:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: _bin
                                                                            .isControllerOnClosed
                                                                        ? AppColours()
                                                                            .closedColour
                                                                        : AppColours()
                                                                            .openColour,
                                                                  ),
                                                                ),
                                                                maxLines: 1,
                                                                minFontSize: 10,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            Flexible(
                                                              fit:
                                                                  FlexFit.tight,
                                                              flex: 1,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Flexible(
                                                                    fit: FlexFit
                                                                        .tight,
                                                                    flex: 5,
                                                                    child:
                                                                        FlutterSwitch(
                                                                      activeSwitchBorder:
                                                                          Border
                                                                              .all(
                                                                        color: AppColours()
                                                                            .openColour
                                                                            .withOpacity(0.3),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      inactiveSwitchBorder:
                                                                          Border
                                                                              .all(
                                                                        color: AppColours()
                                                                            .errorColour
                                                                            .withOpacity(0.3),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      width: width *
                                                                          0.08,
                                                                      height:
                                                                          36,
                                                                      toggleSize:
                                                                          20,
                                                                      value: !_bin
                                                                          .isControllerOnClosed,
                                                                      onToggle:
                                                                          (value) {},
                                                                      activeColor: AppColours()
                                                                          .openColour2
                                                                          .withOpacity(
                                                                              0.2),
                                                                      inactiveColor: AppColours()
                                                                          .errorColour
                                                                          .withOpacity(
                                                                              0.2),
                                                                      activeToggleColor:
                                                                          AppColours()
                                                                              .openColour,
                                                                      inactiveToggleColor:
                                                                          AppColours()
                                                                              .closedColour,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 0,
                                                  top: 1,
                                                  bottom: 1,
                                                  child: Container(
                                                    height: height * 0.08,
                                                    width: width * 0.236,
                                                    decoration: BoxDecoration(
                                                      color: AppColours()
                                                          .mainWhiteColour
                                                          .withOpacity(0.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                        color: AppColours()
                                                            .mainGreyColour
                                                            .withOpacity(0.2),
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                    Stack(
                                      children: [
                                        Positioned(
                                          child: Container(
                                            height: height * 0.125,
                                            width: width * 0.22,
                                            decoration: BoxDecoration(
                                              color:
                                                  AppColours().mainWhiteColour,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: AppColours()
                                                    .mainGreyColour
                                                    .withOpacity(0.2),
                                                width: 1.0,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColours()
                                                      .mainBlackColour
                                                      .withOpacity(0.05),
                                                  blurRadius: 8,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Flexible(
                                                    fit: FlexFit.tight,
                                                    flex: 1,
                                                    child: AutoSizeText(
                                                      _bin.isManual
                                                          ? 'Manual'
                                                          : 'Auto',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        textStyle: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: _bin.isManual
                                                              ? AppColours()
                                                                  .closedColour
                                                              : AppColours()
                                                                  .openColour,
                                                        ),
                                                      ),
                                                      maxLines: 1,
                                                      minFontSize: 10,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Flexible(
                                                    fit: FlexFit.tight,
                                                    flex: 1,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Flexible(
                                                          fit: FlexFit.tight,
                                                          flex: 5,
                                                          child: FlutterSwitch(
                                                            activeSwitchBorder:
                                                                Border.all(
                                                              color: AppColours()
                                                                  .openColour
                                                                  .withOpacity(
                                                                      0.3),
                                                              width: 1.0,
                                                            ),
                                                            inactiveSwitchBorder:
                                                                Border.all(
                                                              color: AppColours()
                                                                  .errorColour
                                                                  .withOpacity(
                                                                      0.3),
                                                              width: 1.0,
                                                            ),
                                                            width: width * 0.08,
                                                            height: 36,
                                                            toggleSize: 20,
                                                            value:
                                                                !_bin.isManual,
                                                            onToggle: (value) {
                                                              changeLidControlState(
                                                                  !value);
                                                            },
                                                            activeColor:
                                                                AppColours()
                                                                    .openColour2
                                                                    .withOpacity(
                                                                        0.2),
                                                            inactiveColor:
                                                                AppColours()
                                                                    .errorColour
                                                                    .withOpacity(
                                                                        0.2),
                                                            activeToggleColor:
                                                                AppColours()
                                                                    .openColour,
                                                            inactiveToggleColor:
                                                                AppColours()
                                                                    .closedColour,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Positioned(
                                        //   left: 0,
                                        //   top: 0,
                                        //   bottom: 0,
                                        //   child: Container(
                                        //     height: height * 0.125,
                                        //     width: width * 0.22,
                                        //     decoration: BoxDecoration(
                                        //       color:
                                        //           Colors.white.withOpacity(0.5),
                                        //       borderRadius:
                                        //           BorderRadius.circular(12),
                                        //       border: Border.all(
                                        //         color: Colors.grey
                                        //             .withOpacity(0.2),
                                        //         width: 1.0,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: height * 0.15,
                                width: double.infinity,
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: AppColours().mainWhiteColour,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColours()
                                        .mainGreyColour
                                        .withOpacity(0.2),
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColours()
                                          .mainBlackColour
                                          .withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _bin.gasLevel > 649
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: AutoSizeText(
                                                'Attention Needed!',
                                                style: GoogleFonts.poppins(
                                                  textStyle: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColours()
                                                        .alertsColour,
                                                  ),
                                                ),
                                                maxLines: 1,
                                                minFontSize: 5,
                                                overflow: TextOverflow.fade,
                                              ),
                                            ),
                                            Flexible(
                                              fit: FlexFit.tight,
                                              flex: 6,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: AutoSizeText(
                                                      'High Gas Level!',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        textStyle: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: AppColours()
                                                              .gasColour1,
                                                        ),
                                                      ),
                                                      maxLines: 1,
                                                      minFontSize: 1,
                                                      overflow:
                                                          TextOverflow.fade,
                                                    ),
                                                  ),
                                                  FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Icon(
                                                      FontAwesomeIcons.wind,
                                                      color: AppColours()
                                                          .gasColour1,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : _bin.precipitation > 30 &&
                                              !_bin.isClosed &&
                                              !_bin.isManual
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: AutoSizeText(
                                                    'Attention Needed!',
                                                    style: GoogleFonts.poppins(
                                                      textStyle: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColours()
                                                            .alertsColour,
                                                      ),
                                                    ),
                                                    maxLines: 1,
                                                    minFontSize: 5,
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                ),
                                                Flexible(
                                                  fit: FlexFit.tight,
                                                  flex: 6,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: AutoSizeText(
                                                          'Dustbin Error!',
                                                          style: GoogleFonts
                                                              .poppins(
                                                            textStyle:
                                                                TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppColours()
                                                                  .errorColour,
                                                            ),
                                                          ),
                                                          maxLines: 1,
                                                          minFontSize: 1,
                                                          overflow:
                                                              TextOverflow.fade,
                                                        ),
                                                      ),
                                                      FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Icon(
                                                          Icons.error_rounded,
                                                          color: AppColours()
                                                              .errorColour,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          : _bin.temperature < 4
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: AutoSizeText(
                                                        'Attention Needed!',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          textStyle: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppColours()
                                                                .alertsColour,
                                                          ),
                                                        ),
                                                        maxLines: 1,
                                                        minFontSize: 5,
                                                        overflow:
                                                            TextOverflow.fade,
                                                      ),
                                                    ),
                                                    Flexible(
                                                      fit: FlexFit.tight,
                                                      flex: 6,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: AutoSizeText(
                                                              'Low Temperature!',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                textStyle:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: AppColours()
                                                                      .temperatureColour,
                                                                ),
                                                              ),
                                                              maxLines: 1,
                                                              minFontSize: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .fade,
                                                            ),
                                                          ),
                                                          FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: Icon(
                                                              FontAwesomeIcons
                                                                  .snowflake,
                                                              color: AppColours()
                                                                  .temperatureColour,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : _bin.temperature > 34
                                                  ? Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: AutoSizeText(
                                                            'Attention Needed!',
                                                            style: GoogleFonts
                                                                .poppins(
                                                              textStyle:
                                                                  TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: AppColours()
                                                                    .alertsColour,
                                                              ),
                                                            ),
                                                            maxLines: 1,
                                                            minFontSize: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .fade,
                                                          ),
                                                        ),
                                                        Flexible(
                                                          fit: FlexFit.tight,
                                                          flex: 6,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              FittedBox(
                                                                fit: BoxFit
                                                                    .scaleDown,
                                                                child:
                                                                    AutoSizeText(
                                                                  'High Temperature!',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                    textStyle:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: AppColours()
                                                                          .temperatureColour,
                                                                    ),
                                                                  ),
                                                                  maxLines: 1,
                                                                  minFontSize:
                                                                      1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .fade,
                                                                ),
                                                              ),
                                                              FittedBox(
                                                                fit: BoxFit
                                                                    .scaleDown,
                                                                child: Icon(
                                                                  Icons
                                                                      .thermostat,
                                                                  color: AppColours()
                                                                      .temperatureColour,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            FittedBox(
                                                              fit: BoxFit.fill,
                                                              child:
                                                                  AutoSizeText(
                                                                'Dustbin Operational!',
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  textStyle:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: AppColours()
                                                                        .wellColour,
                                                                  ),
                                                                ),
                                                                maxLines: 1,
                                                                minFontSize: 5,
                                                                overflow:
                                                                    TextOverflow
                                                                        .fade,
                                                              ),
                                                            ),
                                                            Spacer(
                                                              flex: 1,
                                                            ),
                                                            FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              child:
                                                                  AutoSizeText(
                                                                'All systems running smoothly!',
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  textStyle:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: AppColours()
                                                                        .textColour2,
                                                                  ),
                                                                ),
                                                                maxLines: 2,
                                                                minFontSize: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .fade,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        : Scaffold(
            backgroundColor: AppColours().scaffoldColour,
            appBar: AppBar(
              backgroundColor: AppColours().scaffoldColour,
              elevation: 0.5, // Subtle shadow
              title: Text(
                _bin.name,
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 22, // Slightly smaller for elegance
                    fontWeight: FontWeight.w600, // Semi-bold instead of bold
                    color: AppColours()
                        .contColour4, // Darker gray for better readability
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(
                      right: 16.0), // More balanced right padding
                  child: Container(
                    width: width * 0.22,
                    height: width * 0.06,
                    decoration: BoxDecoration(
                      color: AppColours()
                          .mainWhiteColour, // Clean white background
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: AppColours()
                            .mainGreyColour
                            .withOpacity(0.2), // Lighter border
                        width: 1, // Thinner border
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColours().mainBlackColour.withOpacity(0.05),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AutoSizeText(
                        _bin.type,
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 14, // Slightly smaller
                            fontWeight: FontWeight.w500,
                            color: AppColours()
                                .dustbinCardColour1, // Medium gray for subtlety
                          ),
                        ),
                        maxLines: 1,
                        minFontSize: 10,
                      ),
                    ),
                  ),
                )
              ],
            ),
            body: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      height: height * 1.1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 34,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatCardMobile(
                                  context,
                                  'Fill Status',
                                  '${_bin.fillLevel.toStringAsFixed(0)} L/${_bin.capacity.toStringAsFixed(0)} L',
                                  _bin.fillStatus ? 'Filled' : 'Available',
                                  _bin.fillStatus
                                      ? AppColours().closedColour
                                      : AppColours().wellColour,
                                  _bin.fillStatus
                                      ? FontAwesomeIcons.solidTrashCan
                                      : FontAwesomeIcons.trashCan,
                                ),
                                _buildStatCardMobile(
                                  context,
                                  'Lid State',
                                  _bin.isClosed ? 'Closed' : 'Open',
                                  '',
                                  _bin.isClosed
                                      ? AppColours().closedColour
                                      : AppColours().wellColour,
                                  _bin.isClosed
                                      ? Icons.lock_outline
                                      : FontAwesomeIcons.lockOpen,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 34,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatCardMobile(
                                  context,
                                  'Gas Level',
                                  '${_bin.gasLevel.toStringAsFixed(0)} ppm',
                                  _bin.gasLevel > 649
                                      ? 'Attention Needed!'
                                      : _bin.gasLevel < 650 &&
                                              _bin.gasLevel > 399
                                          ? 'Bad Smell'
                                          : _bin.gasLevel < 400 &&
                                                  _bin.gasLevel > 199
                                              ? 'Fine Smell'
                                              : 'Smells Good',
                                  _bin.gasLevel > 649
                                      ? AppColours().gasColour1
                                      : _bin.gasLevel < 650 &&
                                              _bin.gasLevel > 399
                                          ? AppColours().closedColour
                                          : _bin.gasLevel < 400 &&
                                                  _bin.gasLevel > 199
                                              ? AppColours().fineColour
                                              : AppColours().wellColour,
                                  FontAwesomeIcons.wind,
                                ),
                                Spacer(
                                  flex: 1,
                                ),
                                _buildStatCardMobile(
                                  context,
                                  'Precipitation',
                                  '${_bin.precipitation.toStringAsFixed(0)} %',
                                  _bin.precipitation > 70
                                      ? 'Heavy Rain'
                                      : _bin.precipitation < 71 &&
                                              _bin.precipitation > 30
                                          ? 'Moderate Rain'
                                          : _bin.precipitation < 31 &&
                                                  _bin.precipitation > 2
                                              ? 'Drizzle'
                                              : _bin.precipitation < 3 &&
                                                      _bin.precipitation > 0
                                                  ? 'Dew'
                                                  : 'No Rain',
                                  _bin.precipitation > 70
                                      ? AppColours().closedColour
                                      : _bin.precipitation < 71 &&
                                              _bin.precipitation > 30
                                          ? AppColours().alertsColour
                                          : _bin.precipitation < 31 &&
                                                  _bin.precipitation > 2
                                              ? AppColours().collColour
                                              : _bin.precipitation < 3 &&
                                                      _bin.precipitation > 0
                                                  ? AppColours().googleColour2
                                                  : AppColours().contColour3,
                                  _bin.precipitation > 70
                                      ? FontAwesomeIcons.cloudShowersWater
                                      : _bin.precipitation < 71 &&
                                              _bin.precipitation > 30
                                          ? FontAwesomeIcons.cloudShowersHeavy
                                          : _bin.precipitation < 31 &&
                                                  _bin.precipitation > 2
                                              ? FontAwesomeIcons.cloudRain
                                              : _bin.precipitation < 3 &&
                                                      _bin.precipitation > 0
                                                  ? Icons.water_drop
                                                  : Icons.cloud_off_outlined,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 34,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatCardMobile(
                                  context,
                                  'Temperature',
                                  '${_bin.temperature} °C',
                                  '',
                                  AppColours().temperatureColour,
                                  _bin.temperature > 34
                                      ? FontAwesomeIcons.temperatureHigh
                                      : _bin.temperature > 20 &&
                                              _bin.temperature < 35
                                          ? FontAwesomeIcons.temperatureHalf
                                          : _bin.temperature < 20 &&
                                                  _bin.temperature > 3
                                              ? FontAwesomeIcons.temperatureLow
                                              : _bin.temperature < 4
                                                  ? FontAwesomeIcons.snowflake
                                                  : Icons.thermostat,
                                ),
                                _buildStatCardMobile(
                                  context,
                                  'Humidity',
                                  '${_bin.humidity} %',
                                  '',
                                  AppColours().humidityColour,
                                  FontAwesomeIcons.water,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 17,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _bin.isManual
                                      ? Container(
                                          height: height * 0.08,
                                          width: width * 0.44,
                                          decoration: BoxDecoration(
                                            color: AppColours().mainWhiteColour,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: AppColours()
                                                  .mainGreyColour
                                                  .withOpacity(0.2),
                                              width: 1.0,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColours()
                                                    .mainBlackColour
                                                    .withOpacity(0.05),
                                                blurRadius: 8,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Flexible(
                                                  fit: FlexFit.tight,
                                                  flex: 1,
                                                  child: AutoSizeText(
                                                    _bin.isControllerOnClosed
                                                        ? 'Closed'
                                                        : 'Open',
                                                    style: GoogleFonts.poppins(
                                                      textStyle: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: _bin
                                                                .isControllerOnClosed
                                                            ? AppColours()
                                                                .closedColour
                                                            : AppColours()
                                                                .openColour,
                                                      ),
                                                    ),
                                                    maxLines: 1,
                                                    minFontSize: 10,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Flexible(
                                                  fit: FlexFit.tight,
                                                  flex: 1,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Flexible(
                                                        fit: FlexFit.tight,
                                                        flex: 5,
                                                        child: FlutterSwitch(
                                                          activeSwitchBorder:
                                                              Border.all(
                                                            color: AppColours()
                                                                .openColour
                                                                .withOpacity(
                                                                    0.3),
                                                            width: 1.0,
                                                          ),
                                                          inactiveSwitchBorder:
                                                              Border.all(
                                                            color: AppColours()
                                                                .errorColour
                                                                .withOpacity(
                                                                    0.3),
                                                            width: 1.0,
                                                          ),
                                                          width: width * 0.14,
                                                          height:
                                                              height * 0.035,
                                                          toggleSize: 20,
                                                          value: !_bin
                                                              .isControllerOnClosed,
                                                          onToggle: (value) {
                                                            changeLidState(
                                                                !value);
                                                          },
                                                          activeColor:
                                                              AppColours()
                                                                  .openColour2
                                                                  .withOpacity(
                                                                      0.2),
                                                          inactiveColor:
                                                              AppColours()
                                                                  .errorColour
                                                                  .withOpacity(
                                                                      0.2),
                                                          activeToggleColor:
                                                              AppColours()
                                                                  .openColour,
                                                          inactiveToggleColor:
                                                              AppColours()
                                                                  .closedColour,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : SizedBox(
                                          height: height * 0.08,
                                          width: width * 0.44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 1,
                                                bottom: 1,
                                                child: Container(
                                                  height: height * 0.08,
                                                  width: width * 0.44,
                                                  decoration: BoxDecoration(
                                                    color: AppColours()
                                                        .mainWhiteColour,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                      color: AppColours()
                                                          .mainGreyColour
                                                          .withOpacity(0.2),
                                                      width: 1.0,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: AppColours()
                                                            .mainBlackColour
                                                            .withOpacity(0.05),
                                                        blurRadius: 8,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12,
                                                          vertical: 5),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Flexible(
                                                            fit: FlexFit.tight,
                                                            flex: 1,
                                                            child: AutoSizeText(
                                                              _bin.isControllerOnClosed
                                                                  ? 'Closed'
                                                                  : 'Open',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                textStyle:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: _bin
                                                                          .isControllerOnClosed
                                                                      ? AppColours()
                                                                          .closedColour
                                                                      : AppColours()
                                                                          .openColour,
                                                                ),
                                                              ),
                                                              maxLines: 1,
                                                              minFontSize: 10,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          Flexible(
                                                            fit: FlexFit.tight,
                                                            flex: 1,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Flexible(
                                                                  fit: FlexFit
                                                                      .tight,
                                                                  flex: 5,
                                                                  child:
                                                                      FlutterSwitch(
                                                                    activeSwitchBorder:
                                                                        Border
                                                                            .all(
                                                                      color: AppColours()
                                                                          .openColour
                                                                          .withOpacity(
                                                                              0.3),
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    inactiveSwitchBorder:
                                                                        Border
                                                                            .all(
                                                                      color: AppColours()
                                                                          .errorColour
                                                                          .withOpacity(
                                                                              0.3),
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    width:
                                                                        width *
                                                                            0.14,
                                                                    height:
                                                                        height *
                                                                            0.035,
                                                                    toggleSize:
                                                                        20,
                                                                    value: !_bin
                                                                        .isControllerOnClosed,
                                                                    onToggle:
                                                                        (value) {},
                                                                    activeColor: AppColours()
                                                                        .openColour2
                                                                        .withOpacity(
                                                                            0.2),
                                                                    inactiveColor: AppColours()
                                                                        .errorColour
                                                                        .withOpacity(
                                                                            0.2),
                                                                    activeToggleColor:
                                                                        AppColours()
                                                                            .openColour,
                                                                    inactiveToggleColor:
                                                                        AppColours()
                                                                            .closedColour,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 0,
                                                top: 1,
                                                bottom: 1,
                                                child: Container(
                                                  height: height * 0.08,
                                                  width: width * 0.44,
                                                  decoration: BoxDecoration(
                                                    color: AppColours()
                                                        .mainWhiteColour
                                                        .withOpacity(0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                      color: AppColours()
                                                          .mainGreyColour
                                                          .withOpacity(0.2),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                  Stack(
                                    children: [
                                      Container(
                                        height: height * 0.08,
                                        width: width * 0.44,
                                        decoration: BoxDecoration(
                                          color: AppColours().mainWhiteColour,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColours()
                                                .mainGreyColour
                                                .withOpacity(0.2),
                                            width: 1.0,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColours()
                                                  .mainBlackColour
                                                  .withOpacity(0.05),
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 5),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                fit: FlexFit.tight,
                                                flex: 1,
                                                child: AutoSizeText(
                                                  _bin.isManual
                                                      ? 'Manual'
                                                      : 'Auto',
                                                  style: GoogleFonts.poppins(
                                                    textStyle: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: _bin.isManual
                                                          ? AppColours()
                                                              .closedColour
                                                          : AppColours()
                                                              .openColour,
                                                    ),
                                                  ),
                                                  maxLines: 1,
                                                  minFontSize: 10,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Flexible(
                                                fit: FlexFit.tight,
                                                flex: 1,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Flexible(
                                                      fit: FlexFit.tight,
                                                      flex: 5,
                                                      child: FlutterSwitch(
                                                        activeSwitchBorder:
                                                            Border.all(
                                                          color: AppColours()
                                                              .openColour
                                                              .withOpacity(0.3),
                                                          width: 1.0,
                                                        ),
                                                        inactiveSwitchBorder:
                                                            Border.all(
                                                          color: AppColours()
                                                              .errorColour
                                                              .withOpacity(0.3),
                                                          width: 1.0,
                                                        ),
                                                        width: width * 0.14,
                                                        height: height * 0.035,
                                                        toggleSize: 20,
                                                        value: !_bin.isManual,
                                                        onToggle: (value) {
                                                          changeLidControlState(
                                                              !value);
                                                        },
                                                        activeColor:
                                                            AppColours()
                                                                .openColour2
                                                                .withOpacity(
                                                                    0.2),
                                                        inactiveColor:
                                                            AppColours()
                                                                .errorColour
                                                                .withOpacity(
                                                                    0.2),
                                                        activeToggleColor:
                                                            AppColours()
                                                                .openColour,
                                                        inactiveToggleColor:
                                                            AppColours()
                                                                .closedColour,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Positioned(
                                      //   left: 0,
                                      //   top: 0,
                                      //   bottom: 0,
                                      //   child: Container(
                                      //     height: height * 0.08,
                                      //     width: width * 0.44,
                                      //     decoration: BoxDecoration(
                                      //       color:
                                      //           Colors.white.withOpacity(0.5),
                                      //       borderRadius:
                                      //           BorderRadius.circular(12),
                                      //       border: Border.all(
                                      //         color:
                                      //             Colors.grey.withOpacity(0.2),
                                      //         width: 1.0,
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _bin.isSub && !(_bin.mainBin == '')
                              ? Flexible(
                                  fit: FlexFit.tight,
                                  flex: 6,
                                  child: AutoSizeText(
                                    'Root Bin - ${_bin.mainBin}',
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: AppColours().contColour5,
                                      ),
                                    ),
                                    maxLines: 1,
                                    minFontSize: 10,
                                  ),
                                )
                              : const SizedBox(),
                          _bin.isSub
                              ? const SizedBox(height: 16)
                              : const SizedBox(),
                          SizedBox(width: 12),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 20,
                            child: Container(
                              height: height * 0.08,
                              width: width,
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: AppColours().mainWhiteColour,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColours()
                                      .mainGreyColour
                                      .withOpacity(0.2),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColours()
                                        .mainBlackColour
                                        .withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _bin.gasLevel > 649
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: AutoSizeText(
                                              'Attention Needed!',
                                              style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      AppColours().alertsColour,
                                                ),
                                              ),
                                              maxLines: 1,
                                              minFontSize: 5,
                                              overflow: TextOverflow.fade,
                                            ),
                                          ),
                                          Flexible(
                                            fit: FlexFit.tight,
                                            flex: 6,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: AutoSizeText(
                                                    'High Gas Level!',
                                                    style: GoogleFonts.poppins(
                                                      textStyle: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColours()
                                                            .gasColour1,
                                                      ),
                                                    ),
                                                    maxLines: 1,
                                                    minFontSize: 1,
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                ),
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Icon(
                                                    FontAwesomeIcons.wind,
                                                    color:
                                                        AppColours().gasColour1,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : _bin.precipitation > 30 &&
                                            !_bin.isClosed &&
                                            !_bin.isManual
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: AutoSizeText(
                                                  'Attention Needed!',
                                                  style: GoogleFonts.poppins(
                                                    textStyle: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColours()
                                                          .alertsColour,
                                                    ),
                                                  ),
                                                  maxLines: 1,
                                                  minFontSize: 5,
                                                  overflow: TextOverflow.fade,
                                                ),
                                              ),
                                              Flexible(
                                                fit: FlexFit.tight,
                                                flex: 6,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: AutoSizeText(
                                                        'Dustbin Error!',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          textStyle: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppColours()
                                                                .errorColour,
                                                          ),
                                                        ),
                                                        maxLines: 1,
                                                        minFontSize: 1,
                                                        overflow:
                                                            TextOverflow.fade,
                                                      ),
                                                    ),
                                                    FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Icon(
                                                        Icons.error_rounded,
                                                        color: AppColours()
                                                            .errorColour,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        : _bin.temperature < 4
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: AutoSizeText(
                                                      'Attention Needed!',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        textStyle: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: AppColours()
                                                              .alertsColour,
                                                        ),
                                                      ),
                                                      maxLines: 1,
                                                      minFontSize: 5,
                                                      overflow:
                                                          TextOverflow.fade,
                                                    ),
                                                  ),
                                                  Flexible(
                                                    fit: FlexFit.tight,
                                                    flex: 6,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: AutoSizeText(
                                                            'Low Temperature!',
                                                            style: GoogleFonts
                                                                .poppins(
                                                              textStyle:
                                                                  TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: AppColours()
                                                                    .temperatureColour,
                                                              ),
                                                            ),
                                                            maxLines: 1,
                                                            minFontSize: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .fade,
                                                          ),
                                                        ),
                                                        FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Icon(
                                                            FontAwesomeIcons
                                                                .snowflake,
                                                            color: AppColours()
                                                                .temperatureColour,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : _bin.temperature > 34
                                                ? Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: AutoSizeText(
                                                          'Attention Needed!',
                                                          style: GoogleFonts
                                                              .poppins(
                                                            textStyle:
                                                                TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppColours()
                                                                  .alertsColour,
                                                            ),
                                                          ),
                                                          maxLines: 1,
                                                          minFontSize: 1,
                                                          overflow:
                                                              TextOverflow.fade,
                                                        ),
                                                      ),
                                                      Flexible(
                                                        fit: FlexFit.tight,
                                                        flex: 6,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              child:
                                                                  AutoSizeText(
                                                                'High Temperature!',
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  textStyle:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: AppColours()
                                                                        .temperatureColour,
                                                                  ),
                                                                ),
                                                                maxLines: 1,
                                                                minFontSize: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .fade,
                                                              ),
                                                            ),
                                                            FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              child: Icon(
                                                                Icons
                                                                    .thermostat,
                                                                color: AppColours()
                                                                    .temperatureColour,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          FittedBox(
                                                            fit: BoxFit.fill,
                                                            child: AutoSizeText(
                                                              'Dustbin Operational!',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                textStyle:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: AppColours()
                                                                      .wellColour,
                                                                ),
                                                              ),
                                                              maxLines: 1,
                                                              minFontSize: 5,
                                                              overflow:
                                                                  TextOverflow
                                                                      .fade,
                                                            ),
                                                          ),
                                                          Spacer(
                                                            flex: 1,
                                                          ),
                                                          FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: AutoSizeText(
                                                              'All systems running smoothly!',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                textStyle:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: AppColours()
                                                                      .textColour2,
                                                                ),
                                                              ),
                                                              maxLines: 2,
                                                              minFontSize: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .fade,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 6,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_pin,
                                  size: 26,
                                  color: AppColours().mainThemeColour,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                AutoSizeText(
                                  'Location',
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      color: AppColours().mainBlackColour,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  maxLines: 1,
                                  minFontSize: 12,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Flexible(
                            flex: 70,
                            fit: FlexFit.tight,
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.5,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColours().mainWhiteColour,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColours()
                                      .mainGreyColour
                                      .withOpacity(0.2),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColours()
                                        .mainBlackColour
                                        .withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: GestureDetector(
                                onDoubleTap: () {
                                  _openFullScreenMap(
                                      _mapController.camera.center);
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    children: [
                                      FlutterMap(
                                        mapController: _mapController,
                                        options: MapOptions(
                                          maxZoom: 21,
                                          minZoom: 1,
                                          initialZoom: 17,
                                          initialCenter: LatLng(
                                            _bin.latitude,
                                            _bin.longitude,
                                          ),
                                          interactionOptions:
                                              InteractionOptions(
                                            flags: InteractiveFlag.all,
                                          ),
                                        ),
                                        children: [
                                          ColorFiltered(
                                            colorFilter: ColorFilter.mode(
                                                AppColours()
                                                    .mapFilterColour
                                                    .withOpacity(0.8),
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
                                                            BorderRadius
                                                                .circular(100),
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
                                                                .myLocationColour2
                                                                .withOpacity(
                                                                    0.5),
                                                            blurRadius: 20,
                                                            spreadRadius: 20,
                                                          ),
                                                        ]),
                                                  ),
                                                ),
                                              if (kIsWeb)
                                                Marker(
                                                  point: LatLng(
                                                    _bin.latitude,
                                                    _bin.longitude,
                                                  ),
                                                  child: Icon(
                                                    Icons.location_on,
                                                    size: 40,
                                                    color: AppColours()
                                                        .mainThemeColour,
                                                  ),
                                                ),
                                              if (!kIsWeb)
                                                Marker(
                                                  point: LatLng(
                                                    _bin.latitude,
                                                    _bin.longitude,
                                                  ),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.045,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.074,
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.005,
                                                      ),
                                                      Column(
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/Map Marker.png',
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.04,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.04,
                                                          ),
                                                          SizedBox(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.034,
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          )
                                        ],
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
                                                backgroundColor: AppColours()
                                                    .mainThemeColour,
                                                onPressed: _myLocation,
                                                tooltip: 'My Location',
                                                heroTag: 'meLocate',
                                                mini: true,
                                                child: Icon(
                                                  Icons.my_location_outlined,
                                                  color: AppColours()
                                                      .mainWhiteColour,
                                                ),
                                              ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            FloatingActionButton(
                                              backgroundColor:
                                                  AppColours().mainThemeColour,
                                              onPressed: _initialLocation,
                                              tooltip: 'Locate Bin',
                                              heroTag: 'binLocate',
                                              mini: true,
                                              child: Icon(
                                                FontAwesomeIcons.solidTrashCan,
                                                color: AppColours()
                                                    .mainWhiteColour,
                                                size: 20,
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
                                                color: AppColours()
                                                    .mainWhiteColour,
                                              ),
                                            ),
                                            SizedBox(
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
                                                color: AppColours()
                                                    .mainWhiteColour,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 6,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 3,
                                  child: GestureDetector(
                                    onTap: () async {
                                      await _launchUrl(
                                          'https://www.google.com/maps?q=${_bin.latitude},${_bin.longitude}&z=17');
                                    },
                                    child: Tooltip(
                                      message: 'View in Google Maps',
                                      child: Container(
                                        height: height * 0.06,
                                        decoration: BoxDecoration(
                                          color: AppColours().mainWhiteColour,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColours()
                                                .openColour
                                                .withOpacity(0.3),
                                            width: 1.0,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColours()
                                                  .mainBlackColour
                                                  .withOpacity(0.05),
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.my_location_outlined,
                                                size: 20,
                                                color: AppColours().openColour,
                                              ),
                                              SizedBox(width: 8),
                                              AutoSizeText(
                                                'View Location',
                                                style: GoogleFonts.poppins(
                                                  textStyle: TextStyle(
                                                    color:
                                                        AppColours().openColour,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                maxLines: 1,
                                                minFontSize: 8,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Spacer(
                            flex: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildStatCard(
      String title, String value, String status, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColours().mainBlackColour.withOpacity(0.05),
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
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
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
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: AppColours().contColour5,
                  ),
                ),
                const Spacer(),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildStatCardMobile(BuildContext context, String title, String value,
    String status, Color color, IconData icon) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.44,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppColours().mainBlackColour.withOpacity(0.05),
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
          Flexible(
            fit: FlexFit.tight,
            flex: 12,
            child: AutoSizeText(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              minFontSize: 5,
              overflow: TextOverflow.fade,
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            flex: 12,
            child: AutoSizeText(
              status,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: color,
              ),
              maxLines: 1,
              minFontSize: 1,
              maxFontSize: 16,
              overflow: TextOverflow.fade,
            ),
          ),
          const Spacer(
            flex: 1,
          ),
          Flexible(
            fit: FlexFit.tight,
            flex: 15,
            child: Center(
              child: AutoSizeText(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: AppColours().contColour5,
                ),
                maxLines: 1,
                minFontSize: 10,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
          const Spacer(
            flex: 1,
          ),
          Flexible(
            fit: FlexFit.tight,
            flex: 15,
            child: Row(
              children: [
                const Spacer(),
                Container(
                  height: MediaQuery.of(context).size.height * 0.035,
                  width: MediaQuery.of(context).size.height * 0.035,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: color,
                      size: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColours().textColour2,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
