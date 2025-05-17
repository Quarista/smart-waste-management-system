import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swms_administration/constants/colours.dart';
import 'package:swms_administration/models/post_model.dart';

class CreateNewPostPage extends StatefulWidget {
  final Post post;
  final bool isNew;
  const CreateNewPostPage({
    super.key,
    required this.post,
    required this.isNew,
  });

  @override
  State<CreateNewPostPage> createState() => _CreateNewPostPageState();
}

class _CreateNewPostPageState extends State<CreateNewPostPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _postTitleController = TextEditingController();
  final TextEditingController _postCategoryController = TextEditingController();
  final TextEditingController _postOverviewController = TextEditingController();
  final TextEditingController _postApproachController = TextEditingController();
  final TextEditingController _thumbnailController = TextEditingController();
  final TextEditingController _subImage01Controller = TextEditingController();
  final TextEditingController _subImage02Controller = TextEditingController();
  final TextEditingController _subImage03Controller = TextEditingController();
  Uint8List? _webImageBytes;
  File? _selectedImage;
  String? _thumbnailUrl;
  String? _image1;
  String? _image2;
  String? _image3;
  String? _base64Image;
  bool _isLoading = false;
  String? _imagePath;
  late bool isFromGallery;
  int subImageCount = 0;

  final Color _primaryColor = AppColours().mainThemeColour;
  final Color _accentColor = AppColours().addNewPost;

  Future<void> _pickImage(ImageSource source, int image) async {
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
              if (image == 0) {
                _thumbnailUrl = await uploadImage(_base64Image!);
              } else if (image == 1) {
                _image1 = await uploadImage(_base64Image!);
                setState(() {
                  subImageCount++;
                });
              } else if (image == 2) {
                _image2 = await uploadImage(_base64Image!);
                setState(() {
                  subImageCount++;
                });
              } else if (image == 3) {
                _image3 = await uploadImage(_base64Image!);
                setState(() {
                  subImageCount++;
                });
              }
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
              if (image == 0) {
                _thumbnailUrl = await uploadImage(_base64Image!);
              } else if (image == 1) {
                _image1 = await uploadImage(_base64Image!);
                setState(() {
                  subImageCount++;
                });
              } else if (image == 2) {
                _image2 = await uploadImage(_base64Image!);
                setState(() {
                  subImageCount++;
                });
              } else if (image == 3) {
                _image3 = await uploadImage(_base64Image!);
                setState(() {
                  subImageCount++;
                });
              }
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

  @override
  void initState() {
    _postCategoryController.text = widget.post.category;
    _postTitleController.text = widget.post.title;
    _postOverviewController.text = widget.post.overview;
    _postApproachController.text = widget.post.approach;
    if (!widget.isNew) {
      _thumbnailUrl = widget.post.thumbnail;
      subImageCount =
          widget.post.subImages != null ? widget.post.subImages!.length : 0;
      _image1 = subImageCount > 0 ? widget.post.subImages![0] : null;
      _image2 = subImageCount > 1 ? widget.post.subImages![1] : null;
      _image3 = subImageCount > 2 ? widget.post.subImages![2] : null;
    }
    super.initState();
  }

  @override
  void dispose() {
    _postTitleController.dispose();
    _postCategoryController.dispose();
    _postOverviewController.dispose();
    _postApproachController.dispose();
    _thumbnailController.dispose();
    _subImage01Controller.dispose();
    _subImage02Controller.dispose();
    _subImage03Controller.dispose();
    super.dispose();
  }

  void _selectImage(int image) {
    _pickImage(isFromGallery ? ImageSource.gallery : ImageSource.camera, image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours().scaffoldColour,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        foregroundColor: AppColours().mainWhiteColour,
        elevation: 0,
        title: Text(
          widget.isNew ? 'Add a new post' : 'Edit Post',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: AppColours().mainWhiteColour,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColours().mainWhiteColour),
          onPressed: () {
            Navigator.pop(context);
          },
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
                    widget.isNew
                        ? Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.article,
                                    size: 60,
                                    color: _primaryColor,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  widget.isNew
                                      ? 'Create New Post'
                                      : 'Edit Post',
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      color: AppColours().mainBlackColour,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Let people know your work',
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      color: AppColours()
                                          .mainBlackColour
                                          .withOpacity(0.7),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(),
                    SizedBox(height: 30),
                    Text(
                      'Title',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: AppColours().mainBlackColour.withOpacity(1),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColours().mainWhiteColour,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColours().mainBlackColour.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 1,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _postTitleController,
                        decoration: InputDecoration(
                          hintText: 'A new great title',
                          hintStyle: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              color:
                                  AppColours().mainBlackColour.withOpacity(0.5),
                              fontSize: 16,
                            ),
                          ),
                          prefixIcon: Icon(Icons.title, color: _primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            color: AppColours().mainBlackColour,
                            fontSize: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Category',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: AppColours().mainBlackColour.withOpacity(1),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColours().mainWhiteColour,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColours().mainBlackColour.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 1,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _postCategoryController,
                        decoration: InputDecoration(
                          hintText: 'Category',
                          hintStyle: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              color:
                                  AppColours().mainBlackColour.withOpacity(0.5),
                              fontSize: 16,
                            ),
                          ),
                          prefixIcon:
                              Icon(Icons.category, color: _primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            color: AppColours().mainBlackColour,
                            fontSize: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a category';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Overview',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: AppColours().mainBlackColour.withOpacity(1),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Stack(children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColours().mainWhiteColour,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColours().mainBlackColour.withOpacity(0.1),
                              blurRadius: 5,
                              spreadRadius: 1,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _postOverviewController,
                          decoration: InputDecoration(
                            hintText: 'Describe Briefly',
                            hintStyle: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                color: AppColours()
                                    .mainBlackColour
                                    .withOpacity(0.5),
                                fontSize: 16,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.do_not_touch,
                              color: Colors.transparent,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              color: AppColours().mainBlackColour,
                              fontSize: 16,
                            ),
                          ),
                          maxLines: 6,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter an overview';
                            }
                            return null;
                          },
                        ),
                      ),
                      Positioned(
                        left: 12,
                        top: 12, // Matches contentPadding top
                        child: Icon(
                          Icons.description,
                          color: _primaryColor,
                        ),
                      ),
                    ]),
                    SizedBox(height: 20),
                    Text(
                      'Approach',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: AppColours().mainBlackColour.withOpacity(1),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Stack(children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColours().mainWhiteColour,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColours().mainBlackColour.withOpacity(0.1),
                              blurRadius: 5,
                              spreadRadius: 1,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _postApproachController,
                          decoration: InputDecoration(
                            hintText: 'Describe Briefly',
                            hintStyle: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                color: AppColours()
                                    .mainBlackColour
                                    .withOpacity(0.5),
                                fontSize: 16,
                              ),
                            ),
                            prefixIcon: Icon(Icons.analytics,
                                color: Colors.transparent),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              color: AppColours().mainBlackColour,
                              fontSize: 16,
                            ),
                          ),
                          maxLines: 6,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter an approach';
                            }
                            return null;
                          },
                        ),
                      ),
                      Positioned(
                        left: 12,
                        top: 12, // Matches contentPadding top
                        child: Icon(
                          Icons.analytics,
                          color: _primaryColor,
                        ),
                      ),
                    ]),
                    SizedBox(height: 20),
                    Text(
                      'Thumbnail',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: AppColours().mainBlackColour.withOpacity(1),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Make sure the image is landscape for a better visual appearence',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: AppColours().mainBlackColour.withOpacity(0.4),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
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
                      child: _thumbnailUrl != null
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
                                            image: NetworkImage(
                                              _thumbnailUrl!,
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
                                                _thumbnailUrl = null;
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
                                        _selectImage(0);
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
                                        _selectImage(0);
                                      },
                                      child: Text('Choose from Gallery'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Other Images',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: AppColours().mainBlackColour.withOpacity(1),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      widget.isNew ? 'Add upto 3 images' : 'Add upto 3 images',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: AppColours().mainBlackColour.withOpacity(0.4),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
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
                      child: _image1 != null
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
                                            image: NetworkImage(
                                              _image1!,
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
                                                _image1 = null;
                                                subImageCount--;
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
                                        _selectImage(1);
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
                                        _selectImage(1);
                                      },
                                      child: Text('Choose from Gallery'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                    if (subImageCount > 0)
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
                              color: AppColours()
                                  .mainBlackColour
                                  .withOpacity(0.03),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: _image2 != null
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
                                              image: NetworkImage(
                                                _image2!,
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
                                                  _image2 = null;
                                                  subImageCount--;
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10),
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
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .check_circle_outline,
                                                        color: _primaryColor),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Image Selected',
                                                      style:
                                                          GoogleFonts.poppins(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                            color:
                                                _primaryColor.withOpacity(0.1),
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
                                            color:
                                                _primaryColor.withOpacity(0.1),
                                            width: 1,
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isFromGallery = false;
                                          });
                                          _selectImage(2);
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
                                            color:
                                                _primaryColor.withOpacity(0.1),
                                            width: 1,
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isFromGallery = true;
                                          });
                                          _selectImage(2);
                                        },
                                        child: Text('Choose from Gallery'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                    if (subImageCount > 1)
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
                              color: AppColours()
                                  .mainBlackColour
                                  .withOpacity(0.03),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: _image3 != null
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
                                              image: NetworkImage(
                                                _image3!,
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
                                                  _image3 = null;
                                                  subImageCount--;
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10),
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
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .check_circle_outline,
                                                        color: _primaryColor),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Image Selected',
                                                      style:
                                                          GoogleFonts.poppins(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                            color:
                                                _primaryColor.withOpacity(0.1),
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
                                            color:
                                                _primaryColor.withOpacity(0.1),
                                            width: 1,
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isFromGallery = false;
                                          });
                                          _selectImage(3);
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
                                            color:
                                                _primaryColor.withOpacity(0.1),
                                            width: 1,
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isFromGallery = true;
                                          });
                                          _selectImage(3);
                                        },
                                        child: Text('Choose from Gallery'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                    SizedBox(height: 30),
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
                        onPressed: () async {
                          if (widget.isNew) {
                            if (_formKey.currentState!.validate() ||
                                _thumbnailUrl != null) {
                              final FirebaseFirestore _firestore =
                                  FirebaseFirestore.instance;
                              _firestore.collection('post_updates').orderBy(
                                    'timestamp',
                                    descending: true,
                                  );
                              try {
                                int? docNo;
                                final String postUninitialized =
                                    'uninitialized';
                                Future<void> getPostCount() async {
                                  final QuerySnapshot snapshot =
                                      await _firestore
                                          .collection('post_updates')
                                          .get();
                                  docNo = snapshot.docs.length + 1;
                                }

                                await getPostCount();
                                await _firestore
                                    .collection('post_updates')
                                    .doc('post ${docNo ?? postUninitialized}')
                                    .set({
                                  'title': _postTitleController.text,
                                  'category': _postCategoryController.text,
                                  'overviewText': _postOverviewController.text,
                                  'approachText': _postApproachController.text,
                                  'src': _thumbnailUrl,
                                  'smallImages': [_image1, _image2, _image3],
                                  'timestamp': FieldValue.serverTimestamp(),
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Post published successfully!',
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
                                Navigator.pop(context);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error while publishing the post!',
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
                            } else if (_base64Image != null) {
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
                                    closeIconColor:
                                        AppColours().mainWhiteColour,
                                    backgroundColor:
                                        AppColours().dustbinCardRedColour1,
                                    dismissDirection: DismissDirection.up,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                              return;
                            } else {
                              return;
                            }
                          } else if (_formKey.currentState!.validate() ||
                              _thumbnailUrl != null) {
                            final FirebaseFirestore _firestore =
                                FirebaseFirestore.instance;
                            _firestore.collection('post_updates').orderBy(
                                  'timestamp',
                                  descending: true,
                                );
                            try {
                              await _firestore
                                  .collection('post_updates')
                                  .doc(widget.post.id)
                                  .set({
                                'title': _postTitleController.text,
                                'category': _postCategoryController.text,
                                'overviewText': _postOverviewController.text,
                                'approachText': _postApproachController.text,
                                'src': _thumbnailUrl,
                                'smallImages': [_image1, _image2, _image3],
                                'timestamp': widget.post.timestamp ??
                                    FieldValue.serverTimestamp(),
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Post updated successfully!',
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
                              Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error while updating the post!',
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
                          } else if (_base64Image != null) {
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
                            }
                            return;
                          } else {
                            return;
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.publish,
                                color: AppColours().mainWhiteColour),
                            SizedBox(width: 12),
                            AutoSizeText(
                              widget.isNew ? 'PUBLISH' : 'UPDATE',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  color: AppColours().mainWhiteColour,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                letterSpacing: 1,
                              ),
                              maxLines: 1,
                              minFontSize: 13,
                              overflow: TextOverflow.ellipsis,
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
}
