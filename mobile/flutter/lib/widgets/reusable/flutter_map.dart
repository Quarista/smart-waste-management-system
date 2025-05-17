import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:swms_administration/constants/colours.dart';
import 'package:url_launcher/url_launcher.dart';

class MapCard extends StatefulWidget {
  final LatLng? location;
  final bool isBinMarker;
  final bool fullscreen;
  final bool isMyLocation;
  final bool isFullscreenMap;
  final bool isGoogleMaps;
  final bool isInteractive;
  final bool showControls;
  const MapCard({
    super.key,
    this.location,
    required this.isBinMarker,
    required this.fullscreen,
    required this.isMyLocation,
    required this.isFullscreenMap,
    required this.isGoogleMaps,
    required this.isInteractive,
    required this.showControls,
  });

  @override
  State<MapCard> createState() => _MapCardState();
}

class _MapCardState extends State<MapCard> {
  final MapController _mapController = MapController();

  LatLng? _currentLocation;

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
    if (widget.location != null) {
      _mapController.move(
        widget.location!,
        17,
      );
    }
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

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && widget.isMyLocation) {
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
    if (permission == LocationPermission.denied && widget.isMyLocation) {
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

    if (permission == LocationPermission.deniedForever && widget.isMyLocation) {
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
    if (context.mounted && widget.isMyLocation) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    }
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
                      flags: widget.isInteractive
                          ? InteractiveFlag.all
                          : InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          const Color.fromARGB(255, 160, 185, 220)
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
                                  borderRadius: BorderRadius.circular(100),
                                  color: const Color.fromARGB(255, 0, 93, 231),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blueAccent.withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 20,
                                    ),
                                  ]),
                            ),
                          ),
                        if (widget.isBinMarker && widget.location != null)
                          Marker(
                            point: widget.location!,
                            child: Icon(
                              Icons.location_on,
                              size: 40,
                              color: AppColours().mainThemeColour,
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
              if (widget.isGoogleMaps)
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
                                final latitude =
                                    widget.location?.latitude ?? 0.0;
                                final longitude =
                                    widget.location?.longitude ?? 0.0;
                                await _launchUrl(
                                    'https://www.google.com/maps?q=$latitude,$longitude&z=17');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 2),
                                height: 40,
                                width: 200,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.blue.shade200),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.map,
                                          color: Colors.blue.shade800),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'View in Google Maps',
                                        style: TextStyle(
                                          color: Colors.blue.shade800,
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
                    if (widget.isBinMarker || widget.location != null)
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
                    if (widget.showControls)
                      SizedBox(
                        height: 8,
                      ),
                    if (widget.showControls)
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
                    if (widget.showControls)
                      SizedBox(
                        height: 8,
                      ),
                    if (widget.showControls)
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        if (widget.isFullscreenMap) {
          _openFullScreenMap(_mapController.camera.center);
        }
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
                initialCenter:
                    widget.location ?? _currentLocation ?? LatLng(0, 0),
                interactionOptions: InteractionOptions(
                  flags: widget.isInteractive
                      ? InteractiveFlag.all
                      : InteractiveFlag.none,
                ),
              ),
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                      const Color.fromARGB(255, 160, 185, 220).withOpacity(0.8),
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
                              borderRadius: BorderRadius.circular(100),
                              color: const Color.fromARGB(255, 0, 93, 231),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 20,
                                ),
                              ]),
                        ),
                      ),
                    if (widget.isBinMarker && widget.location != null)
                      Marker(
                        point: widget.location!,
                        child: Icon(
                          Icons.location_on,
                          size: 40,
                          color: AppColours().mainThemeColour,
                        ),
                      ),
                  ],
                )
              ],
            ),
            if (widget.isFullscreenMap)
              Positioned(
                top: 16,
                right: 16,
                child: FloatingActionButton(
                  backgroundColor: AppColours().mainThemeColour,
                  onPressed: () {
                    _openFullScreenMap(_mapController.camera.center);
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
                      backgroundColor: AppColours().mainThemeColour,
                      onPressed: _myLocation,
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
                  if (widget.isBinMarker || widget.location != null)
                    FloatingActionButton(
                      backgroundColor: AppColours().mainThemeColour,
                      onPressed: _initialLocation,
                      tooltip: 'Locate Bin',
                      heroTag: 'binLocate',
                      mini: true,
                      child: Icon(
                        FontAwesomeIcons.solidTrashCan,
                        color: AppColours().mainWhiteColour,
                        size: 20,
                      ),
                    ),
                  if (widget.showControls)
                    SizedBox(
                      height: 5,
                    ),
                  FloatingActionButton(
                    backgroundColor: AppColours().mainThemeColour,
                    onPressed: _zoomIn,
                    tooltip: 'Zoom In',
                    heroTag: 'zoomIn',
                    mini: true,
                    child: Icon(
                      Icons.add,
                      color: AppColours().mainWhiteColour,
                    ),
                  ),
                  if (widget.showControls)
                    SizedBox(
                      height: 5,
                    ),
                  if (widget.showControls)
                    FloatingActionButton(
                      backgroundColor: AppColours().mainThemeColour,
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
            )
          ],
        ),
      ),
    );
  }
}
