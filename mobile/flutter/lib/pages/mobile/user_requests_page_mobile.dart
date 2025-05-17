import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swms_administration/constants/colours.dart';
import 'package:swms_administration/constants/text_styles.dart';
import 'package:swms_administration/models/user_request_model.dart';
import 'package:swms_administration/router/router.dart';
import 'package:swms_administration/services/user_request_services.dart';

class UserRequestsPageMobile extends StatefulWidget {
  const UserRequestsPageMobile({super.key});

  @override
  State<UserRequestsPageMobile> createState() => _UserRequestsPageMobileState();
}

class _UserRequestsPageMobileState extends State<UserRequestsPageMobile>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late UserRequestServices _userRequestServices;
  List<UserRequest> _filteredRequests = [];
  late TabController _tabController;
  List<UserRequest> repliedUserRequests = [];
  List<UserRequest> receivedUserRequests = [];

  @override
  void initState() {
    super.initState();
    _userRequestServices = UserRequestServices();
    //Setup initial requests list
    _filteredRequests = _userRequestServices.allRequests;
    // Add listener to the search controller
    _searchController.addListener(_filterRequests);

    // Listen to changes from UserRequestServices
    _userRequestServices.addListener(_onRequestsUpdated);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filterRequests();
    });
    sortRequests();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging || _tabController.index != null) {
        setState(() {}); // Trigger rebuild on tab change or swipe
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterRequests);
    _searchController.dispose();
    _userRequestServices.removeListener(_onRequestsUpdated);
    _userRequestServices.dispose();
    _tabController.dispose();
    _replyController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Update filtered requests when UserRequestServices updates
  void _onRequestsUpdated() {
    setState(() {
      _filterRequests();
      sortRequests();
    });
  }

  //Filter requests based on search text
  void _filterRequests() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredRequests = _userRequestServices.allRequests;
      } else {
        _filteredRequests =
            _userRequestServices.searchRequests(_searchController.text);
      }
      sortRequests();
    });
  }

  void sortRequests() {
    repliedUserRequests = _filteredRequests
        .where(
          (request) => request.isReplied,
        )
        .toList();
    repliedUserRequests.sort(
      (a, b) => b.date.compareTo(a.date),
    );
    receivedUserRequests = _filteredRequests
        .where(
          (request) => !request.isReplied,
        )
        .toList();
    receivedUserRequests.sort(
      (a, b) => a.date.compareTo(b.date),
    );
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController _replyController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  void openBottomSheet(UserRequest request, bool isEdit) {
    final AppColours colours = AppColours(); // Access theme colors
    if (isEdit) {
      _replyController = TextEditingController(text: request.reply);
    }
    showModalBottomSheet(
        barrierColor: colours.mainBlackColour.withOpacity(0.7),
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {
              RouterClass.router.pop(context);
              _replyController.text = '';
              _nameController.text = '';
            },
            constraints: BoxConstraints.expand(
                height: MediaQuery.of(context).size.height * 0.95),
            builder: (context) {
              return Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.95,
                decoration: BoxDecoration(
                  color: colours.mainWhiteColour.withOpacity(0.9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Specify unknown if you want to reply as anonymous',
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    color: colours.mainBlackColour
                                        .withOpacity(0.4),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: colours.mainWhiteColour,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colours.mainWhiteColour
                                          .withOpacity(0.1),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    hintText: 'Your Name Here...',
                                    hintStyle: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        color: colours.mainBlackColour
                                            .withOpacity(0.5),
                                        fontSize: 16,
                                      ),
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
                                      color: colours.mainBlackColour,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(
                          flex: 1,
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 6,
                          child: Container(
                            decoration: BoxDecoration(
                              color: colours.mainWhiteColour,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      colours.mainBlackColour.withOpacity(0.1),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _replyController,
                              decoration: InputDecoration(
                                hintText: 'Your Reply Here...',
                                hintStyle: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    color: colours.mainBlackColour
                                        .withOpacity(0.5),
                                    fontSize: 16,
                                  ),
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
                                  color: colours.mainBlackColour,
                                  fontSize: 16,
                                ),
                              ),
                              validator: (value) {
                                if ((value!.trim().isEmpty && value.isEmpty) ||
                                    value.trim().isEmpty) {
                                  return 'Please Enter the Content!';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        Spacer(flex: 1),
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Spacer(flex: 4),
                              Flexible(
                                fit: FlexFit.tight,
                                flex: 3,
                                child: GestureDetector(
                                  onTap: () async {
                                    try {
                                      final _firestore =
                                          FirebaseFirestore.instance;
                                      if (_formKey.currentState!.validate()) {
                                        int? docNo;
                                        final String postUninitialized =
                                            'uninitialized';
                                        Future<void> getPostCount() async {
                                          final QuerySnapshot snapshot =
                                              await _firestore
                                                  .collection('email_requests')
                                                  .get();
                                          docNo = snapshot.docs.length + 1;
                                        }

                                        final String finalEmail =
                                            '${_nameController.text.isEmpty || _nameController.text.toLowerCase() == 'unknown' ? 'An Unknown' : _nameController.text} from the Waste Management System replied to your following ${request.isReport == null ? 'General Request' : request.isReport! ? 'Bug Report' : 'Support Request'} sent via the system website: \n \n${request.content}\n \n \n \n${_replyController.text}\n \n \n \n \n \n \n \n EquaBin™ \n __________ \n \n \nIf you think this email is not relevant to you, please accept our apologies and ignore this email.';
                                        await getPostCount();
                                        await _firestore
                                            .collection('email_requests')
                                            .doc(
                                                'email reply ${docNo ?? postUninitialized}')
                                            .set({
                                          'subject':
                                              'Reply to ${request.user} by ${_nameController.text.isEmpty || _nameController.text.toLowerCase() == 'unknown' ? 'An Unknown' : _nameController.text} from the Admin Panel - EquaBin',
                                          'recipient': request.email,
                                          'timestamp':
                                              FieldValue.serverTimestamp(),
                                          'body': finalEmail.replaceAll(
                                              r'\n', '\n'),
                                          'status': 'pending',
                                          'request':
                                              'email reply ${docNo ?? postUninitialized}',
                                        });
                                        await _firestore
                                            .collection('user_submissions')
                                            .doc(request.id)
                                            .update({
                                          'replied': true,
                                          'reply': _replyController.text,
                                        });

                                        RouterClass.router.pop();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Request for your email has been sent! It may take a while to be delivered!',
                                              style: GoogleFonts.poppins(),
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor:
                                                AppColours().mainThemeColour,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                            ),
                                          ),
                                        );
                                        _nameController.text = '';
                                        _replyController.text = '';
                                      }
                                      // if (context.mounted) {
                                      //   RouterClass.router.pop(context);
                                      //   showDialog(
                                      //     context: context,
                                      //     builder: (context) => AlertDialog(
                                      //       title:
                                      //           Text('Daily Limit Reached!'),
                                      //       backgroundColor:
                                      //           AppColours().mainWhiteColour,
                                      //       titleTextStyle: AppTextStyles()
                                      //           .subtitleStyleMobile
                                      //           .copyWith(
                                      //             color: Colors.blue,
                                      //           ),
                                      //       titlePadding: EdgeInsets.all(10),
                                      //       contentTextStyle:
                                      //           AppTextStyles().bodyTextStyle,
                                      //       content: Column(
                                      //         children: [
                                      //           Text(
                                      //               'You organization\'s daily limit for replying has been reached. \nPlease try again later!'),
                                      //           TextButton(
                                      //             onPressed: () =>
                                      //                 Navigator.pop(context),
                                      //             style: ButtonStyle(
                                      //               maximumSize: WidgetStatePropertyAll(Size.fromHeight(MediaQuery.of(context).size.height*0.3)),
                                      //               textStyle:
                                      //                   WidgetStatePropertyAll(
                                      //                 AppTextStyles()
                                      //                     .buttonTextStyle
                                      //                     .copyWith(
                                      //                         color: Colors
                                      //                             .blue),
                                      //               ),
                                      //               backgroundColor: WidgetStatePropertyAll(AppColours().mainWhiteColour),
                                      //             ),
                                      //             child: Text(
                                      //                 'Do not send', style:AppTextStyles().buttonTextStyle
                                      //                     .copyWith(
                                      //                         color: Colors
                                      //                             .blue) ,),
                                      //           ),
                                      //         ],
                                      //       ),
                                      //     ),
                                      //   );
                                      // }
                                    } catch (e) {
                                      RouterClass.router.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error while sending the reply!',
                                            style: GoogleFonts.poppins(),
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 5,
                                    ),
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    height: MediaQuery.of(context).size.height *
                                        0.045,
                                    decoration: BoxDecoration(
                                      color: colours.mainThemeColour,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          "Send Reply",
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                              color: colours.mainWhiteColour,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
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
                ),
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final AppColours colours = AppColours(); // Access theme colors
    return Scaffold(
      backgroundColor: colours.mainWhiteColour,
      appBar: AppBar(
        toolbarHeight: 110,
        title: Text(
          'User Requests',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: colours.mainTextColour,
            ),
          ),
        ),
        backgroundColor: colours.mainWhiteColour,
        bottom: PreferredSize(
          preferredSize: Size(0, 55),
          child: Container(
            color: colours.mainWhiteColour,
            child: TabBar(
              controller: _tabController,
              onTap: (index) {
                setState(() {}); // Explicitly trigger rebuild on tab tap
              },
              labelPadding: EdgeInsets.zero,
              labelStyle: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colours.mainTextColour,
                ),
              ),
              indicatorColor: Colors.transparent,
              labelColor: colours.mainTextColour,
              unselectedLabelColor: colours.mainTextColour.withOpacity(0.6),
              tabs: [
                Tab(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 50),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _tabController.index == 0
                            ? colours.mainThemeColour.withOpacity(0.1)
                            : colours.mainWhiteColour,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(14),
                          bottomLeft: Radius.circular(14),
                        ),
                        border: Border.all(
                          width: 0.5,
                          color: colours.containerShadowColour,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colours.containerShadowColour,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(
                            flex: 2,
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 2,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.039,
                              height: MediaQuery.of(context).size.width * 0.039,
                              decoration: BoxDecoration(
                                color: AppColours().recievedrequestColour1,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const Spacer(
                            flex: 1,
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 8,
                            child: Text(
                              "${receivedUserRequests.length} Received",
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 50),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _tabController.index == 1
                            ? colours.mainThemeColour.withOpacity(0.1)
                            : colours.mainWhiteColour,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                        border: Border.all(
                          width: 0.5,
                          color: colours.containerShadowColour,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colours.containerShadowColour,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(
                            flex: 2,
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 2,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.039,
                              height: MediaQuery.of(context).size.width * 0.039,
                              decoration: BoxDecoration(
                                color: AppColours().repliedrequestColour1,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const Spacer(
                            flex: 1,
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 8,
                            child: Text(
                              "${repliedUserRequests.length} Replied",
                              overflow: TextOverflow.fade,
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
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(), // Disable swipe gestures
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
                itemCount: receivedUserRequests.length,
                itemBuilder: (context, index) {
                  final UserRequest userRequest = receivedUserRequests[index];
                  String getMonth(int month) {
                    if (month == 1) {
                      return 'Jan';
                    } else if (month == 2) {
                      return 'Feb';
                    } else if (month == 3) {
                      return 'Mar';
                    } else if (month == 4) {
                      return 'Apr';
                    } else if (month == 5) {
                      return 'May';
                    } else if (month == 6) {
                      return 'Jun';
                    } else if (month == 7) {
                      return 'Jul';
                    } else if (month == 8) {
                      return 'Aug';
                    } else if (month == 9) {
                      return 'Sep';
                    } else if (month == 10) {
                      return 'Oct';
                    } else if (month == 11) {
                      return 'Nov';
                    } else if (month == 12) {
                      return 'Dec';
                    } else {
                      return 'null';
                    }
                  }

                  final String month = getMonth(userRequest.date.month);
                  return Padding(
                    padding: EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: colours.containerShadowColour,
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: colours.containerShadowColour,
                          width: 0.5,
                        ),
                        color: colours.mainWhiteColour,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              right: 5,
                              left: 5,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 8,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8.0,
                                      right: 8,
                                      left: 8,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${userRequest.time.hour.toString().padLeft(2, '0')}:${userRequest.time.minute.toString().padLeft(2, '0')}, $month ${userRequest.date.day.toString().padLeft(2, '0')}, ${userRequest.date.year.toString().padLeft(4, '0')}',
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: colours.mainTextColour,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 6,
                                        ),
                                        Text(
                                          userRequest.user,
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                              color: colours.valueColour,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Spacer(
                                  flex: 5,
                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.04,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.26,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColours()
                                                .recievedrequestColour2
                                                .withOpacity(0.8),
                                            width: 1.3,
                                          ),
                                          color: AppColours()
                                              .recievedrequestColour2
                                              .withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Spacer(
                                              flex: 1,
                                            ),
                                            Flexible(
                                              fit: FlexFit.tight,
                                              flex: 3,
                                              child: Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.027,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.027,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColours()
                                                      .recievedrequestColour3,
                                                ),
                                              ),
                                            ),
                                            Spacer(
                                              flex: 1,
                                            ),
                                            Flexible(
                                              fit: FlexFit.tight,
                                              flex: 9,
                                              child: AutoSizeText(
                                                userRequest.isReplied
                                                    ? 'Replied'
                                                    : 'Received',
                                                style: GoogleFonts.poppins(
                                                  textStyle: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        colours.mainTextColour,
                                                  ),
                                                ),
                                                maxLines: 1,
                                                minFontSize: 10,
                                                overflow: TextOverflow.fade,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Text(
                                          userRequest.isReport == null
                                              ? 'General'
                                              : userRequest.isReport!
                                                  ? 'Report'
                                                  : 'Support',
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: colours.mainTextColour,
                                            ),
                                          ),
                                          overflow: TextOverflow.fade,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Divider(
                            color: colours.containerShadowColour,
                            thickness: 1,
                            indent: 20,
                            endIndent: 20,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20, // Reduced horizontal padding
                              vertical: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 1,
                                  child: SizedBox(
                                    child: Text(
                                      userRequest.content,
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: colours.valueColour,
                                        ),
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: colours.containerShadowColour,
                            thickness: 1.5,
                            indent: 15,
                            endIndent: 15,
                            height: 20,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              right: 20, // Reduced horizontal padding
                              left: 20, // Reduced horizontal padding
                            ),
                            child: GestureDetector(
                              onTap: () {
                                openBottomSheet(
                                  userRequest,
                                  false,
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 5,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Reply',
                                          textAlign: TextAlign.left,
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: colours.mainTextColour,
                                            ),
                                          ),
                                          overflow: TextOverflow.fade,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 1,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.1,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.08,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.edit_note_rounded,
                                          size: 28,
                                          color: colours.mainTextColour,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
                itemCount: repliedUserRequests.length,
                itemBuilder: (context, index) {
                  final UserRequest userRequest = repliedUserRequests[index];
                  final String reply = userRequest.reply!;
                  String getMonth(int month) {
                    if (month == 1) {
                      return 'Jan';
                    } else if (month == 2) {
                      return 'Feb';
                    } else if (month == 3) {
                      return 'Mar';
                    } else if (month == 4) {
                      return 'Apr';
                    } else if (month == 5) {
                      return 'May';
                    } else if (month == 6) {
                      return 'Jun';
                    } else if (month == 7) {
                      return 'Jul';
                    } else if (month == 8) {
                      return 'Aug';
                    } else if (month == 9) {
                      return 'Sep';
                    } else if (month == 10) {
                      return 'Oct';
                    } else if (month == 11) {
                      return 'Nov';
                    } else if (month == 12) {
                      return 'Dec';
                    } else {
                      return 'null';
                    }
                  }

                  final String month = getMonth(userRequest.date.month);
                  return Padding(
                    padding: EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: colours.containerShadowColour,
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: colours.containerShadowColour,
                          width: 0.5,
                        ),
                        color: colours.mainWhiteColour,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              right: 5,
                              left: 5,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 8,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8.0,
                                      right: 8,
                                      left: 8,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${userRequest.time.hour.toString().padLeft(2, '0')}:${userRequest.time.minute.toString().padLeft(2, '0')}, $month ${userRequest.date.day.toString().padLeft(2, '0')}, ${userRequest.date.year.toString().padLeft(4, '0')}',
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: colours.mainTextColour,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 6,
                                        ),
                                        Text(
                                          userRequest.user,
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                              color: colours.valueColour,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Spacer(
                                  flex: 5,
                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.04,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.21,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColours()
                                                .repliedrequestColour2
                                                .withOpacity(0.4),
                                            width: 1.3,
                                          ),
                                          color: AppColours()
                                              .repliedrequestColour3
                                              .withOpacity(0.6),
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Spacer(
                                              flex: 1,
                                            ),
                                            Flexible(
                                              fit: FlexFit.tight,
                                              flex: 3,
                                              child: Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.027,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.027,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColours()
                                                      .mainThemeColour,
                                                ),
                                              ),
                                            ),
                                            Spacer(
                                              flex: 1,
                                            ),
                                            Flexible(
                                              fit: FlexFit.tight,
                                              flex: 9,
                                              child: AutoSizeText(
                                                userRequest.isReplied
                                                    ? 'Replied'
                                                    : 'Received',
                                                style: GoogleFonts.poppins(
                                                  textStyle: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        colours.mainTextColour,
                                                  ),
                                                ),
                                                maxLines: 1,
                                                minFontSize: 10,
                                                overflow: TextOverflow.fade,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Text(
                                          userRequest.isReport == null
                                              ? 'General'
                                              : userRequest.isReport!
                                                  ? 'Report'
                                                  : 'Support',
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: colours.mainTextColour,
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
                          Divider(
                            color: colours.containerShadowColour,
                            thickness: 1,
                            indent: 20,
                            endIndent: 20,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 30, // Increased horizontal padding
                              vertical: 20,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 1,
                                  child: SizedBox(
                                    child: Text(
                                      userRequest.content,
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: colours.valueColour,
                                        ),
                                      ),
                                      softWrap: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: colours.containerShadowColour,
                            thickness: 1.5,
                            indent: 15,
                            endIndent: 15,
                            height: 20,
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Spacer(
                                    flex: 1,
                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 20,
                                    child: Text(
                                      'Reply',
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: colours.mainTextColour,
                                        ),
                                      ),
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.008,
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30, // Increased horizontal padding
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Spacer(
                                  flex: 2,
                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 28,
                                  child: SizedBox(
                                    child: Text(
                                      reply,
                                      maxLines: 5,
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          overflow: TextOverflow.fade,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: colours.valueColour,
                                        ),
                                      ),
                                      softWrap: true,
                                    ),
                                  ),
                                ),
                                Spacer(
                                  flex: 1,
                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [],
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 18,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
