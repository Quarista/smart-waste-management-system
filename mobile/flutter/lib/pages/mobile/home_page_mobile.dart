import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swms_administration/constants/colours.dart';
import 'package:swms_administration/models/news_model.dart';
import 'package:swms_administration/router/router.dart';
import 'package:swms_administration/services/database.dart';
import 'package:swms_administration/services/news_services.dart';
import 'package:swms_administration/widgets/reusable/clock.dart';
import 'package:swms_administration/widgets/reusable/date.dart';

class HomePageMobile extends StatefulWidget {
  const HomePageMobile({super.key});

  @override
  State<HomePageMobile> createState() => _HomePageMobileState();
}

class _HomePageMobileState extends State<HomePageMobile> {
  final TextEditingController _searchController = TextEditingController();
  late NewsServices _newsServices;
  late StreamSubscription<DocumentSnapshot> _sessionSubscription;
  List<DeveloperNews> _filteredNews = [];
  late int _currentHour;
  late Timer _timer;
  final _dbService = DataBaseService();
  bool _isLoading = true;
  String imageUrl = 'https://i.ibb.co/FqgHp43y/waste-management-mobile.png';
  void getImageUrl() {
    final docRef = FirebaseFirestore.instance
        .collection("A1_SuperAdmin_QuaristaControl")
        .doc('Home Page');
    _sessionSubscription = docRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final imageUrlList = data['MobileImage'] ??
            [
              'https://i.ibb.co/FqgHp43y/waste-management-mobile.png',
              'https://g.foolcdn.com/editorial/images/567131/waste-management.jpg',
            ];
        imageUrlList.shuffle();
        final imageUrlF = imageUrlList[
                imageUrlList.length - 3 >= 0 ? imageUrlList.length - 3 : 0] ??
            'https://i.ibb.co/FqgHp43y/waste-management-mobile.png';
        setState(() {
          imageUrl = imageUrlF;
        });
      } else {
        setState(() {
          imageUrl = 'https://i.ibb.co/FqgHp43y/waste-management-mobile.png';
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getImageUrl();
    _newsServices = NewsServices();

    // Set up the initial filtered bins list
    _filteredNews = _newsServices.allNews;

    // Add listener to the search controller
    _searchController.addListener(_filterNews);

    // Listen to changes from BinServices
    _newsServices.addListener(_onNewsUpdated);
    _currentHour = _getCurrentHour();
    _startTimer();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _dbService.getBins();
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterNews);
    _searchController.dispose();
    _newsServices.removeListener(_onNewsUpdated);
    _newsServices.dispose();
    _sessionSubscription.cancel();
    _timer.cancel();
    super.dispose();
  }

  void _onNewsUpdated() {
    _filterNews();
  }

  void _filterNews() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredNews = _newsServices.allNews;
        _filteredNews.sort(
          (a, b) => b.date.compareTo(a.date),
        );
      } else {
        _filteredNews = _newsServices.searchBins(_searchController.text);
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentHour = _getCurrentHour();
      });
    });
  }

  int _getCurrentHour() {
    return DateTime.now().hour;
  }

  String _getGreeting() {
    if (_currentHour >= 0 && _currentHour < 12) {
      return 'Good Morning,';
    } else if (_currentHour >= 12 && _currentHour < 18) {
      return 'Good Afternoon,';
    } else {
      return 'Good Evening,';
    }
  }

  String _getUsername() {
    // Replace with actual username retrieval logic
    return 'Admin User';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final appColours = AppColours();
    return Scaffold(
      backgroundColor: appColours.scaffoldColour,
      body: RefreshIndicator(
        elevation: 2,
        displacement: MediaQuery.of(context).size.height * 0.44 / 3,
        color: appColours.mainThemeColour,
        backgroundColor: appColours.mainThemeColour,
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            // Modern AppBar with Parallax Effect
            SliverAppBar(
              expandedHeight: size.height * 0.35,
              pinned: true,
              backgroundColor: appColours.scaffoldColour,
              elevation: 0,
              stretch: true,
              toolbarHeight: size.height * 0.13,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.blurBackground,
                  StretchMode.zoomBackground,
                ],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Hero image with gradient overlay
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/waste_management_mobile.png',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            appColours.mainWhiteColour.withOpacity(0.2),
                            appColours.mainWhiteColour,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Greeting text
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AutoSizeText(
                                  _getGreeting(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: appColours.mainTextColour,
                                  ),
                                  maxLines: 1,
                                  minFontSize: 8,
                                ),
                                AutoSizeText(
                                  _getUsername(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: appColours.mainTextColour,
                                  ),
                                  maxLines: 1,
                                  minFontSize: 8,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Clock and date
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color:
                                  appColours.mainWhiteColour.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: appColours.mainBlackColour
                                      .withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                RealTimeClock(
                                  isClock: true,
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: AppColours().mainThemeColour,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                RealTimeDate(
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: appColours.textColour2,
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
            ),

            // Welcome Message Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColours().mainThemeColour.withOpacity(0.9),
                      AppColours().mainThemeColour.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColours().mainThemeColour.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.eco_outlined,
                          color: appColours.mainWhiteColour,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Welcome to",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: appColours.mainWhiteColour,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Team Quaristas™ Smart Waste Management System",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: appColours.mainWhiteColour,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Revolutionizing waste management with smart technologies for a cleaner tomorrow.",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: appColours.mainWhiteColour.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Tooltip(
                          message: 'Who we are',
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to dashboard or detailed view
                              RouterClass.router.push('/quarista');
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: AppColours().mainThemeColour,
                              backgroundColor: appColours.mainWhiteColour,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "About Quarista",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Developer News Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.code_rounded,
                      color: AppColours().mainThemeColour,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Developer News",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColours().mainTextColour,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // News Cards
            SliverList(
              delegate: SliverChildListDelegate([
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _filteredNews.length,
                  itemBuilder: (context, index) {
                    DeveloperNews news = _filteredNews[index];
                    String getMonth(int month) {
                      if (month == 1) {
                        return 'January';
                      } else if (month == 2) {
                        return 'February';
                      } else if (month == 3) {
                        return 'March';
                      } else if (month == 4) {
                        return 'April';
                      } else if (month == 5) {
                        return 'May';
                      } else if (month == 6) {
                        return 'June';
                      } else if (month == 7) {
                        return 'July';
                      } else if (month == 8) {
                        return 'August';
                      } else if (month == 9) {
                        return 'September';
                      } else if (month == 10) {
                        return 'October';
                      } else if (month == 11) {
                        return 'November';
                      } else if (month == 12) {
                        return 'December';
                      } else {
                        return 'January';
                      }
                    }

                    final String month = getMonth(news.date.month);
                    return _buildNewsCard(context,
                        date: '$month ${news.date.day}, ${news.date.year}',
                        title: news.title,
                        content: news.content,
                        icon: news.icon);
                  },
                ),
                // _buildNewsCard(
                //   context,
                //   date: "April 22, 2025",
                //   title: "Android 1.4.0 Released",
                //   content:
                //       "Collection Routes, Fill Level Charts and many more!",
                //   icon: Icons.android_rounded,
                // ),
                // _buildNewsCard(
                //   context,
                //   date: "April 19, 2025",
                //   title: "Fill Level Distribution",
                //   content:
                //       "Interactive charts that communicate with the user's mind to give great idea about the system!",
                //   icon: Icons.auto_graph_rounded,
                // ),
                // _buildNewsCard(
                //   context,
                //   date: "April 16, 2025",
                //   title: "Collection Route Navigations",
                //   content:
                //       "Drivers can now plan their routes within seconds through their mobile!",
                //   icon: FontAwesomeIcons.truckFront,
                // ),
                // _buildNewsCard(
                //   context,
                //   date: "April 15, 2025",
                //   title: "App Animations",
                //   content:
                //       "Creative transitions that delights the users and some more!",
                //   icon: Icons.star_half_rounded,
                // ),
                // _buildNewsCard(
                //   context,
                //   date: "April 8, 2025",
                //   title: "Launcher Icon Released",
                //   content: "A custom launcher icon was revealed",
                //   icon: Icons.rocket_launch_rounded,
                // ),
                // _buildNewsCard(
                //   context,
                //   date: "March 31, 2025",
                //   title: "Android 1.3.0 Released",
                //   content: "Flutter Map, Colour Theme Update and many more!",
                //   icon: Icons.android_rounded,
                // ),
                // _buildNewsCard(
                //   context,
                //   date: "March 30, 2025",
                //   title: "Responsive Update 8.0.0 Released",
                //   content:
                //       "Major UI updates to Post Manager Page, User Requests Page and Dustbin Info Page!",
                //   icon: Icons.devices_other_rounded,
                // ),
                // _buildNewsCard(
                //   context,
                //   date: "March 29, 2025",
                //   title: "Update 4.5 Released",
                //   content: "Flutter Map, Colour Themes Update and many more!",
                //   icon: Icons.map_rounded,
                // ),
                // _buildNewsCard(
                //   context,
                //   date: "March 22, 2025",
                //   title: "UI Update 3.5 Released",
                //   content:
                //       "Major UI updates to Post Manager Page and many more!",
                //   icon: Icons.system_update,
                // ),
                // _buildNewsCard(
                //   context,
                //   date: "March 21, 2025",
                //   title: "Android APK Released",
                //   content:
                //       "The Android APK was released for the first time in Firebase App Distribution",
                //   icon: Icons.android_rounded,
                // ),
                // _buildNewsCard(
                //   context,
                //   date: "March 19, 2025",
                //   title: "Deployed To Firebase",
                //   content: "The Web was deployed once again and Updated",
                //   icon: Icons.webhook_rounded,
                // ),
                // _buildNewsCard(
                //   context,
                //   date: "March 19, 2025",
                //   title: "UI Update 2.5 Released",
                //   content:
                //       "Major improvements to bin capacity monitoring and route optimization algorithms.",
                //   icon: Icons.system_update,
                // ),
                // _buildNewsCard(
                //   context,
                //   date: "March 13, 2025",
                //   title: "New Analytics Dashboard",
                //   content:
                //       "Enhanced analytics dashboard with real-time waste collection metrics and trend analysis.",
                //   icon: Icons.analytics_outlined,
                // ),
                // _buildNewsCard(
                //   context,
                //   date: "March 9, 2025",
                //   title: "Mobile App Performance Boost",
                //   content:
                //       "50% faster load times and reduced battery consumption in the latest mobile update.",
                //   icon: Icons.speed_outlined,
                // ),
                const SizedBox(height: 16),
              ]),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AppColours().toggleTheme(),
        backgroundColor: AppColours().mainThemeColour,
        child: Icon(
          AppColours().isDarkMode ? Icons.light_mode : Icons.dark_mode,
          color: AppColours().mainWhiteColour,
        ),
      ),
    );
  }

  Widget _buildNewsCard(
    BuildContext context, {
    required String date,
    required String title,
    required String content,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: AppColours().mainWhiteColour,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColours().mainBlackColour.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColours().mainGreyColour.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to news detail page
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColours().mainThemeColour.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: AppColours().mainThemeColour,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColours().mainGreyColour,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColours().mainTextColour,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  content,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColours().textColour2,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
