import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swms_administration/constants/colours.dart';
import 'package:swms_administration/constants/text_styles.dart';
import 'package:swms_administration/models/user_request_model.dart';
import 'package:swms_administration/router/router.dart';
import 'package:swms_administration/services/user_request_services.dart';
import 'package:swms_administration/widgets/reusable/user_request_card.dart';

class UserRequestsPageDesktop extends StatefulWidget {
  const UserRequestsPageDesktop({super.key});

  @override
  State<UserRequestsPageDesktop> createState() =>
      _UserRequestsPageDesktopState();
}

class _UserRequestsPageDesktopState extends State<UserRequestsPageDesktop>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late UserRequestServices _userRequestServices;
  List<UserRequest> _filteredRequests = [];
  late TabController _tabController;
  List<UserRequest> repliedUserRequests = [];
  List<UserRequest> receivedUserRequests = [];
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
    });
  }

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
                                      color: colours.mainBlackColour
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
    final AppColours appColours = AppColours();
    return Scaffold(
      backgroundColor: AppColours().scaffoldColour,
      appBar: AppBar(
        title: Text(
          'User Requests',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: AppColours().scaffoldColour,
        bottom: PreferredSize(
          preferredSize: Size(0, 55),
          child: Container(
            color: AppColours().scaffoldColour,
            child: TabBar(
              labelPadding: EdgeInsets.zero,
              labelStyle: GoogleFonts.poppins(
                textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              controller: _tabController,
              indicatorColor: Colors.transparent,
              labelColor: AppColours().mainBlackColour,
              unselectedLabelColor: appColours.mainBlackColour,
              tabs: [
                Tab(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          appColours.recievedrequestColour1.withOpacity(0.03),
                      border: Border.symmetric(
                        vertical: BorderSide(
                          width: 0.2,
                          color: appColours.requestCardColour1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 8,
                          child: Center(
                            child: Text(
                              "${receivedUserRequests.length} Received",
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: appColours.repliedrequestColour1.withOpacity(0.03),
                      border: Border.symmetric(
                        vertical: BorderSide(
                          width: 0.2,
                          color: appColours.requestCardColour1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 8,
                          child: Center(
                            child: Text(
                              "${repliedUserRequests.length} Replied",
                              overflow: TextOverflow.fade,
                            ),
                          ),
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
      body: Row(
        children: [
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: SingleChildScrollView(
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
                    return UserRequestCard(
                      userRequest: userRequest,
                      isReply: false,
                      month: month,
                      openBottomSheet: openBottomSheet,
                    );
                  },
                ),
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: repliedUserRequests.length,
                  itemBuilder: (context, index) {
                    final UserRequest userRequest = repliedUserRequests[index];
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
                    return UserRequestCard(
                      userRequest: userRequest,
                      isReply: true,
                      month: month,
                      openBottomSheet: openBottomSheet,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
