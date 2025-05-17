import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swms_administration/constants/colours.dart';

class CreateNewBinPage extends StatefulWidget {
  const CreateNewBinPage({super.key});

  @override
  State<CreateNewBinPage> createState() => _CreateNewBinPageState();
}

class _CreateNewBinPageState extends State<CreateNewBinPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _litersController = TextEditingController();
  final TextEditingController _mainBinController = TextEditingController();
  Uint8List? _webImageBytes;
  File? _selectedImage;
  String? _imageUrl;
  String? _base64Image;
  LatLng? _currentLocation;
  bool _isLoading = false;
  String? _imagePath;
  late bool isFromGallery;
  String _selectedBinType = 'Major';
  final List<String> _binTypes = ['Major', 'Minor', 'Branch'];
  final bool isLocationSelected = false;
  LatLng? _selectedLocation;
  LatLng? _finalLocation;
  final MapController _mapController = MapController();
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      try {
        setState(() => _isLoading = true);
        if (kIsWeb) {
          final bytes = await pickedImage.readAsBytes();
          final base64 = base64Encode(bytes);
          if (!_validateImageSize(base64)) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Image too large! Maximum file size - 30MB',
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  showCloseIcon: true,
                  closeIconColor: AppColours().mainWhiteColour,
                  backgroundColor: AppColours().dustbinCardRedColour1,
                  dismissDirection: DismissDirection.up,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            return;
          }
          setState(() async {
            _webImageBytes = bytes;
            _base64Image = base64;
            _selectedImage = null;
            if (_base64Image != null) {
              _imageUrl = await uploadImage(_base64Image!);
            }
          });
        } else {
          final imageFile = File(pickedImage.path);
          final imageBytes = await imageFile.readAsBytes();
          Uint8List? thumbnailBytesGlobal;
          if (!_validateImageSize(base64Encode(imageBytes))) {
            final thumbnailFile = await _createThumbnail(pickedImage.path);
            final thumbnailBytes = await thumbnailFile.readAsBytes();
            thumbnailBytesGlobal = thumbnailBytes;
          }
          setState(() async {
            _selectedImage = imageFile;
            if (_validateImageSize(base64Encode(imageBytes))) {
              _base64Image = base64Encode(imageBytes);
            } else if (_validateImageSize(
                base64Encode(thumbnailBytesGlobal!))) {
              _base64Image = base64Encode(thumbnailBytesGlobal);
            }
            _webImageBytes = null;
            if (_base64Image != null) {
              _imageUrl = await uploadImage(_base64Image!);
            }
          });
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<File> _createThumbnail(String path) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/thumbnail_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      path,
      targetPath,
      quality: 70,
      minWidth: 300,
      minHeight: 300,
    );

    return File(result!.path);
  }

  Future<String?> uploadImage(String base64image) async {
    const apiKey = '1818002ea2eb7f94fc37020430f55158';
    final uri = Uri.parse('https://api.imgbb.com/1/upload');
    final base64Image = base64image;
    // Send POST request
    final response = await http.post(
      uri,
      body: {
        'key': apiKey,
        'image': base64Image,
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['data']['url'];
    } else {
      throw Exception('Upload failed: ${response.body}');
    }
  }

  bool _validateImageSize(String base64Image) {
    // Calculate the actual byte size accounting for Base64 encoding
    const maxSizeKB = 30720;
    final base64Length = base64Image.length;
    final sizeInBytes =
        (base64Length * 3 / 4).ceil(); // Base64 size calculation

    return sizeInBytes <= maxSizeKB * 1024;
  }

  final Color _primaryColor = AppColours().mainThemeColour;
  final Color _accentColor = AppColours().addNewPost;

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

  void _setSelectedLocation(LatLng point) {
    setState(() {
      _selectedLocation = point;
    });
  }

  void _openFullScreenMap(LatLng? myLocation) {
    LatLng? tempLocation = _selectedLocation;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Select Location',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              backgroundColor: _primaryColor,
              foregroundColor: AppColours().mainWhiteColour,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              automaticallyImplyLeading: false,
            ),
            body: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      onTap: (tapPosition, LatLng point) {
                        _setSelectedLocation(point);
                        tempLocation = point;
                        setDialogState(() {});
                      },
                      maxZoom: 21,
                      minZoom: 1,
                      initialZoom: 17,
                      initialCenter:
                          _currentLocation ?? LatLng(6.904946, 79.861151),
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
                          if (myLocation != null)
                            Marker(
                              point: myLocation,
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
                                  ],
                                ),
                              ),
                            ),
                          if (kIsWeb && tempLocation != null)
                            Marker(
                              point: tempLocation!,
                              child: Icon(
                                Icons.location_on,
                                size: 40,
                                color: AppColours().mainThemeColour,
                              ),
                            ),
                          if (!kIsWeb && tempLocation != null)
                            Marker(
                              point: tempLocation!,
                              width: MediaQuery.of(context).size.height * 0.045,
                              height:
                                  MediaQuery.of(context).size.height * 0.074,
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
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 130,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColours().mainWhiteColour,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColours().mainTextColour.withOpacity(0.2),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 160,
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
                Positioned(
                  bottom: 16,
                  left: MediaQuery.of(context).size.width * 0.3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _finalLocation = _selectedLocation;
                            Navigator.pop(context);
                          });
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColours().scaffoldColour,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: AppColours()
                                    .mainTextColour
                                    .withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, -4),
                              ),
                            ],
                            border: Border.all(
                              color:
                                  AppColours().mainThemeColour.withOpacity(0.1),
                              width: 1.5,
                            ),
                          ),
                          child: FittedBox(
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: AppColours().mainThemeColour,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Choose Location',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: AppColours().mainThemeColour,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 75,
                  left: 10,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColours().mainThemeColour,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColours().mainWhiteColour,
                    ),
                  ),
                )
              ],
            ),
          );
        });
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _idController.dispose();
    _litersController.dispose();
    _mainBinController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _selectImage() {
    _pickImage(isFromGallery ? ImageSource.gallery : ImageSource.camera);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours().scaffoldColour,
      appBar: AppBar(
        title: Text(
          'Add New Dustbin',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: _primaryColor,
        foregroundColor: AppColours().scaffoldColour,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(6),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accentColor.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accentColor.withOpacity(0.15),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              physics: BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 30, top: 10),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.recycling,
                                size: 40,
                                color: _primaryColor,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Register Collection Point',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColours().mainTextColour,
                              ),
                            ),
                            Text(
                              'Create a new waste collection point',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColours().textColour2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildInputLabel('Collection Name'),
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Provide a descriptive name',
                      icon: Icons.label_outline,
                      keyboardType: TextInputType.name,
                    ),
                    _buildInputLabel('Collection Type'),
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColours().mainWhiteColour,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColours().mainBlackColour.withOpacity(0.03),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        child: DropdownButtonFormField<String>(
                          icon: Icon(Icons.arrow_drop_down_circle,
                              color: _primaryColor),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.account_tree_outlined,
                                color: _primaryColor),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          style: GoogleFonts.poppins(
                            color: AppColours().mainTextColour,
                            fontSize: 15,
                          ),
                          value: _selectedBinType,
                          isExpanded: true,
                          isDense: true,
                          items: _binTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedBinType = newValue;
                              });
                            }
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please select a type'
                              : null,
                        ),
                      ),
                    ),
                    if (_selectedBinType == 'Branch')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('Root Collection Point'),
                          _buildTextField(
                            controller: _mainBinController,
                            hintText: 'Enter the name of the Root Bin',
                            icon: Icons.account_tree_outlined,
                            keyboardType: TextInputType.name,
                          ),
                        ],
                      ),
                    _buildInputLabel('Capacity'),
                    _buildTextField(
                      controller: _litersController,
                      hintText: 'Volume capacity',
                      icon: Icons.inventory_2_outlined,
                      keyboardType: TextInputType.number,
                      suffix: Text(
                        'Liters',
                        style: GoogleFonts.poppins(
                          color: AppColours().textColour2,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _buildInputLabel('Location Details'),
                    _buildTextField(
                      controller: _locationController,
                      hintText: 'Briefly specify the physical location',
                      icon: Icons.pin_drop_outlined,
                      keyboardType: TextInputType.streetAddress,
                    ),
                    _buildInputLabel('Map Location'),
                    GestureDetector(
                      onTap: () {
                        _openFullScreenMap(_currentLocation);
                      },
                      child: Container(
                        height: _finalLocation == null ? 160 : 220,
                        margin: EdgeInsets.only(bottom: 32),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColours().mainWhiteColour,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _primaryColor
                                .withOpacity(_imagePath != null ? 0.7 : 0.2),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColours()
                                  .mainBlackColour
                                  .withOpacity(0.03),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: _finalLocation == null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: _accentColor.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color:
                                                _primaryColor.withOpacity(0.1),
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.add_location_alt_outlined,
                                          size: 38,
                                          color: _accentColor,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Add Location',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          color: AppColours().mainTextColour,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    height: double.infinity,
                                    width: MediaQuery.of(context).size.width *
                                        0.55,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: FlutterMap(
                                          mapController: _mapController,
                                          options: MapOptions(
                                            initialCenter: _finalLocation!,
                                            initialZoom: 15,
                                            interactionOptions:
                                                InteractionOptions(
                                              flags: InteractiveFlag.pinchZoom,
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
                                                subdomains: const [
                                                  'a',
                                                  'b',
                                                  'c'
                                                ],
                                              ),
                                            ),
                                            MarkerLayer(
                                              markers: [
                                                if (kIsWeb &&
                                                    _finalLocation != null)
                                                  Marker(
                                                    point: _finalLocation!,
                                                    child: Icon(
                                                      Icons.location_on,
                                                      size: 40,
                                                      color: AppColours()
                                                          .mainThemeColour,
                                                    ),
                                                  ),
                                                if (!kIsWeb &&
                                                    _finalLocation != null)
                                                  Marker(
                                                    point: _finalLocation!,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.045,
                                                    height:
                                                        MediaQuery.of(context)
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
                                        )),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color:
                                                  _accentColor.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: _primaryColor
                                                    .withOpacity(0.1),
                                                width: 1,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.edit_location_alt_outlined,
                                              size: 38,
                                              color: _accentColor,
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'Edit Location',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  AppColours().mainTextColour,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                    ),
                    _buildInputLabel('Upload Image'),
                    Container(
                      height: 160,
                      margin: EdgeInsets.only(bottom: 32),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColours().mainWhiteColour,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _primaryColor
                              .withOpacity(_imagePath != null ? 0.7 : 0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColours().mainBlackColour.withOpacity(0.03),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: _base64Image != null
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    color: _accentColor.withOpacity(0.1),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          image: DecorationImage(
                                            image: MemoryImage(
                                              base64Decode(_base64Image!),
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedImage = null;
                                                _webImageBytes = null;
                                                _base64Image = null;
                                              });
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 10),
                                              decoration: BoxDecoration(
                                                color: AppColours()
                                                    .mainWhiteColour,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColours()
                                                        .mainBlackColour
                                                        .withOpacity(0.1),
                                                    blurRadius: 8,
                                                    spreadRadius: 1,
                                                  )
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .check_circle_outline,
                                                      color: _primaryColor),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Image Selected',
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: _primaryColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            'Tap to change the image',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: AppColours().textColour2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: _accentColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _primaryColor.withOpacity(0.1),
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.add_a_photo_outlined,
                                        size: 38,
                                        color: _accentColor,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Add DustBin Photo',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        color: AppColours().mainTextColour,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            _accentColor.withOpacity(0.1),
                                        foregroundColor: _primaryColor,
                                        elevation: 0,
                                        side: BorderSide(
                                          color: _primaryColor.withOpacity(0.1),
                                          width: 1,
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isFromGallery = false;
                                        });
                                        _selectImage();
                                      },
                                      child: Text('Take a Photo'),
                                    ),
                                    SizedBox(height: 12),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            _accentColor.withOpacity(0.1),
                                        foregroundColor: _primaryColor,
                                        elevation: 0,
                                        side: BorderSide(
                                          color: _primaryColor.withOpacity(0.1),
                                          width: 1,
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isFromGallery = true;
                                        });
                                        _selectImage();
                                      },
                                      child: Text('Choose from Gallery'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [_primaryColor, _accentColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_base64Image != null) {
                            if (!_validateImageSize(_base64Image!)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    kIsWeb
                                        ? 'Image too large! Maximum file size - 30MB'
                                        : 'Image too large! Max 30MB after compression',
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  showCloseIcon: true,
                                  closeIconColor: AppColours().mainWhiteColour,
                                  backgroundColor:
                                      AppColours().dustbinCardRedColour1,
                                  dismissDirection: DismissDirection.up,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            } else if (_formKey.currentState!.validate() ||
                                _imageUrl != null) {
                              final FirebaseFirestore _firestore =
                                  FirebaseFirestore.instance;
                              try {
                                int? docNo;
                                final String binUninitialized = 'uninitialized';
                                Future<void> getDustbinCount() async {
                                  final QuerySnapshot snapshot =
                                      await _firestore
                                          .collection('Dustbins')
                                          .get();
                                  docNo = snapshot.docs.length + 1;
                                }

                                await getDustbinCount();
                                await _firestore
                                    .collection('Dustbins')
                                    .doc('dustbin ${docNo ?? binUninitialized}')
                                    .set({
                                  'name': _nameController.text,
                                  'location': _locationController.text,
                                  'imageUrl': _imageUrl ??
                                      'https://i.ibb.co/bMTZ2Lr4/Pagama.png',
                                  'type': _selectedBinType,
                                  'isClosed': true,
                                  'capacity':
                                      double.parse(_litersController.text),
                                  'isSub': _selectedBinType == 'Branch',
                                  'isManual': false,
                                  'mainBin': _selectedBinType == 'Branch'
                                      ? _mainBinController.text
                                      : null,
                                  'latitude': _finalLocation == null
                                      ? 0
                                      : _finalLocation!.latitude,
                                  'longitude': _finalLocation == null
                                      ? 0
                                      : _finalLocation!.longitude,
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Collection point registered successfully!',
                                      style: GoogleFonts.poppins(),
                                    ),
                                    backgroundColor: _primaryColor,
                                    dismissDirection:
                                        DismissDirection.startToEnd,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error while registering collection point',
                                      style: GoogleFonts.poppins(),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                );
                                return;
                              }
                            }
                          } else if (_formKey.currentState!.validate()) {
                            final FirebaseFirestore _firestore =
                                FirebaseFirestore.instance;
                            try {
                              int? docNo;
                              final String binUninitialized = 'uninitialized';
                              Future<void> getDustbinCount() async {
                                final QuerySnapshot snapshot = await _firestore
                                    .collection('Dustbins')
                                    .get();
                                docNo = snapshot.docs.length + 1;
                              }

                              await getDustbinCount();
                              await _firestore
                                  .collection('Dustbins')
                                  .doc('dustbin ${docNo ?? binUninitialized}')
                                  .set({
                                'name': _nameController.text,
                                'location': _locationController.text,
                                'type': _selectedBinType,
                                'isClosed': true,
                                'isControllerOnClosed': true,
                                'imageUrl':
                                    'https://i.ibb.co/bMTZ2Lr4/Pagama.png',
                                'capacity':
                                    double.parse(_litersController.text),
                                'isSub': _selectedBinType == 'Branch',
                                'isManual': false,
                                'mainBin': _selectedBinType == 'Branch'
                                    ? _mainBinController.text
                                    : null,
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Collection point registered successfully!',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  backgroundColor: _primaryColor,
                                  dismissDirection: DismissDirection.startToEnd,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error while registering collection point',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                              );
                              return;
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColours().mainWhiteColour,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          minimumSize: Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_outlined),
                            SizedBox(width: 12),
                            AutoSizeText(
                              'REGISTER',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              minFontSize: 13,
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColours().mainTextColour,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required TextInputType keyboardType,
    Widget? suffix,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColours().mainWhiteColour,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColours().mainBlackColour.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: AppColours().mainTextColour,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: AppColours().hintTextColour,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: _primaryColor),
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: suffix,
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty || value.trim().isEmpty) {
            return 'This field is required';
          }
          if (keyboardType == TextInputType.number &&
              double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          if (keyboardType == TextInputType.number &&
              double.tryParse(value)! <= 0) {
            return 'Please enter a positive number';
          }
          return null;
        },
      ),
    );
  }
}
