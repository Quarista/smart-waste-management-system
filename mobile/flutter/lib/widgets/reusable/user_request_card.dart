import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swms_administration/constants/colours.dart';
import 'package:swms_administration/models/user_request_model.dart';

class UserRequestCard extends StatefulWidget {
  final UserRequest userRequest;
  final bool isReply;
  final void Function(UserRequest, bool) openBottomSheet;
  final String month;
  const UserRequestCard({
    super.key,
    required this.userRequest,
    required this.isReply,
    required this.month,
    required this.openBottomSheet,
  });

  @override
  State<UserRequestCard> createState() => _UserRequestCardState();
}

class _UserRequestCardState extends State<UserRequestCard> {
  @override
  Widget build(BuildContext context) {
    final appColours = AppColours();
    return widget.isReply
        ? Padding(
            padding: EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                  color: appColours.repliedrequestColour1.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: appColours.dustbinCardColour1.withOpacity(0.08),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          appColours.dustbinCardShadowColour.withOpacity(0.01),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 0),
                    ),
                  ]),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 15.0,
                      right: 15,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.userRequest.time.hour.toString().padLeft(2, '0')}:${widget.userRequest.time.minute.toString().padLeft(2, '0')}, ${widget.month} ${widget.userRequest.date.day.toString().padLeft(2, '0')}, ${widget.userRequest.date.year.toString().padLeft(4, '0')}',
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  widget.userRequest.user,
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
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
                              // Container(
                              //   padding: EdgeInsets.all(5),
                              //   height:
                              //       MediaQuery.of(context).size.height * 0.04,
                              //   width: MediaQuery.of(context).size.width * 0.21,
                              //   decoration: BoxDecoration(
                              //     border: Border.all(
                              //       color: appColours.repliedrequestColour2
                              //           .withOpacity(0.4),
                              //       width: 1.3,
                              //     ),
                              //     color: appColours.repliedrequestColour3
                              //         .withOpacity(0.6),
                              //     borderRadius: BorderRadius.circular(100),
                              //   ),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.start,
                              //     children: [
                              //       Spacer(
                              //         flex: 1,
                              //       ),
                              //       Flexible(
                              //         fit: FlexFit.tight,
                              //         flex: 5,
                              //         child: Container(
                              //           decoration: BoxDecoration(
                              //             shape: BoxShape.circle,
                              //             color:
                              //                 appColours.repliedrequestColour2,
                              //           ),
                              //         ),
                              //       ),
                              //       Spacer(
                              //         flex: 1,
                              //       ),
                              //       Flexible(
                              //         fit: FlexFit.tight,
                              //         flex: 9,
                              //         child: Text(
                              //           widget.userRequest.isReplied
                              //               ? 'Replied'
                              //               : 'Received',
                              //           style: GoogleFonts.poppins(
                              //             textStyle: TextStyle(
                              //               fontSize: 11,
                              //               fontWeight: FontWeight.w600,
                              //             ),
                              //           ),
                              //         ),
                              //       )
                              //     ],
                              //   ),
                              // ),
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.04,
                                width: MediaQuery.of(context).size.width * 0.18,
                                decoration: BoxDecoration(
                                  color: appColours.repliedrequestColour3
                                      .withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(
                                    100,
                                  ),
                                  border: Border.all(
                                    color: appColours.repliedrequestColour2
                                        .withOpacity(0.2),
                                    width: 0.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: appColours.mainGreyColour
                                          .withOpacity(0.02),
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2,
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                            0.008,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        fit: FlexFit.tight,
                                        flex: 3,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: appColours
                                                .repliedrequestColour2,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        fit: FlexFit.tight,
                                        flex: 8,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              'Replied',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    appColours.mainTextColour,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  widget.userRequest.isReport == null
                                      ? 'General'
                                      : widget.userRequest.isReport!
                                          ? 'Report'
                                          : 'Support',
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
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
                    color: appColours.mainBlackColour.withOpacity(0.05),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: 40, left: 20, right: 20, top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 1,
                          child: SizedBox(
                            child: Text(
                              widget.userRequest.content,
                              textAlign: TextAlign.left,
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
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
                    color: appColours.mainGreyColour.withOpacity(0.05),
                    thickness: 2,
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
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
                                ),
                              ),
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.008,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
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
                              widget.userRequest.reply!,
                              maxLines: 5,
                              textAlign: TextAlign.left,
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  overflow: TextOverflow.fade,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
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
          )
        : Padding(
            padding: EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                  color: appColours.recievedrequestColour2.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: appColours.dustbinCardColour1.withOpacity(0.08),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          appColours.dustbinCardShadowColour.withOpacity(0.01),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 0),
                    ),
                  ]),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 15.0,
                      right: 15,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.userRequest.time.hour.toString().padLeft(2, '0')}:${widget.userRequest.time.minute.toString().padLeft(2, '0')}, ${widget.month} ${widget.userRequest.date.day.toString().padLeft(2, '0')}, ${widget.userRequest.date.year.toString().padLeft(4, '0')}',
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  widget.userRequest.user,
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
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
                              // Container(
                              //   padding: EdgeInsets.all(5),
                              //   height:
                              //       MediaQuery.of(context).size.height * 0.04,
                              //   width: MediaQuery.of(context).size.width * 0.21,
                              //   decoration: BoxDecoration(
                              //     border: Border.all(
                              //       color: appColours.recievedrequestColour2
                              //           .withOpacity(0.8),
                              //       width: 1.3,
                              //     ),
                              //     color: appColours.recievedrequestColour2
                              //         .withOpacity(0.5),
                              //     borderRadius: BorderRadius.circular(100),
                              //   ),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.start,
                              //     children: [
                              //       Spacer(
                              //         flex: 1,
                              //       ),
                              //       Flexible(
                              //         fit: FlexFit.tight,
                              //         flex: 5,
                              //         child: Container(
                              //           decoration: BoxDecoration(
                              //             shape: BoxShape.circle,
                              //             color:
                              //                 appColours.recievedrequestColour3,
                              //           ),
                              //         ),
                              //       ),
                              //       Spacer(
                              //         flex: 1,
                              //       ),
                              //       Flexible(
                              //         fit: FlexFit.tight,
                              //         flex: 9,
                              //         child: Text(
                              //           widget.userRequest.isReplied
                              //               ? 'Replied'
                              //               : 'Received',
                              //           style: GoogleFonts.poppins(
                              //             textStyle: TextStyle(
                              //               fontSize: 11,
                              //               fontWeight: FontWeight.w600,
                              //             ),
                              //           ),
                              //         ),
                              //       )
                              //     ],
                              //   ),
                              // ),
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.04,
                                width: MediaQuery.of(context).size.width * 0.18,
                                decoration: BoxDecoration(
                                  color: appColours.recievedrequestColour2
                                      .withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(
                                    100,
                                  ),
                                  border: Border.all(
                                    color: appColours.recievedrequestColour2
                                        .withOpacity(0.2),
                                    width: 0.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: appColours.mainGreyColour
                                          .withOpacity(0.02),
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2,
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                            0.008,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        fit: FlexFit.tight,
                                        flex: 3,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: appColours
                                                .recievedrequestColour3,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        fit: FlexFit.tight,
                                        flex: 8,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              'Recieved',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    appColours.mainTextColour,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  widget.userRequest.isReport == null
                                      ? 'General'
                                      : widget.userRequest.isReport!
                                          ? 'Report'
                                          : 'Support',
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
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
                    color: appColours.mainBlackColour.withOpacity(0.05),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: 40, left: 20, right: 20, top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 1,
                          child: SizedBox(
                            child: Text(
                              widget.userRequest.content,
                              textAlign: TextAlign.left,
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
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
                    color: appColours.mainBlackColour.withOpacity(0.025),
                    thickness: 2,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 5,
                      left: 20,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        widget.openBottomSheet(
                          widget.userRequest,
                          false,
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Reply',
                                textAlign: TextAlign.left,
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                overflow: TextOverflow.fade,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.05,
                                height:
                                    MediaQuery.of(context).size.width * 0.05,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.edit_note_rounded,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
