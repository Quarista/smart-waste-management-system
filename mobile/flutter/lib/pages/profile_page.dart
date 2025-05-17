import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:swms_administration/constants/colours.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

void main() {
  runApp(const QuaristaApp());
}

class QuaristaApp extends StatelessWidget {
  const QuaristaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quarista Team',
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: GoogleFonts.poppinsTextTheme(),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ProfilePage(),
    );
  }
}

class TeamMember {
  final String name;
  final String role;
  final String bio;
  final String imageUrl;
  final List<SocialLink> socialLinks;

  TeamMember({
    required this.name,
    required this.role,
    required this.bio,
    required this.imageUrl,
    required this.socialLinks,
  });
}

class SocialLink {
  final String platform;
  final String url;
  final IconData icon;

  SocialLink({
    required this.platform,
    required this.url,
    required this.icon,
  });
}

class ProfileServices extends ChangeNotifier {}

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _TeamProfilePageState();
}

class _TeamProfilePageState extends State<ProfilePage> {
  final List<TeamMember> _teamMembers = [];

  int _selectedMemberIndex = 0;
  bool _showQuaristaInfo = true;
  late Timer _autoSlideTimer;
  final PageController _pageController = PageController();
  String _quaristaDescription1 = '';
  String _quaristaDescription2 = '';

  @override
  void initState() {
    super.initState();
    _fetchTeamMembers();
    _fetchQuaristaInfo();
    // Auto-hide Quarista info after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showQuaristaInfo = false;
        });
        // Start auto-sliding through team members
        _startAutoSlide();
      }
    });
  }

  void _fetchTeamMembers() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection("A1_SuperAdmin_QuaristaControl")
        .doc('Team Profile')
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null) {
        final List<TeamMember> members = [];

        data.forEach((key, value) {
          if (key.startsWith('Member') && value is List<dynamic>) {
            members.add(TeamMember(
              name: value[0],
              role: value[1],
              bio: value[2],
              imageUrl: value[3],
              socialLinks: [], // Add logic for social links if available
            ));
          }
        });

        setState(() {
          _teamMembers.clear();
          _teamMembers.addAll(members);
        });
      }
    }
  }

  void _fetchQuaristaInfo() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection("A1_SuperAdmin_QuaristaControl")
        .doc('Team Profile')
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data['Quarista'] != null) {
        final List<dynamic> quaristaInfo = data['Quarista'];
        if (quaristaInfo.length >= 2) {
          setState(() {
            _quaristaDescription1 = quaristaInfo[0];
            _quaristaDescription2 = quaristaInfo[1];
          });
        }
      }
    }
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (mounted) {
        setState(() {
          _selectedMemberIndex =
              (_selectedMemberIndex + 1) % _teamMembers.length;
        });
        _pageController.animateToPage(
          _selectedMemberIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600; // Define tablet breakpoint

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isTablet),
            Expanded(
              child: _showQuaristaInfo
                  ? _buildQuaristaInfo(isTablet)
                  : _buildMemberDetailsPageView(isTablet),
            ),
            SizedBox(
              height: isTablet ? 200 : 150, // Adjust height for tablets
              child: _buildMemberSelector(isTablet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/quaristalogo.png',
              width: isTablet ? 70 : 50, // Adjust size for tablets
              height: isTablet ? 70 : 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Team Quarista',
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 28 : 24, // Adjust font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Meet our amazing team',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: AppColours().contColour3,
                      fontSize: isTablet ? 16 : 14, // Adjust font size
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuaristaInfo(bool isTablet) {
    return AnimationConfiguration.synchronized(
      duration: const Duration(milliseconds: 800),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ListView(
                children: [
                  Container(
                    width: isTablet ? 150 : 120, // Adjust size for tablets
                    height: isTablet ? 150 : 120,
                    decoration: BoxDecoration(
                      color: AppColours().profilePageQuarista,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColours().mainBlackColour.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.groups_rounded,
                      size: isTablet ? 80 : 60, // Adjust size for tablets
                      color: AppColours().mainWhiteColour,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'About Quarista',
                    style: GoogleFonts.poppins(
                      fontSize: isTablet ? 32 : 28, // Adjust font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(_quaristaDescription1,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: isTablet ? 18 : 16, // Adjust font size
                          height: 1.5,
                          color: AppColours().dustbinCardColour1,
                        ),
                      )),
                  const SizedBox(height: 16),
                  Text(_quaristaDescription2,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: isTablet ? 18 : 16, // Adjust font size
                          height: 1.5,
                          color: AppColours().dustbinCardColour1,
                        ),
                      )),
                  const SizedBox(height: 32),
                  Text('Loading team profiles...',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: AppColours().contColour3,
                          fontStyle: FontStyle.italic,
                          fontSize: isTablet ? 16 : 14, // Adjust font size
                        ),
                      )),
                  const SizedBox(height: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberDetailsPageView(bool isTablet) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _selectedMemberIndex = index;
        });
      },
      itemCount: _teamMembers.length,
      itemBuilder: (context, index) {
        return _buildMemberDetails(_teamMembers[index], isTablet);
      },
    );
  }

  Widget _buildMemberDetails(TeamMember member, bool isTablet) {
    return AnimationConfiguration.synchronized(
      duration: const Duration(milliseconds: 500),
      child: SlideAnimation(
        horizontalOffset: 50.0,
        child: FadeInAnimation(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Hero(
                    tag: 'member-${member.name}',
                    child: Container(
                      height: isTablet ? 250 : 200,
                      width: isTablet ? 250 : 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColours().mainBlackColour.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          member.imageUrl,
                          fit: BoxFit.cover,
                          frameBuilder:
                              (context, child, frame, wasSynchronouslyLoaded) {
                            if (wasSynchronouslyLoaded) {
                              return child;
                            }
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: frame == null
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        color: AppColours().mainThemeColour,
                                      ),
                                    )
                                  : child,
                            );
                          },
                          errorBuilder: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    member.name,
                    style: GoogleFonts.poppins(
                      fontSize: isTablet ? 32 : 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColours().profilePageMembers1.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      member.role,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColours().profilePageMembers,
                        fontSize: isTablet ? 18 : 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'About',
                  style: GoogleFonts.poppins(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(member.bio,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        height: 1.5,
                        color: AppColours().dustbinCardColour1,
                      ),
                    )),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberSelector(bool isTablet) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColours().contColour2,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: AppColours().contColour1,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _teamMembers.length,
              itemBuilder: (context, index) {
                final member = _teamMembers[index];
                final isSelected = index == _selectedMemberIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMemberIndex = index;
                    });
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    // Stop and restart auto-sliding when user manually selects
                    _autoSlideTimer.cancel();
                    _startAutoSlide();
                  },
                  child: AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Container(
                          width: isTablet ? 100 : 90,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColours()
                                    .profilePageMembers1
                                    .withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColours().profilePageMembers
                                        : Colors.transparent,
                                    width: 2.5,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Hero(
                                    tag: 'thumb-${member.name}',
                                    child: Image.network(
                                      member.imageUrl,
                                      width: isTablet ? 70 : 60,
                                      height: isTablet ? 70 : 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(member.name.split(' ')[0],
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? AppColours().profilePageMembers
                                          : AppColours().mainBlackColour,
                                      fontSize: isTablet ? 16 : 14,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
