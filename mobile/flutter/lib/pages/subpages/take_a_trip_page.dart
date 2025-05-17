import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:swms_administration/constants/colours.dart';
import 'package:swms_administration/models/bin_model.dart';
import 'package:swms_administration/utils/responsive.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:swms_administration/constants/text_styles.dart';

class TakeATripPage extends StatefulWidget {
  final List<Bin> stops;
  final String title;
  final Color tripColour;

   TakeATripPage({
    super.key,
    required this.stops,
    required this.title,
    required this.tripColour,
  });

  @override
  State<TakeATripPage> createState() => _TakeATripPageState();
}

class _TakeATripPageState extends State<TakeATripPage> {
  late List<Bin> _currentStops;
  Bin? _startPoint;
  Bin? _endPoint;
  bool _locationsSet = false;

  @override
  void initState() {
    super.initState();
    _currentStops = List.from(widget.stops);
  }

  double _calculateDistance(Bin a, Bin b) {
     double earthRadius = 6371e3;
    final lat1 = a.latitude * pi / 180;
    final lon1 = a.longitude * pi / 180;
    final lat2 = b.latitude * pi / 180;
    final lon2 = b.longitude * pi / 180;

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final aVal = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(aVal), sqrt(1 - aVal));

    return earthRadius * c;
  }

  List<Bin> _optimizeRouteWithStartEnd() {
    final stops =
        _currentStops.where((stop) => stop.id != _startPoint?.id).toList();
    List<Bin> optimized = [];
    if (_startPoint != null) optimized.add(_startPoint!);

    while (stops.isNotEmpty) {
      stops.sort((a, b) => _calculateDistance(optimized.last, a)
          .compareTo(_calculateDistance(optimized.last, b)));
      optimized.add(stops.removeAt(0));
    }

    if (_endPoint != null && _endPoint?.id != optimized.lastOrNull?.id) {
      optimized.add(_endPoint!);
    }

    return optimized;
  }

  Widget _buildDismissBackground() {
    return Container(
      decoration: BoxDecoration(
        color: AppColours().closedColour2,
        borderRadius: BorderRadius.circular(12),
      ),
      margin:  EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
              padding:  EdgeInsets.only(left: 20),
              child: Icon(Icons.delete, color: AppColours().mainWhiteColour)),
          Padding(
              padding:  EdgeInsets.only(right: 20),
              child: Icon(Icons.delete, color: AppColours().mainWhiteColour)),
        ],
      ),
    );
  }

  void _handleDismiss(Bin stop) {
    setState(() {
      _currentStops.removeWhere((bin) => bin.id == stop.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${stop.name} removed'),
        backgroundColor: widget.tripColour,
        behavior: SnackBarBehavior.floating,
        duration:  Duration(
          milliseconds: 200,
        ),
      ),
    );
  }

  Widget _buildBatteryIndicator(Bin stop) {
    final level = stop.fillLevel;
    final capacity = stop.capacity;
    final isDesktop = Responsive.isDesktop(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: isDesktop ? 80 : 60,
          height: isDesktop ? 80 : 60,
          child: CircularProgressIndicator(
            value: level / capacity,
            strokeWidth: isDesktop ? 10 : 5,
            backgroundColor: widget.tripColour.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
                _getFillLevelColor(level, capacity)),
          ),
        ),
        Padding(
          padding:  EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${(level / capacity * 100).toInt()}%',
                style: AppTextStyles().statValueStyle.copyWith(
                    color: _getFillLevelColor(level, capacity), fontSize: 16),
              ),
               SizedBox(height: 4),
              SvgPicture.asset(
                'assets/icons/SVG/fillLevel.svg',
                color: _getFillLevelColor(level, capacity),
                height: 15,
                width: 15,
                semanticsLabel: 'Fill Level',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getFillLevelColor(double fillLevel, double capacity) {
    final double fillPercentage = fillLevel / capacity;
    if (fillPercentage > 0.7499) return AppColours().closedColour2;
    if (fillPercentage > 0.499) return AppColours().takeATrip1;
    if (fillPercentage > 0.2499) return AppColours().takeATrip2;
    return AppColours().takeATrip3;
  }

  Widget _buildGoButton() {
    return ElevatedButton.icon(
      icon:  Icon(Icons.directions, color: AppColours().mainWhiteColour),
      label: Text(
        'START NAVIGATION',
        style: AppTextStyles().buttonTextStyle,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.tripColour,
        padding:  EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: _generateRoute,
    );
  }

  void _generateRoute() async {
    if (_startPoint == null || _endPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Please set start and end points'),
        backgroundColor: widget.tripColour,
        duration:  Duration(milliseconds: 600),
      ));
      return;
    }

    final optimizedStops = _optimizeRouteWithStartEnd();
    final coordinates = optimizedStops
        .map((stop) => '${stop.latitude},${stop.longitude}')
        .join('/');

    final url =
        'https://www.google.com/maps/dir/${Uri.encodeFull(coordinates)}?travelmode=driving&dir_action=navigate';

    if (!await launchUrl(Uri.parse(url))) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Failed to launch navigation',
        ),
        backgroundColor: widget.tripColour,
        duration:  Duration(milliseconds: 600),
      ));
    }
  }

  void _showLocationSetup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSetupFlow(
          currentStops: _currentStops,
          startPoint: _startPoint,
          tripColour: widget.tripColour,
          stops: widget.stops,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _startPoint = result['start'];
        _endPoint = result['end'];
        _locationsSet = true;
      });
    }
  }

  Widget _buildBinCard(Bin stop) {
    final isDesktop = Responsive.isDesktop(context);
    return isDesktop
        ? Padding(
            padding:  EdgeInsets.symmetric(vertical: 8, horizontal: 5),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(16),
              shadowColor: widget.tripColour.withOpacity(0.3),
              child: Dismissible(
                key: Key(stop.id),
                direction: isDesktop
                    ? DismissDirection.none
                    : DismissDirection.horizontal,
                background: _buildDismissBackground(),
                secondaryBackground: _buildDismissBackground(),
                onDismissed: (direction) => _handleDismiss(stop),
                child: Container(
                  padding:  EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColours().mainWhiteColour,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: widget.tripColour.withOpacity(0.1),
                        blurRadius: 8,
                        offset:  Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stop.name,
                                  style: AppTextStyles().cardTitleStyle,
                                ),
                                 SizedBox(height: 8),
                                Text(
                                  '${(stop.fillLevel).toStringAsFixed(0)}L / ${stop.capacity}L',
                                  style: AppTextStyles().cardSubtitleStyle,
                                ),
                                 SizedBox(height: 4),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.13,
                                  child: AutoSizeText(
                                    stop.location,
                                    style: AppTextStyles().bodyTextStyle,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          isDesktop
                              ? FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: IconButton(
                                    onPressed: () {
                                      _handleDismiss(stop);
                                    },
                                    tooltip: 'Remove the collection point',
                                    icon: Padding(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Icon(Icons.delete,
                                          color: AppColours().closedColour2),
                                    ),
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ),
                      Spacer(),
                      _buildBatteryIndicator(stop),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Padding(
            padding:  EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(16),
              shadowColor: widget.tripColour.withOpacity(0.3),
              child: Dismissible(
                key: Key(stop.id),
                direction: isDesktop
                    ? DismissDirection.none
                    : DismissDirection.horizontal,
                background: _buildDismissBackground(),
                secondaryBackground: _buildDismissBackground(),
                onDismissed: (direction) => _handleDismiss(stop),
                child: Container(
                  padding:  EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColours().mainWhiteColour,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: widget.tripColour.withOpacity(0.1),
                        blurRadius: 8,
                        offset:  Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildBatteryIndicator(stop),
                       SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stop.name,
                              style: AppTextStyles().cardTitleStyle,
                            ),
                             SizedBox(height: 8),
                            Text(
                              '${(stop.fillLevel).toStringAsFixed(0)}L / ${stop.capacity}L',
                              style: AppTextStyles().cardSubtitleStyle,
                            ),
                             SizedBox(height: 4),
                            Text(
                              stop.location,
                              style: AppTextStyles().bodyTextStyle,
                            ),
                          ],
                        ),
                      ),
                      isDesktop
                          ? IconButton(
                              onPressed: () {
                                _handleDismiss(stop);
                              },
                              tooltip: 'Remove the collection point',
                              icon: Padding(
                                padding: EdgeInsets.only(left: 20),
                                child:
                                    Icon(Icons.delete, color: AppColours().closedColour2),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColours().mainWhiteColour,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: AppTextStyles().pageTitleStyleMobile.copyWith(
                color: AppColours().mainWhiteColour,
                fontWeight: FontWeight.w100,
              ),
        ),
        backgroundColor: widget.tripColour,
        elevation: 0,
        toolbarHeight: 110,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: widget.tripColour.withOpacity(0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:  EdgeInsets.only(
                left: 22.0,
                top: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select the bins you want to clean. \n${isDesktop ? 'Click on the delete icon' : 'Swipe'} to remove a collection point',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        color: AppColours().mainTextColour.withOpacity(0.3),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  isDesktop
                      ? Padding(
                          padding:  EdgeInsets.only(right: 18.0),
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(widget.tripColour),
                              textStyle: WidgetStatePropertyAll(
                                AppTextStyles().buttonTextStyle.copyWith(
                                    color: AppColours().mainWhiteColour),
                              ),
                            ),
                            onPressed: () {
                              _showLocationSetup();
                            },
                            child: Padding(
                              padding:
                                   EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text(
                                'Next',
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    color: AppColours().mainWhiteColour,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
             SizedBox(height: 10),
            Expanded(
              child: isDesktop
                  ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 4 : 1,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                        childAspectRatio: isDesktop ? 1.1 : 1,
                      ),
                      padding:  EdgeInsets.symmetric(vertical: 16),
                      itemCount: _currentStops.length,
                      itemBuilder: (context, index) =>
                          _buildBinCard(_currentStops[index]),
                    )
                  : ListView.builder(
                      padding:  EdgeInsets.symmetric(vertical: 16),
                      itemCount: _currentStops.length,
                      itemBuilder: (context, index) =>
                          _buildBinCard(_currentStops[index]),
                    ),
            ),
            isDesktop
                ? SizedBox()
                : Container(
                    width: double.infinity,
                    height: 50,
                    padding:  EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColours().mainWhiteColour,
                      borderRadius:  BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.tripColour.withOpacity(0.2),
                          blurRadius: 16,
                          offset:  Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // _buildGoButton(),
                      ],
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: isDesktop
          ? null
          : FloatingActionButton(
              onPressed: _showLocationSetup,
              backgroundColor: widget.tripColour,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              elevation: 100,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Icon(
                  Icons.navigate_next_rounded,
                  color: AppColours().mainWhiteColour,
                  size: 45,
                ),
              ),
            ),
    );
  }
}

class LocationSetupFlow extends StatefulWidget {
  final List<Bin> stops;
  final List<Bin> currentStops;
  final Bin? startPoint;
  final Color tripColour;

   LocationSetupFlow({
    super.key,
    required this.currentStops,
    this.startPoint,
    required this.tripColour,
    required this.stops,
  });

  @override
  State<LocationSetupFlow> createState() => _LocationSetupFlowState();
}

class _LocationSetupFlowState extends State<LocationSetupFlow> {
  late List<Bin> _currentStops;
  late PageController _pageController;
  Bin? _selectedStart;
  Bin? _selectedEnd;
  LatLng? _currentLocation;
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
    _pageController = PageController();
    _selectedStart = widget.startPoint;
    _getCurrentLocation();
    _currentStops = List.from(widget.stops);
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            content: Text('Please enable location services')),
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
              behavior: SnackBarBehavior.floating,
              content: Text('Location permissions are denied')),
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

  bool selectOnMap = true;
  bool isStart = true;
  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    return isDesktop
        ? Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(
                selectOnMap ? MediaQuery.of(context).size.height * 0.30 : 80,
              ),
              child: ClipRRect(
                borderRadius: selectOnMap
                    ? BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      )
                    : BorderRadius.all(Radius.zero),
                child: AppBar(
                  toolbarHeight: selectOnMap
                      ? MediaQuery.of(context).size.height * 0.25
                      : null,
                  backgroundColor: widget.tripColour.withOpacity(0.6),
                  elevation: 100,
                  title: Text(
                    'Set Locations',
                    style: GoogleFonts.poppins(
                      textStyle:  TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColours().mainWhiteColour,
                      ),
                    ),
                  ),
                  leading: IconButton(
                    icon:  Icon(Icons.arrow_back,
                        size: 28, color: AppColours().mainWhiteColour),
                    onPressed: () => Navigator.pop(context),
                  ),
                  bottom: selectOnMap
                      ? PreferredSize(
                          preferredSize: Size.fromHeight(0.2),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(
                              top: 10,
                              right: 20,
                              left: 20,
                              bottom: 30,
                            ),
                            decoration: BoxDecoration(
                              color: widget.tripColour.withOpacity(0.01),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.tripColour.withOpacity(0.2),
                                  blurRadius: 16,
                                  offset:  Offset(0, -4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Start Point',
                                  style: GoogleFonts.poppins(
                                    textStyle:  TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                 SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColours().mainWhiteColour,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding:  EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                  ),
                                  hint: Text(
                                    'Select Start Point',
                                    style: GoogleFonts.poppins(
                                      textStyle:  TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  items: [
                                    if (_currentLocation != null)
                                      DropdownMenuItem(
                                        value: 'current',
                                        child: Row(
                                          children: [
                                             Icon(Icons.my_location,
                                                color: AppColours().goodBinColour),
                                             SizedBox(width: 8),
                                            Text(
                                              'Current Location',
                                              style: GoogleFonts.poppins(
                                                textStyle:  TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (_selectedEnd != null)
                                      DropdownMenuItem(
                                        value: 'end',
                                        child: Row(
                                          children: [
                                             Icon(Icons.my_location,
                                                color: AppColours().mainGreyColour),
                                             SizedBox(width: 8),
                                            Text(
                                              'Same as Destination',
                                              style: GoogleFonts.poppins(
                                                textStyle:  TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ...widget.currentStops
                                        .map((bin) => DropdownMenuItem(
                                              value: bin.id,
                                              child: Row(
                                                children: [
                                                   Icon(Icons.delete,
                                                      color: AppColours().midBinColour),
                                                   SizedBox(width: 8),
                                                  Text(
                                                    bin.name,
                                                    style: GoogleFonts.poppins(
                                                      textStyle:
                                                           TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                    DropdownMenuItem(
                                      value: 'map',
                                      child: Row(
                                        children: [
                                           Icon(Icons.map,
                                              color: AppColours().takeATrip4),
                                           SizedBox(width: 8),
                                          Text(
                                            'Select on Map',
                                            style: GoogleFonts.poppins(
                                              textStyle:  TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value == 'map') {
                                      setState(() {
                                        selectOnMap = true;
                                        isStart = true;
                                      });
                                    } else if (value == 'current') {
                                      _handleCurrentLocationSelect(
                                          isStart: true);
                                    } else if (value == 'end') {
                                      setState(() {
                                        _selectedStart = _selectedEnd;
                                      });
                                    } else {
                                      final selectedBin = widget.currentStops
                                          .firstWhere((bin) => bin.id == value);
                                      setState(() {
                                        _selectedStart = selectedBin;
                                      });
                                    }
                                  },
                                ),
                                 SizedBox(height: 16),
                                Text(
                                  'Destination',
                                  style: GoogleFonts.poppins(
                                    textStyle:  TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                 SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColours().mainWhiteColour,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding:  EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                  ),
                                  hint: Text(
                                    'Select Destination',
                                    style: GoogleFonts.poppins(
                                      textStyle:  TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  items: [
                                    if (_currentLocation != null)
                                      DropdownMenuItem(
                                        value: 'current',
                                        child: Row(
                                          children: [
                                             Icon(Icons.my_location,
                                                color: AppColours().goodBinColour),
                                             SizedBox(width: 8),
                                            Text(
                                              'Current Location',
                                              style: GoogleFonts.poppins(
                                                textStyle:  TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (_selectedStart != null)
                                      DropdownMenuItem(
                                        value: 'start',
                                        child: Row(
                                          children: [
                                             Icon(Icons.my_location,
                                                color: AppColours().mainGreyColour),
                                             SizedBox(width: 8),
                                            Text(
                                              'Same as Start Point',
                                              style: GoogleFonts.poppins(
                                                textStyle:  TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ...widget.currentStops
                                        .map((bin) => DropdownMenuItem(
                                              value: bin.id,
                                              child: Row(
                                                children: [
                                                   Icon(Icons.delete,
                                                      color: AppColours().midBinColour),
                                                   SizedBox(width: 8),
                                                  Text(
                                                    bin.name,
                                                    style: GoogleFonts.poppins(
                                                      textStyle:
                                                           TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                    DropdownMenuItem(
                                      value: 'map',
                                      child: Row(
                                        children: [
                                           Icon(Icons.map,
                                              color: AppColours().takeATrip4),
                                           SizedBox(width: 8),
                                          Text(
                                            'Select on Map',
                                            style: GoogleFonts.poppins(
                                              textStyle:  TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value == 'map') {
                                      setState(() {
                                        selectOnMap = true;
                                        isStart = false;
                                      });
                                    } else if (value == 'current') {
                                      _handleCurrentLocationSelect(
                                          isStart: false);
                                    } else if (value == 'start') {
                                      setState(() {
                                        _selectedEnd = _selectedStart;
                                      });
                                    } else {
                                      final selectedBin = widget.currentStops
                                          .firstWhere((bin) => bin.id == value);
                                      setState(() {
                                        _selectedEnd = selectedBin;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ),
            body: selectOnMap
                ? Stack(
                    children: [
                      _buildMapScreen(isStart: isStart),
                      Positioned(
                        right: 16,
                        top: 50,
                        child: Column(
                          children: [
                            FloatingActionButton(
                              backgroundColor: widget.tripColour,
                              onPressed: _zoomIn,
                              tooltip: 'Zoom In',
                              heroTag: 'zoomIn',
                              child: Icon(
                                Icons.add,
                                color: AppColours().mainWhiteColour,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            FloatingActionButton(
                              backgroundColor: widget.tripColour,
                              heroTag: 'zoomOut',
                              tooltip: 'Zoom Out',
                              onPressed: _zoomOut,
                              child: Icon(
                                Icons.remove,
                                color: AppColours().mainWhiteColour,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            if (_currentLocation != null)
                              FloatingActionButton(
                                backgroundColor: widget.tripColour,
                                onPressed: _myLocation,
                                tooltip: 'My Location',
                                heroTag: 'meLocate',
                                child: Icon(
                                  Icons.my_location_outlined,
                                  color: AppColours().mainWhiteColour,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:  EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buildGoButton(),
                              ],
                            ),
                            // ElevatedButton(
                            //   onPressed: () {
                            //     if (_selectedStart != null && _selectedEnd != null) {
                            //       Navigator.pop(
                            //         context,
                            //         {'start': _selectedStart, 'end': _selectedEnd},
                            //       );
                            //     } else {
                            //       ScaffoldMessenger.of(context).showSnackBar(
                            //         SnackBar(
                            //           content: Text(
                            //             'Please select both start and destination points',
                            //             style: GoogleFonts.poppins(),
                            //           ),
                            //            behavior: SnackBarBehavior.floating,
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(100),
                            // ),
                            // showCloseIcon: true,
                            //           backgroundColor: widget.tripColour,
                            //           duration:  Duration(milliseconds: 600),
                            //         ),
                            //       );
                            //     }
                            //   },
                            //   style: ElevatedButton.styleFrom(
                            //     backgroundColor: widget.tripColour,
                            //     padding:  EdgeInsets.symmetric(vertical: 16),
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(12),
                            //     ),
                            //   ),
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: [
                            //        Icon(Icons.check, color: AppColours().mainWhiteColour),
                            //        SizedBox(width: 8),
                            //       Text(
                            //         'Confirm Selection',
                            //         style: GoogleFonts.poppins(
                            //           textStyle:  TextStyle(
                            //               fontSize: 14, fontWeight: FontWeight.w600),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Padding(
                    padding:  EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Point',
                          style: GoogleFonts.poppins(
                            textStyle:  TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                         SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColours().mainWhiteColour,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:  EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                          ),
                          hint: Text(
                            'Select Start Point',
                            style: GoogleFonts.poppins(
                              textStyle:  TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                          items: [
                            if (_currentLocation != null)
                              DropdownMenuItem(
                                value: 'current',
                                child: Row(
                                  children: [
                                     Icon(Icons.my_location,
                                        color: AppColours().goodBinColour),
                                     SizedBox(width: 8),
                                    Text(
                                      'Current Location',
                                      style: GoogleFonts.poppins(
                                        textStyle:  TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ...widget.currentStops
                                .map((bin) => DropdownMenuItem(
                                      value: bin.id,
                                      child: Row(
                                        children: [
                                           Icon(Icons.delete,
                                              color: AppColours().midBinColour),
                                           SizedBox(width: 8),
                                          Text(
                                            bin.name,
                                            style: GoogleFonts.poppins(
                                              textStyle:  TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                            DropdownMenuItem(
                              value: 'map',
                              child: Row(
                                children: [
                                   Icon(Icons.map, color: AppColours().takeATrip4),
                                   SizedBox(width: 8),
                                  Text(
                                    'Select on Map',
                                    style: GoogleFonts.poppins(
                                      textStyle:  TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == 'map') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      _buildMapScreen(isStart: true),
                                ),
                              );
                              setState(() {
                                selectOnMap = true;
                              });
                            } else if (value == 'current') {
                              _handleCurrentLocationSelect(isStart: true);
                            } else {
                              final selectedBin = widget.currentStops
                                  .firstWhere((bin) => bin.id == value);
                              setState(() {
                                _selectedStart = selectedBin;
                              });
                            }
                          },
                        ),
                         SizedBox(height: 16),
                        Text(
                          'Destination',
                          style: GoogleFonts.poppins(
                            textStyle:  TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                         SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColours().mainWhiteColour,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:  EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                          ),
                          hint: Text(
                            'Select Destination',
                            style: GoogleFonts.poppins(
                              textStyle:  TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                          items: [
                            if (_currentLocation != null)
                              DropdownMenuItem(
                                value: 'current',
                                child: Row(
                                  children: [
                                     Icon(Icons.my_location,
                                        color: AppColours().goodBinColour),
                                     SizedBox(width: 8),
                                    Text(
                                      'Current Location',
                                      style: GoogleFonts.poppins(
                                        textStyle:  TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ...widget.currentStops
                                .map((bin) => DropdownMenuItem(
                                      value: bin.id,
                                      child: Row(
                                        children: [
                                           Icon(Icons.delete,
                                              color: AppColours().midBinColour),
                                           SizedBox(width: 8),
                                          Text(
                                            bin.name,
                                            style: GoogleFonts.poppins(
                                              textStyle:  TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                            DropdownMenuItem(
                              value: 'map',
                              child: Row(
                                children: [
                                   Icon(Icons.map, color: AppColours().takeATrip4),
                                   SizedBox(width: 8),
                                  Text(
                                    'Select on Map',
                                    style: GoogleFonts.poppins(
                                      textStyle:  TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == 'map') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      _buildMapScreen(isStart: false),
                                ),
                              );
                              setState(() {
                                selectOnMap = true;
                              });
                            } else if (value == 'current') {
                              _handleCurrentLocationSelect(isStart: false);
                            } else {
                              final selectedBin = widget.currentStops
                                  .firstWhere((bin) => bin.id == value);
                              setState(() {
                                _selectedEnd = selectedBin;
                              });
                            }
                          },
                        ),
                         Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            if (_selectedStart != null &&
                                _selectedEnd != null) {
                              Navigator.pop(
                                context,
                                {'start': _selectedStart, 'end': _selectedEnd},
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please select both start and destination points',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  backgroundColor: widget.tripColour,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  showCloseIcon: true,
                                  behavior: SnackBarBehavior.floating,
                                  duration:  Duration(milliseconds: 600),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.tripColour,
                            padding:  EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                               Icon(Icons.check, color: AppColours().mainWhiteColour),
                               SizedBox(width: 8),
                              Text(
                                'Confirm Selection',
                                style: GoogleFonts.poppins(
                                  textStyle:  TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          )
        : Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(
                selectOnMap ? MediaQuery.of(context).size.height * 0.30 : 80,
              ),
              child: ClipRRect(
                borderRadius: selectOnMap
                    ? BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      )
                    : BorderRadius.all(Radius.zero),
                child: AppBar(
                  toolbarHeight: selectOnMap
                      ? MediaQuery.of(context).size.height * 0.25
                      : null,
                  backgroundColor: widget.tripColour.withOpacity(0.6),
                  elevation: 100,
                  title: Text(
                    'Set Locations',
                    style: GoogleFonts.poppins(
                      textStyle:  TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColours().mainWhiteColour,
                      ),
                    ),
                  ),
                  leading: IconButton(
                    icon:  Icon(Icons.arrow_back,
                        size: 28, color: AppColours().mainWhiteColour),
                    onPressed: () => Navigator.pop(context),
                  ),
                  bottom: selectOnMap
                      ? PreferredSize(
                          preferredSize: Size.fromHeight(0.2),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(
                              top: 10,
                              right: 20,
                              left: 20,
                              bottom: 30,
                            ),
                            decoration: BoxDecoration(
                              color: widget.tripColour.withOpacity(0.01),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.tripColour.withOpacity(0.2),
                                  blurRadius: 16,
                                  offset:  Offset(0, -4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Start Point',
                                  style: GoogleFonts.poppins(
                                    textStyle:  TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                 SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColours().mainWhiteColour,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding:  EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                  ),
                                  hint: Text(
                                    'Select Start Point',
                                    style: GoogleFonts.poppins(
                                      textStyle:  TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  items: [
                                    if (_currentLocation != null)
                                      DropdownMenuItem(
                                        value: 'current',
                                        child: Row(
                                          children: [
                                             Icon(Icons.my_location,
                                                color: AppColours().goodBinColour),
                                             SizedBox(width: 8),
                                            Text(
                                              'Current Location',
                                              style: GoogleFonts.poppins(
                                                textStyle:  TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (_selectedEnd != null)
                                      DropdownMenuItem(
                                        value: 'end',
                                        child: Row(
                                          children: [
                                             Icon(Icons.my_location,
                                                color: AppColours().mainGreyColour),
                                             SizedBox(width: 8),
                                            Text(
                                              'Same as Destination',
                                              style: GoogleFonts.poppins(
                                                textStyle:  TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ...widget.currentStops
                                        .map((bin) => DropdownMenuItem(
                                              value: bin.id,
                                              child: Row(
                                                children: [
                                                   Icon(Icons.delete,
                                                      color: AppColours().midBinColour),
                                                   SizedBox(width: 8),
                                                  Text(
                                                    bin.name,
                                                    style: GoogleFonts.poppins(
                                                      textStyle:
                                                           TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                    DropdownMenuItem(
                                      value: 'map',
                                      child: Row(
                                        children: [
                                           Icon(Icons.map,
                                              color: AppColours().takeATrip4),
                                           SizedBox(width: 8),
                                          Text(
                                            'Select on Map',
                                            style: GoogleFonts.poppins(
                                              textStyle:  TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value == 'map') {
                                      setState(() {
                                        selectOnMap = true;
                                        isStart = true;
                                      });
                                    } else if (value == 'current') {
                                      _handleCurrentLocationSelect(
                                          isStart: true);
                                    } else if (value == 'end') {
                                      setState(() {
                                        _selectedStart = _selectedEnd;
                                      });
                                    } else {
                                      final selectedBin = widget.currentStops
                                          .firstWhere((bin) => bin.id == value);
                                      setState(() {
                                        _selectedStart = selectedBin;
                                      });
                                    }
                                  },
                                ),
                                 SizedBox(height: 16),
                                Text(
                                  'Destination',
                                  style: GoogleFonts.poppins(
                                    textStyle:  TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                 SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColours().mainWhiteColour,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding:  EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                  ),
                                  hint: Text(
                                    'Select Destination',
                                    style: GoogleFonts.poppins(
                                      textStyle:  TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  items: [
                                    if (_currentLocation != null)
                                      DropdownMenuItem(
                                        value: 'current',
                                        child: Row(
                                          children: [
                                             Icon(Icons.my_location,
                                                color: AppColours().goodBinColour),
                                             SizedBox(width: 8),
                                            Text(
                                              'Current Location',
                                              style: GoogleFonts.poppins(
                                                textStyle:  TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (_selectedStart != null)
                                      DropdownMenuItem(
                                        value: 'start',
                                        child: Row(
                                          children: [
                                            Icon(Icons.my_location,
                                                color: AppColours().mainGreyColour),
                                             SizedBox(width: 8),
                                            Text(
                                              'Same as Start Point',
                                              style: GoogleFonts.poppins(
                                                textStyle:  TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ...widget.currentStops
                                        .map((bin) => DropdownMenuItem(
                                              value: bin.id,
                                              child: Row(
                                                children: [
                                                   Icon(Icons.delete,
                                                      color: AppColours().midBinColour),
                                                   SizedBox(width: 8),
                                                  Text(
                                                    bin.name,
                                                    style: GoogleFonts.poppins(
                                                      textStyle:
                                                           TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                    DropdownMenuItem(
                                      value: 'map',
                                      child: Row(
                                        children: [
                                           Icon(Icons.map,
                                              color: AppColours().takeATrip4),
                                           SizedBox(width: 8),
                                          Text(
                                            'Select on Map',
                                            style: GoogleFonts.poppins(
                                              textStyle:  TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value == 'map') {
                                      setState(() {
                                        selectOnMap = true;
                                        isStart = false;
                                      });
                                    } else if (value == 'current') {
                                      _handleCurrentLocationSelect(
                                          isStart: false);
                                    } else if (value == 'start') {
                                      setState(() {
                                        _selectedEnd = _selectedStart;
                                      });
                                    } else {
                                      final selectedBin = widget.currentStops
                                          .firstWhere((bin) => bin.id == value);
                                      setState(() {
                                        _selectedEnd = selectedBin;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ),
            body: selectOnMap
                ? Stack(
                    children: [
                      _buildMapScreen(isStart: isStart),
                      Positioned(
                        right: 16,
                        top: 50,
                        child: Column(
                          children: [
                            FloatingActionButton(
                              backgroundColor: widget.tripColour,
                              onPressed: _zoomIn,
                              tooltip: 'Zoom In',
                              heroTag: 'zoomIn',
                              child: Icon(
                                Icons.add,
                                color: AppColours().mainWhiteColour,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            FloatingActionButton(
                              backgroundColor: widget.tripColour,
                              heroTag: 'zoomOut',
                              tooltip: 'Zoom Out',
                              onPressed: _zoomOut,
                              child: Icon(
                                Icons.remove,
                                color: AppColours().mainWhiteColour,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            if (_currentLocation != null)
                              FloatingActionButton(
                                backgroundColor: widget.tripColour,
                                onPressed: _myLocation,
                                tooltip: 'My Location',
                                heroTag: 'meLocate',
                                child: Icon(
                                  Icons.my_location_outlined,
                                  color: AppColours().mainWhiteColour,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:  EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buildGoButton(),
                              ],
                            ),
                            // ElevatedButton(
                            //   onPressed: () {
                            //     if (_selectedStart != null && _selectedEnd != null) {
                            //       Navigator.pop(
                            //         context,
                            //         {'start': _selectedStart, 'end': _selectedEnd},
                            //       );
                            //     } else {
                            //       ScaffoldMessenger.of(context).showSnackBar(
                            //         SnackBar(
                            //           content: Text(
                            //             'Please select both start and destination points',
                            //             style: GoogleFonts.poppins(),
                            //           ),
                            //            behavior: SnackBarBehavior.floating,
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(100),
                            // ),
                            // showCloseIcon: true,
                            //           backgroundColor: widget.tripColour,
                            //           duration:  Duration(milliseconds: 600),
                            //         ),
                            //       );
                            //     }
                            //   },
                            //   style: ElevatedButton.styleFrom(
                            //     backgroundColor: widget.tripColour,
                            //     padding:  EdgeInsets.symmetric(vertical: 16),
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(12),
                            //     ),
                            //   ),
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: [
                            //        Icon(Icons.check, color: AppColours().mainWhiteColour),
                            //        SizedBox(width: 8),
                            //       Text(
                            //         'Confirm Selection',
                            //         style: GoogleFonts.poppins(
                            //           textStyle:  TextStyle(
                            //               fontSize: 14, fontWeight: FontWeight.w600),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Padding(
                    padding:  EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Point',
                          style: GoogleFonts.poppins(
                            textStyle:  TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                         SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColours().mainWhiteColour,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:  EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                          ),
                          hint: Text(
                            'Select Start Point',
                            style: GoogleFonts.poppins(
                              textStyle:  TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                          items: [
                            if (_currentLocation != null)
                              DropdownMenuItem(
                                value: 'current',
                                child: Row(
                                  children: [
                                     Icon(Icons.my_location,
                                        color: AppColours().goodBinColour),
                                     SizedBox(width: 8),
                                    Text(
                                      'Current Location',
                                      style: GoogleFonts.poppins(
                                        textStyle:  TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ...widget.currentStops
                                .map((bin) => DropdownMenuItem(
                                      value: bin.id,
                                      child: Row(
                                        children: [
                                           Icon(Icons.delete,
                                              color: AppColours().midBinColour),
                                           SizedBox(width: 8),
                                          Text(
                                            bin.name,
                                            style: GoogleFonts.poppins(
                                              textStyle:  TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                            DropdownMenuItem(
                              value: 'map',
                              child: Row(
                                children: [
                                   Icon(Icons.map, color: AppColours().takeATrip4),
                                   SizedBox(width: 8),
                                  Text(
                                    'Select on Map',
                                    style: GoogleFonts.poppins(
                                      textStyle:  TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == 'map') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      _buildMapScreen(isStart: true),
                                ),
                              );
                              setState(() {
                                selectOnMap = true;
                              });
                            } else if (value == 'current') {
                              _handleCurrentLocationSelect(isStart: true);
                            } else {
                              final selectedBin = widget.currentStops
                                  .firstWhere((bin) => bin.id == value);
                              setState(() {
                                _selectedStart = selectedBin;
                              });
                            }
                          },
                        ),
                         SizedBox(height: 16),
                        Text(
                          'Destination',
                          style: GoogleFonts.poppins(
                            textStyle:  TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                         SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColours().mainWhiteColour,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:  EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                          ),
                          hint: Text(
                            'Select Destination',
                            style: GoogleFonts.poppins(
                              textStyle:  TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                          items: [
                            if (_currentLocation != null)
                              DropdownMenuItem(
                                value: 'current',
                                child: Row(
                                  children: [
                                     Icon(Icons.my_location,
                                        color: AppColours().goodBinColour),
                                     SizedBox(width: 8),
                                    Text(
                                      'Current Location',
                                      style: GoogleFonts.poppins(
                                        textStyle:  TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ...widget.currentStops
                                .map((bin) => DropdownMenuItem(
                                      value: bin.id,
                                      child: Row(
                                        children: [
                                           Icon(Icons.delete,
                                              color: AppColours().midBinColour),
                                           SizedBox(width: 8),
                                          Text(
                                            bin.name,
                                            style: GoogleFonts.poppins(
                                              textStyle:  TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                            DropdownMenuItem(
                              value: 'map',
                              child: Row(
                                children: [
                                   Icon(Icons.map, color: AppColours().takeATrip4),
                                   SizedBox(width: 8),
                                  Text(
                                    'Select on Map',
                                    style: GoogleFonts.poppins(
                                      textStyle:  TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == 'map') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      _buildMapScreen(isStart: false),
                                ),
                              );
                              setState(() {
                                selectOnMap = true;
                              });
                            } else if (value == 'current') {
                              _handleCurrentLocationSelect(isStart: false);
                            } else {
                              final selectedBin = widget.currentStops
                                  .firstWhere((bin) => bin.id == value);
                              setState(() {
                                _selectedEnd = selectedBin;
                              });
                            }
                          },
                        ),
                         Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            if (_selectedStart != null &&
                                _selectedEnd != null) {
                              Navigator.pop(
                                context,
                                {'start': _selectedStart, 'end': _selectedEnd},
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please select both start and destination points',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  backgroundColor: widget.tripColour,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  showCloseIcon: true,
                                  behavior: SnackBarBehavior.floating,
                                  duration:  Duration(milliseconds: 600),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.tripColour,
                            padding:  EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                               Icon(Icons.check, color: AppColours().mainWhiteColour),
                               SizedBox(width: 8),
                              Text(
                                'Confirm Selection',
                                style: GoogleFonts.poppins(
                                  textStyle:  TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
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

  Widget _buildMapScreen({required bool isStart}) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentLocation ??
              (widget.currentStops.isNotEmpty
                  ? LatLng(widget.currentStops.first.latitude,
                      widget.currentStops.first.longitude)
                  :  LatLng(0, 0)),
          initialZoom: 13,
          onTap: (_, LatLng position) => _handleMapTap(position, isStart),
        ),
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
                 AppColours().mapFilterColour,
                BlendMode.overlay),
            child: TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains:  ['a', 'b', 'c'],
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
                      color:  AppColours().myLocationColour1,
                      border: Border.all(
                        color: AppColours().mainWhiteColour,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColours().myLocationColour2.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ...widget.currentStops.map((bin) => Marker(
                    point: LatLng(bin.latitude, bin.longitude),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColours().mainWhiteColour,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: AppColours().shadowColour, blurRadius: 6),
                        ],
                        border: Border.all(
                          color: AppColours().mainBlackColour.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      padding:  EdgeInsets.all(8),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FontAwesomeIcons.solidTrashCan,
                              color: _getFillLevelColor(
                                  bin.fillLevel, bin.capacity),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
              if (_selectedStart != null)
                Marker(
                  point: LatLng(
                      _selectedStart!.latitude, _selectedStart!.longitude),
                  height: 16,
                  width: 16,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: AppColours().mainGreyColour,
                      border: Border.all(
                        color: AppColours().takeATrip5,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColours().mainGreyColour.withOpacity(0.5),
                          blurRadius: 1,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              if (kIsWeb && _selectedEnd != null)
                Marker(
                  point:
                      LatLng(_selectedEnd!.latitude, _selectedEnd!.longitude),
                  child: Icon(
                    Icons.location_on,
                    size: 40,
                    color: AppColours().mainThemeColour,
                  ),
                ),
              if (!kIsWeb && _selectedEnd != null)
                Marker(
                  point:
                      LatLng(_selectedEnd!.latitude, _selectedEnd!.longitude),
                  width: MediaQuery.of(context).size.height * 0.045,
                  height: MediaQuery.of(context).size.height * 0.074,
                  child: Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.height * 0.005,
                      ),
                      Column(
                        children: [
                          Image.asset(
                            'assets/images/Map Marker.png',
                            height: MediaQuery.of(context).size.height * 0.04,
                            width: MediaQuery.of(context).size.height * 0.04,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.034,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateDistance(Bin a, Bin b) {
     double earthRadius = 6371e3;
    final lat1 = a.latitude * pi / 180;
    final lon1 = a.longitude * pi / 180;
    final lat2 = b.latitude * pi / 180;
    final lon2 = b.longitude * pi / 180;

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final aVal = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(aVal), sqrt(1 - aVal));

    return earthRadius * c;
  }

  List<Bin> _optimizeRouteWithStartEnd() {
    final stops =
        _currentStops.where((stop) => stop.id != _selectedStart?.id).toList();
    List<Bin> optimized = [];
    if (_selectedStart != null) optimized.add(_selectedStart!);

    while (stops.isNotEmpty) {
      stops.sort((a, b) => _calculateDistance(optimized.last, a)
          .compareTo(_calculateDistance(optimized.last, b)));
      optimized.add(stops.removeAt(0));
    }

    if (_selectedEnd != null && _selectedEnd?.id != optimized.lastOrNull?.id) {
      optimized.add(_selectedEnd!);
    }

    return optimized;
  }

  Color _getFillLevelColor(double fillLevel, double capacity) {
    final double fillPercentage = fillLevel / capacity;
    if (fillPercentage > 0.7499) return AppColours().closedColour2;
    if (fillPercentage > 0.499) return AppColours().takeATrip1;
    if (fillPercentage > 0.2499) return AppColours().takeATrip2;
    return AppColours().takeATrip3;
  }

  Widget _buildGoButton() {
    return ElevatedButton.icon(
      label: Text(
        'GO',
        style: AppTextStyles().buttonTextStyle.copyWith(fontSize: 20),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.tripColour,
        elevation: 100,
        shadowColor: AppColours().mainBlackColour.withOpacity(0.5),
        padding:  EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
      onPressed: _generateRoute,
    );
  }

  void _generateRoute() async {
    if (_selectedStart == null || _selectedEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please set start and end points'),
        backgroundColor: widget.tripColour,
        behavior: SnackBarBehavior.floating,
        duration:  Duration(milliseconds: 600),
      ));
      return;
    }

    final optimizedStops = _optimizeRouteWithStartEnd();
    final coordinates = optimizedStops
        .map((stop) => '${stop.latitude},${stop.longitude}')
        .join('/');

    final url =
        'https://www.google.com/maps/dir/${Uri.encodeFull(coordinates)}?travelmode=driving&dir_action=navigate';

    if (!await launchUrl(Uri.parse(url))) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Failed to launch navigation',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: widget.tripColour,
        duration:  Duration(milliseconds: 600),
      ));
    }
  }

  void _handleMapTap(LatLng position, bool isStart) {
    final bin = Bin(
      '',
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Custom Location',
      latitude: position.latitude,
      longitude: position.longitude,
      fillLevel: 0,
      gasLevel: 0,
      humidity: 0,
      temperature: 0,
      precipitation: 0,
      fillStatus: false,
      isClosed: false,
      isControllerOnClosed: false,
      imageUrl: '',
      type: 'Custom',
      capacity: 0,
      isSub: false,
      location: 'Custom Location',
      networkStatus: true,
      isManual: true,
    );

    setState(() {
      if (isStart) {
        _selectedStart = bin;
      } else {
        _selectedEnd = bin;
      }
    });
  }

  void _handleCurrentLocationSelect({required bool isStart}) {
    if (_currentLocation == null) return;

    final bin = Bin(
      '',
      id: 'current',
      name: 'Current Location',
      latitude: _currentLocation!.latitude,
      longitude: _currentLocation!.longitude,
      fillLevel: 0,
      gasLevel: 0,
      humidity: 0,
      temperature: 0,
      precipitation: 0,
      fillStatus: false,
      isClosed: false,
      isControllerOnClosed: false,
      imageUrl: '',
      type: 'Current',
      capacity: 0,
      isSub: false,
      location: 'Current Location',
      networkStatus: true,
      isManual: true,
    );

    setState(() {
      if (isStart) {
        _selectedStart = bin;
      } else {
        _selectedEnd = bin;
      }
    });
  }
}
