import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swms_administration/constants/colours.dart';
import 'package:swms_administration/models/post_model.dart';
import 'package:swms_administration/router/router.dart';
import 'package:swms_administration/services/post_services.dart';

class PostManagerPageDesktop extends StatefulWidget {
  const PostManagerPageDesktop({super.key});

  @override
  State<PostManagerPageDesktop> createState() => _PostManagerPageDesktopState();
}

class _PostManagerPageDesktopState extends State<PostManagerPageDesktop> {
  final TextEditingController _searchController = TextEditingController();
  late PostServices _postServices;
  List<Post> _filteredPosts = [];
  @override
  void initState() {
    super.initState();
    _postServices = PostServices();
    //Setup initial posts list
    _filteredPosts = _postServices.allPosts;
    // Add listener to the search controller
    _searchController.addListener(_filterPosts);

    // Listen to changes from PostServices
    _postServices.addListener(_onPostsUpdated);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPosts);
    _searchController.dispose();
    _postServices.removeListener(_onPostsUpdated);
    _postServices.dispose();
    super.dispose();
  }

  // Update filtered posts when PostServices updates
  void _onPostsUpdated() {
    _filterPosts();
  }

  //Filter posts based on search text
  void _filterPosts() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredPosts = _postServices.allPosts;
      } else {
        _filteredPosts = _postServices.searchPosts(_searchController.text);
      }
    });
  }

  void _openPostDetailsBottomSheet(BuildContext context, Post post) {
    List<String?> subImages = post.subImages != null
        ? post.subImages!.map((img) => img.toString()).toList()
        : [];
    void removeNullImgs() {
      subImages.removeWhere((image) => image == '');
    }

    final AppColours appColours = AppColours();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        removeNullImgs();
        return Container(
          decoration: BoxDecoration(
            color: appColours.scaffoldColour,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Scaffold(
            backgroundColor: appColours.scaffoldColour,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: appColours.scaffoldColour,
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 24,
                          color: appColours.dustbinCardColour1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      _openFullScreenImage(
                          context, post.thumbnail, post.title, post.category);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        post.thumbnail,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            'https://i.ibb.co/C51TLWKG/Screenshot-2025-03-09-192257.png',
                            fit: BoxFit.fill,
                            width: double.infinity,
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    post.title,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: appColours.mainBlackColour,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColours().profilePageMembers1.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      post.category,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColours().mainThemeColour,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Overview",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: appColours.mainBlackColour,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    post.overview,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: appColours.dustbinCardColour1,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Approach",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: appColours.mainBlackColour,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    post.approach,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: appColours.dustbinCardColour1,
                    ),
                  ),
                  SizedBox(height: 20),
                  if (subImages.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            height: 100,
                            child: ListView.builder(
                              itemCount: subImages.length,
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                final String image = subImages[index]!;
                                return Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      _openFullScreenImage(context, image,
                                          post.title, post.category);
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.network(
                                        image,
                                        fit: BoxFit.cover,
                                        width: 150,
                                        height: 100,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              height: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: appColours
                                                    .mainBlackColour
                                                    .withOpacity(0.1),
                                                border: Border.all(
                                                  color: appColours
                                                      .mainBlackColour
                                                      .withOpacity(0.02),
                                                  width: 2,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: appColours
                                                        .dustbinCardShadowColour,
                                                    blurRadius: 5,
                                                    spreadRadius: 2,
                                                    offset: Offset(
                                                      2,
                                                      0,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              child: FittedBox(
                                                fit: BoxFit.contain,
                                                child: Padding(
                                                  padding: EdgeInsets.all(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.01),
                                                  child: Icon(
                                                    Icons.image,
                                                    color: appColours
                                                        .mainWhiteColour,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openFullScreenImage(
      BuildContext context, String imagePath, String title, String category) {
    final AppColours appColours = AppColours();
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: appColours.scaffoldColour,
            elevation: 0,
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: appColours.mainBlackColour,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        category,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: appColours.dustbinCardColour1,
                        ),
                      ),
                    ],
                  ),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 24,
                        color: appColours.dustbinCardColour1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: InteractiveViewer(
                      panEnabled: true,
                      alignment: Alignment.center,
                      minScale: 0.5,
                      maxScale: 40,
                      child: Image.network(
                        imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            'https://i.ibb.co/C51TLWKG/Screenshot-2025-03-09-192257.png',
                            fit: BoxFit.fill,
                            width: double.infinity,
                          );
                        },
                      ),
                    ),
                  ),
                ]),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColours appColours = AppColours();
    return Scaffold(
      backgroundColor: AppColours().scaffoldColour,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Post Manager',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Spacer(
                      flex: 8,
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          final Map<Post, bool> map = {
                            Post(
                              id: '',
                              [],
                              approach: '',
                              category: '',
                              overview: '',
                              thumbnail: '',
                              title: '',
                              Timestamp.now(),
                            ): true,
                          };
                          RouterClass.router.push('/createpost', extra: map);
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: appColours.mainThemeColour,
                            border: Border.all(
                              color: appColours.mainThemeColour,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                fit: FlexFit.tight,
                                flex: 1,
                                child: Icon(
                                  Icons.add,
                                  size: 22,
                                  color: appColours.mainWhiteColour,
                                ),
                              ),
                              Flexible(
                                fit: FlexFit.tight,
                                flex: 7,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'New Post',
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: appColours.mainWhiteColour,
                                        ),
                                      ),
                                      overflow: TextOverflow.fade,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.9,
                    ),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _filteredPosts.length,
                    itemBuilder: (context, index) {
                      final Post post = _filteredPosts[index];
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.8,
                        width: double.infinity,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: appColours.mainGreyColour.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                post.thumbnail,
                                fit: BoxFit.fill,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.network(
                                    'https://i.ibb.co/C51TLWKG/Screenshot-2025-03-09-192257.png',
                                    fit: BoxFit.fill,
                                    width: double.infinity,
                                  );
                                },
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.2,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    appColours.mainBlackColour.withOpacity(0.8),
                                    appColours.mainBlackColour.withOpacity(0.1),
                                  ],
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 9,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        top: 14,
                                        left: 14,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            fit: FlexFit.tight,
                                            flex: 2,
                                            child: AutoSizeText(
                                              post.category,
                                              style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                  color: appColours.darkText,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              maxLines: 1,
                                              minFontSize: 7,
                                              overflow: TextOverflow.fade,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Flexible(
                                            fit: FlexFit.tight,
                                            flex: 5,
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.54,
                                              child: AutoSizeText(
                                                post.title,
                                                style: GoogleFonts.poppins(
                                                  textStyle: TextStyle(
                                                    color: appColours
                                                        .mainWhiteColour,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                maxLines: 2,
                                                minFontSize: 12,
                                                overflow: TextOverflow.fade,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Spacer(
                                            flex: 1,
                                          ),
                                          Flexible(
                                            fit: FlexFit.tight,
                                            flex: 1,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Tooltip(
                                                  message: 'View Post',
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      _openPostDetailsBottomSheet(
                                                          context, post);
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(3),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: appColours
                                                            .mainWhiteColour
                                                            .withOpacity(0.9),
                                                      ),
                                                      child: Center(
                                                        child: FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Icon(
                                                            Icons
                                                                .visibility_outlined,
                                                            color: appColours
                                                                .dustbinCardRedColour2,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Tooltip(
                                                  message: 'Edit Post',
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      final Map<Post, bool>
                                                          map = {
                                                        Post(
                                                          post.subImages,
                                                          id: post.id,
                                                          category:
                                                              post.category,
                                                          overview:
                                                              post.overview,
                                                          approach:
                                                              post.approach,
                                                          thumbnail:
                                                              post.thumbnail,
                                                          title: post.title,
                                                          post.timestamp ??
                                                              Timestamp.now(),
                                                        ): false,
                                                      };
                                                      RouterClass.router.push(
                                                          '/createpost',
                                                          extra: map);
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(3),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: appColours
                                                            .mainWhiteColour
                                                            .withOpacity(0.9),
                                                      ),
                                                      child: Center(
                                                        child: FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Icon(
                                                            Icons.edit_outlined,
                                                            color: appColours
                                                                .mainThemeColour,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Tooltip(
                                                  message: 'Delete Post',
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      try {
                                                        final _firestore =
                                                            FirebaseFirestore
                                                                .instance;
                                                        _firestore
                                                            .collection(
                                                                'post_updates')
                                                            .doc(post.id)
                                                            .delete();
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Center(
                                                              child: Text(
                                                                'Post Deleted',
                                                                style: GoogleFonts
                                                                    .poppins(),
                                                              ),
                                                            ),
                                                            behavior:
                                                                SnackBarBehavior
                                                                    .floating,
                                                            backgroundColor:
                                                                appColours
                                                                    .errorColour,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.32,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100),
                                                            ),
                                                          ),
                                                        );
                                                      } catch (e) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Error! Unable to delete the post',
                                                              style: GoogleFonts
                                                                  .poppins(),
                                                            ),
                                                            behavior:
                                                                SnackBarBehavior
                                                                    .floating,
                                                            backgroundColor:
                                                                appColours
                                                                    .dustbinCardRedColour1,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(2),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: appColours
                                                            .mainWhiteColour
                                                            .withOpacity(0.9),
                                                      ),
                                                      child: Center(
                                                        child: FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Icon(
                                                            Icons
                                                                .delete_outlined,
                                                            color: appColours
                                                                .dustbinCardRedColour3,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
