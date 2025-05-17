import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:animations/animations.dart';
import 'package:swms_administration/constants/colours.dart';
import 'package:swms_administration/pages/desktop/dustbin_dashboard_desktop.dart';
import 'package:swms_administration/pages/desktop/dustbin_info_desktop.dart';
import 'package:swms_administration/pages/desktop/home_page_desktop.dart';
import 'package:swms_administration/pages/desktop/post_manager_page_desktop.dart';
import 'package:swms_administration/pages/desktop/user_requests_page_desktop.dart';

import 'package:swms_administration/pages/mobile/dustbin_dashboard_mobile.dart';
import 'package:swms_administration/pages/mobile/dustbin_info_mobile.dart';
import 'package:swms_administration/pages/mobile/home_page_mobile.dart';
import 'package:swms_administration/pages/mobile/post_manager_page_mobile.dart';
import 'package:swms_administration/pages/mobile/user_requests_page_mobile.dart';

import 'package:swms_administration/utils/responsive.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool isSidebarExpanded = true; // Default expanded for desktop
  bool _tabletSidebarUserPreference = false;

  // Animation controllers
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _bounceController;
  late AnimationController _navBarController;

  // Create a map to store individual animations for nav items
  Map<int, AnimationController> _navItemControllers = {};

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _navBarController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Create animation controllers for each nav item
    for (int i = 0; i < 5; i++) {
      _navItemControllers[i] = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );
    }

    // Initialize sidebar state based on device type
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          isSidebarExpanded = !Responsive.isTablet(context);
        });

        // Initial animations
        _scaleController.forward();
        _navBarController.forward();
        _startNavItemAnimations();
      }
    });
  }

  void _startNavItemAnimations() {
    // Staggered animation for nav items
    Future.delayed(const Duration(milliseconds: 100), () {
      _navItemControllers[0]?.forward();
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      _navItemControllers[1]?.forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      _navItemControllers[2]?.forward();
    });
    Future.delayed(const Duration(milliseconds: 250), () {
      _navItemControllers[3]?.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _navItemControllers[4]?.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);
    final appColours = AppColours();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuint,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            // Sidebar for Tablets & Web with animation
            if (isDesktop) _buildSidebar(isTablet),

            // Main Page Content with enhanced page transitions
            Expanded(
              child: AlignTransition(
                alignment: Tween<AlignmentGeometry>(
                  begin: const Alignment(0, 0.5),
                  end: const Alignment(0, 0),
                ).animate(_navBarController),
                child: PageTransitionSwitcher(
                  transitionBuilder: (
                    Widget child,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                  ) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.02),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  child: _buildCurrentPage(isDesktop),
                  duration: const Duration(milliseconds: 400),
                ),
              ),
            ),
          ],
        ),
        // Bottom Navigation for Mobile with completely redesigned animation
        bottomNavigationBar: !isDesktop ? _buildMobileNavBar() : null,
      ),
    );
  }

  // Helper method to get the current page based on selected index
  Widget _buildCurrentPage(bool isDesktop) {
    final pages = isDesktop
        ? [
            HomePageDesktop(),
            DustbinDashboardDesktop(),
            DustbinInfoDesktop(),
            PostManagerPageDesktop(),
            UserRequestsPageDesktop(),
          ]
        : [
            HomePageMobile(),
            DustbinDashboardMobile(),
            DustbinInfoMobile(),
            PostManagerPageMobile(),
            UserRequestsPageMobile(),
          ];

    return pages[_selectedIndex];
  }

  // Enhanced Sidebar Widget with improved tablet support and animations
  Widget _buildSidebar(bool isTablet) {
    final primaryColor = Theme.of(context).primaryColor;
    final accentColor = const Color.fromARGB(255, 106, 0, 255);

    // Set appropriate width for different states
    double sidebarWidth = isTablet
        ? (isSidebarExpanded ? 230 : 75) // Slightly narrower for tablet
        : (isSidebarExpanded ? 250 : 75); // Standard width for desktop

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      width: sidebarWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color.fromARGB(120, 166, 168, 167),
            const Color.fromARGB(70, 166, 168, 167),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // App Logo or Title with animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.elasticOut,
                )),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: isSidebarExpanded
                ? Padding(
                    key: const ValueKey('expanded-title'),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: AnimatedBuilder(
                      animation: _bounceController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + 0.05 * _bounceController.value.abs(),
                          child: child,
                        );
                      },
                      child: Text(
                        "SWMS Admin",
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 20 : 22,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          shadows: [
                            Shadow(
                              color: accentColor.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Padding(
                    key: const ValueKey('collapsed-title'),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationController.value * 2 * 3.14159,
                          child: child,
                        );
                      },
                      child: Icon(
                        Icons.recycling,
                        size: 28,
                        color: accentColor,
                      ),
                    ),
                  ),
          ),

          // Toggle Button with improved tablet support and animations
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  isSidebarExpanded = !isSidebarExpanded;
                  if (isTablet) {
                    _tabletSidebarUserPreference = isSidebarExpanded;
                  }

                  // Trigger animations
                  if (isSidebarExpanded) {
                    _rotationController.forward(from: 0.0);
                  } else {
                    _rotationController.reverse(from: 1.0);
                  }
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Tooltip(
                message: isSidebarExpanded ? "Collapse Menu" : "Expand Menu",
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.05),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder(
                        tween: Tween<double>(
                            begin: 0, end: isSidebarExpanded ? 0 : 0.5),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        builder: (_, double value, Widget? child) {
                          return Transform.rotate(
                            angle: value * 3.14159 * 2,
                            child: child,
                          );
                        },
                        child: Icon(
                          Icons.chevron_left,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutQuint,
                        child: isSidebarExpanded
                            ? Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  "Collapse Menu",
                                  style: _menuTextStyle(isTablet: isTablet)
                                      .copyWith(fontSize: 14),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Divider(
              color: const Color.fromARGB(95, 255, 255, 255), thickness: 1.5),

          const SizedBox(height: 16),

          // Navigation Items with enhanced animations
          _buildNavItem(Icons.home_outlined, "Home", 0, isTablet),
          _buildNavItem(Icons.dashboard_outlined, "Dashboard", 1, isTablet),
          _buildNavItem(Icons.delete_outline_rounded, "Dustbins", 2, isTablet),
          _buildNavItem(Icons.post_add, "Post", 3, isTablet),
          _buildNavItem(Icons.request_page_rounded, "Requests", 4, isTablet),

          const Spacer(),

          // Footer section with enhanced animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              );
            },
            child: isSidebarExpanded
                ? Padding(
                    key: const ValueKey('expanded-footer'),
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: accentColor.withOpacity(0.05),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0.8, end: 1.0),
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.elasticOut,
                            builder: (_, double value, Widget? child) {
                              return Transform.scale(
                                scale: value,
                                child: child,
                              );
                            },
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: accentColor.withOpacity(0.2),
                              child: Icon(
                                Icons.person_outline,
                                size: 18,
                                color: accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Admin",
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 13 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    key: const ValueKey('collapsed-footer'),
                    padding: const EdgeInsets.all(16.0),
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.elasticOut,
                      builder: (_, double value, Widget? child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: accentColor.withOpacity(0.2),
                        child: Icon(
                          Icons.person_outline,
                          size: 18,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Enhanced Navigation Item with advanced animations and tablet support
  Widget _buildNavItem(IconData icon, String label, int index, bool isTablet) {
    final isSelected = _selectedIndex == index;
    final accentColor = const Color.fromARGB(255, 106, 0, 255);

    // Get animation controller for this specific nav item
    final animationController = _navItemControllers[index] ?? _scaleController;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutQuint,
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animationController,
          curve: Curves.easeOut,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      accentColor.withOpacity(0.1),
                      accentColor.withOpacity(0.2),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              splashColor: accentColor.withOpacity(0.1),
              highlightColor: accentColor.withOpacity(0.05),
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedIndex = index;
                });
              },
              child: Tooltip(
                message: label,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? 12 : 14,
                    horizontal: isTablet ? 14 : 16,
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        transform: Matrix4.identity(),
                        transformAlignment: Alignment.center,
                        child: Icon(
                          icon,
                          color: isSelected
                              ? accentColor
                              : const Color.fromARGB(255, 0, 0, 0),
                          size: isTablet ? 22 : 24,
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutQuint,
                        child: isSidebarExpanded
                            ? Padding(
                                padding:
                                    EdgeInsets.only(left: isTablet ? 14 : 16),
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 300),
                                  style: _menuTextStyle(isTablet: isTablet)
                                      .copyWith(
                                    color: isSelected
                                        ? accentColor
                                        : const Color.fromARGB(255, 0, 0, 0),
                                    fontSize: isSelected
                                        ? (isTablet ? 15 : 17)
                                        : (isTablet ? 14 : 16),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                  child: Text(label),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      if (isSidebarExpanded && isSelected)
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.elasticOut,
                              builder: (context, double value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: child,
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentColor.withOpacity(0.5),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // COMPLETELY REDESIGNED Mobile Navigation Bar
  Widget _buildMobileNavBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: GNav(
          duration: const Duration(milliseconds: 300), // Animation duration
          selectedIndex: _selectedIndex, // Ensure this is synchronized
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          color: const Color.fromARGB(255, 0, 0, 0),
          activeColor: Colors.white,
          tabBackgroundColor: AppColours().navBarColour,
          hoverColor: AppColours().navBarColour.withOpacity(0.4),
          gap: 8,
          padding: const EdgeInsets.all(16),
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          tabs: [
            GButton(
              icon: Icons.home_outlined,
              text: "Home",
              textStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500, color: Colors.white),
            ),
            GButton(
              icon: Icons.dashboard_outlined,
              text: "Dashboard",
              textStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500, color: Colors.white),
            ),
            GButton(
              icon: Icons.delete_outline_rounded,
              text: "Dustbins",
              textStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500, color: Colors.white),
            ),
            GButton(
              icon: Icons.post_add,
              text: "Post",
              textStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500, color: Colors.white),
            ),
            GButton(
              icon: Icons.request_page_rounded,
              text: "Requests",
              textStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sidebar Text Style with tablet support
  TextStyle _menuTextStyle({bool isTablet = false}) {
    return GoogleFonts.poppins(
      fontSize: isTablet ? 14 : 16,
      fontWeight: FontWeight.w500,
    );
  }

  @override
  void dispose() {
    // Dispose all animation controllers
    _rotationController.dispose();
    _scaleController.dispose();
    _bounceController.dispose();
    _navBarController.dispose();

    // Dispose all nav item controllers
    _navItemControllers.forEach((_, controller) => controller.dispose());

    super.dispose();
  }
}
