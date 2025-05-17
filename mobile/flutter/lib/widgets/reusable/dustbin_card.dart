import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swms_administration/constants/colours.dart';
import 'package:swms_administration/models/bin_model.dart';
import 'package:swms_administration/router/router.dart';

class DustbinCard extends StatelessWidget {
  final Bin bin;
  final Map<String, String> binDetails;
  final BuildContext context;
  final bool isDesktop;
  const DustbinCard({
    super.key,
    required this.bin,
    required this.binDetails,
    required this.context,
    required this.isDesktop,
  });
  Widget _buildImage() {
    if (bin.imageUrl.startsWith('http') || bin.imageUrl.startsWith('data')) {
      return _buildNetworkImage(bin.imageUrl);
    } else if (bin.imageUrl == 'assets/images/Pagama.png') {
      return Image.asset(
        bin.imageUrl,
        fit: BoxFit.fill,
      );
    } else {
      return _buildBase64Image(base64Decode(bin.imageUrl));
    }
  }

  Widget _buildBase64Image(Uint8List data) {
    try {
      final bytes = data;
      return Image.memory(
        bytes,
        fit: BoxFit.fill,
      );
    } catch (e) {
      return _errorWidget();
    }
  }

  Widget _buildNetworkImage(String url) {
    return Image.network(
      url,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: child,
        );
      },
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        return Center(child: child);
      },
      fit: BoxFit.fill,
      errorBuilder: (context, error, stackTrace) {
        return _errorWidget();
      },
    );
  }

  Widget _errorWidget() {
    final appColours = AppColours();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: appColours.mainBlackColour.withOpacity(0.1),
          border: Border.all(
            color: appColours.mainBlackColour.withOpacity(0.02),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: appColours.dustbinCardShadowColour,
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
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
            child: Icon(
              Icons.image,
              color: appColours.mainWhiteColour,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    final appColours = AppColours();
    return isDesktop
        ? Padding(
            padding: EdgeInsets.only(
              top: height * 0.015,
            ),
            child: Container(
              height: height * 0.19,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: appColours.mainWhiteColour,
                border: Border.all(
                  color: appColours.mainGreyColour.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: appColours.mainGreyColour.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: SizedBox(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildImage(),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Spacer(
                                        flex: 2,
                                      ),
                                      Flexible(
                                        fit: FlexFit.tight,
                                        flex: 1,
                                        child: Container(
                                          width: width * 0.1,
                                          height: height * 0.025,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              100,
                                            ),
                                            color: appColours.mainWhiteColour
                                                .withOpacity(0.1),
                                            border: Border.all(
                                              color: appColours.mainGreyColour
                                                  .withOpacity(
                                                0.3,
                                              ),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: appColours.mainGreyColour
                                                    .withOpacity(0.2),
                                                spreadRadius: 1,
                                                blurRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: AutoSizeText(
                                              bin.type,
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: appColours
                                                    .dustbinCardColour1,
                                              ),
                                              maxLines: 1,
                                              minFontSize: 6,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 1,
                                  child: AutoSizeText(
                                    bin.name,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: appColours.mainBlackColour,
                                    ),
                                    maxLines: 1,
                                    minFontSize: 6,
                                  ),
                                ),
                                SizedBox(height: height * 0.018),
                                bin.fillStatus
                                    ? Flexible(
                                        fit: FlexFit.tight,
                                        flex: 1,
                                        child: Row(
                                          children: [
                                            Flexible(
                                              fit: FlexFit.tight,
                                              flex: 6,
                                              child: Container(
                                                width: width * 0.17,
                                                decoration: BoxDecoration(
                                                  color: appColours.errorColour
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    100,
                                                  ),
                                                  border: Border.all(
                                                    color: appColours
                                                        .errorColour
                                                        .withOpacity(0.2),
                                                    width: 0.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: appColours
                                                          .mainGreyColour
                                                          .withOpacity(0.2),
                                                      spreadRadius: 1,
                                                      blurRadius: 2,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 2,
                                                    vertical: height * 0.004,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        fit: FlexFit.tight,
                                                        flex: 3,
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                context,
                                                              ).size.width *
                                                              0.027,
                                                          height: MediaQuery.of(
                                                                context,
                                                              ).size.width *
                                                              0.027,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: appColours
                                                                .errorColour,
                                                          ),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        fit: FlexFit.tight,
                                                        flex: 8,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 12.8,
                                                          ),
                                                          child: FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: Text(
                                                              'Filled',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: appColours
                                                                    .dustbinCardRedColour1,
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
                                            Spacer(
                                              flex: 7,
                                            ),
                                          ],
                                        ),
                                      )
                                    : Flexible(
                                        fit: FlexFit.tight,
                                        flex: 1,
                                        child: Row(
                                          children: [
                                            Flexible(
                                              fit: FlexFit.tight,
                                              flex: 6,
                                              child: Container(
                                                width: width * 0.17,
                                                decoration: BoxDecoration(
                                                  color: appColours
                                                      .dustbinCardGreenColour1
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    100,
                                                  ),
                                                  border: Border.all(
                                                    color: appColours
                                                        .dustbinCardGreenColour2
                                                        .withOpacity(0.2),
                                                    width: 0.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: appColours
                                                          .mainGreyColour
                                                          .withOpacity(0.2),
                                                      spreadRadius: 1,
                                                      blurRadius: 2,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 2,
                                                    vertical: height * 0.004,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        fit: FlexFit.tight,
                                                        flex: 3,
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                context,
                                                              ).size.width *
                                                              0.027,
                                                          height: MediaQuery.of(
                                                                context,
                                                              ).size.width *
                                                              0.027,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: appColours
                                                                .dustbinCardGreenColour2,
                                                          ),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        fit: FlexFit.tight,
                                                        flex: 8,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      4.0),
                                                          child: FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: Text(
                                                              'Available',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: appColours
                                                                    .dustbinCardGreenColour2,
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
                                            Spacer(
                                              flex: 7,
                                            ),
                                          ],
                                        ),
                                      ),
                                SizedBox(height: height * 0.01),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      bin.isClosed
                                          ? Flexible(
                                              fit: FlexFit.tight,
                                              flex: 6,
                                              child: Container(
                                                width: width * 0.17,
                                                decoration: BoxDecoration(
                                                  color: appColours.errorColour
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    100,
                                                  ),
                                                  border: Border.all(
                                                    color: appColours
                                                        .errorColour
                                                        .withOpacity(0.2),
                                                    width: 0.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: appColours
                                                          .mainGreyColour
                                                          .withOpacity(0.2),
                                                      spreadRadius: 1,
                                                      blurRadius: 2,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 2,
                                                    vertical: height * 0.004,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        fit: FlexFit.tight,
                                                        flex: 3,
                                                        child: Container(
                                                          width: width * 0.027,
                                                          height: width * 0.027,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: appColours
                                                                .errorColour,
                                                          ),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        fit: FlexFit.tight,
                                                        flex: 8,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 9,
                                                          ),
                                                          child: FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: Text(
                                                              'Closed',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: appColours
                                                                    .dustbinCardRedColour1,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Flexible(
                                              fit: FlexFit.tight,
                                              flex: 6,
                                              child: Container(
                                                width: width * 0.17,
                                                decoration: BoxDecoration(
                                                  color: appColours
                                                      .dustbinCardGreenColour1
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    100,
                                                  ),
                                                  border: Border.all(
                                                    color: appColours
                                                        .dustbinCardGreenColour2
                                                        .withOpacity(0.2),
                                                    width: 0.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: appColours
                                                          .mainGreyColour
                                                          .withOpacity(0.2),
                                                      spreadRadius: 1,
                                                      blurRadius: 2,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 2,
                                                    vertical: height * 0.004,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        fit: FlexFit.tight,
                                                        flex: 3,
                                                        child: Container(
                                                          width: width * 0.027,
                                                          height: width * 0.027,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: appColours
                                                                .dustbinCardGreenColour2,
                                                          ),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        fit: FlexFit.tight,
                                                        flex: 8,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 12.5,
                                                          ),
                                                          child: FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: Text(
                                                              'Open',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: appColours
                                                                    .dustbinCardGreenColour2,
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
                                      Spacer(
                                        flex: 7,
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Tooltip(
                                        message: 'View Bin',
                                        child: GestureDetector(
                                          onTap: () {
                                            RouterClass.router.push(
                                              '/bind',
                                              extra: binDetails,
                                            );
                                          },
                                          child: Container(
                                            height: 20,
                                            width: 20,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: appColours.mainGreyColour
                                                    .withOpacity(0.6),
                                                width: 1,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: appColours
                                                      .mainBlackColour
                                                      .withOpacity(0.02),
                                                  spreadRadius: 1,
                                                  blurRadius: 1,
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.arrow_forward,
                                                size: 13,
                                                color: appColours.mainGreyColour
                                                    .withOpacity(
                                                  0.6,
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
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        : Padding(
            padding: EdgeInsets.only(
              top: height * 0.015,
            ),
            child: Container(
              height: height * 0.19,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: appColours.mainWhiteColour,
                border: Border.all(
                  color: appColours.mainGreyColour.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: appColours.mainGreyColour.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: SizedBox(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildImage(),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 1,
                                  child: bin.isSub && !(bin.mainBin == '')
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Spacer(
                                              flex: 5,
                                            ),
                                            Flexible(
                                              fit: FlexFit.tight,
                                              flex: 7,
                                              child: Container(
                                                width: width * 0.1,
                                                height: height * 0.025,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    100,
                                                  ),
                                                  color: appColours
                                                      .mainGreyColour
                                                      .withOpacity(0.1),
                                                  border: Border.all(
                                                    color: appColours
                                                        .mainGreyColour
                                                        .withOpacity(
                                                      0.3,
                                                    ),
                                                    width: 1,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: appColours
                                                          .mainGreyColour
                                                          .withOpacity(0.08),
                                                      spreadRadius: 1,
                                                      blurRadius: 2,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: AutoSizeText(
                                                    '${bin.type} of ${bin.mainBin}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: appColours
                                                          .dustbinCardColour1,
                                                    ),
                                                    maxLines: 1,
                                                    minFontSize: 6,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Spacer(
                                              flex: 2,
                                            ),
                                            Flexible(
                                              fit: FlexFit.tight,
                                              flex: 1,
                                              child: Container(
                                                width: width * 0.1,
                                                height: height * 0.025,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    100,
                                                  ),
                                                  color: appColours
                                                      .mainGreyColour
                                                      .withOpacity(0.1),
                                                  border: Border.all(
                                                    color: appColours
                                                        .mainGreyColour
                                                        .withOpacity(
                                                      0.3,
                                                    ),
                                                    width: 1,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: appColours
                                                          .mainGreyColour
                                                          .withOpacity(0.1),
                                                      spreadRadius: 1,
                                                      blurRadius: 2,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: AutoSizeText(
                                                    bin.type,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: appColours
                                                          .dustbinCardColour1,
                                                    ),
                                                    maxLines: 1,
                                                    minFontSize: 6,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 1,
                                  child: AutoSizeText(
                                    bin.name,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: appColours.mainBlackColour,
                                    ),
                                    maxLines: 1,
                                    minFontSize: 6,
                                  ),
                                ),
                                SizedBox(height: height * 0.018),
                                bin.fillStatus
                                    ? Flexible(
                                        fit: FlexFit.tight,
                                        flex: 1,
                                        child: Row(
                                          children: [
                                            Flexible(
                                              fit: FlexFit.tight,
                                              flex: 5,
                                              child: Container(
                                                width: width * 0.17,
                                                decoration: BoxDecoration(
                                                  color: appColours.errorColour
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    100,
                                                  ),
                                                  border: Border.all(
                                                    color: appColours
                                                        .errorColour
                                                        .withOpacity(0.5),
                                                    width: 0.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: appColours
                                                          .mainGreyColour
                                                          .withOpacity(0.1),
                                                      spreadRadius: 1,
                                                      blurRadius: 2,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 2,
                                                    vertical: height * 0.004,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        fit: FlexFit.tight,
                                                        flex: 3,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: appColours
                                                                .dustbinCardRedColour2,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: appColours
                                                                    .mainGreyColour
                                                                    .withOpacity(
                                                                        0.1),
                                                                spreadRadius: 1,
                                                                blurRadius: 2,
                                                                offset: Offset(
                                                                    0, 3),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        fit: FlexFit.tight,
                                                        flex: 8,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      14.2),
                                                          child: FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: Text(
                                                              'Filled',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: appColours
                                                                    .dustbinCardRedColour3
                                                                    .withOpacity(
                                                                        0.9),
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
                                            Spacer(
                                              flex: 7,
                                            ),
                                          ],
                                        ),
                                      )
                                    : Flexible(
                                        fit: FlexFit.tight,
                                        flex: 1,
                                        child: Row(
                                          children: [
                                            Flexible(
                                              fit: FlexFit.tight,
                                              flex: 5,
                                              child: Container(
                                                width: width * 0.17,
                                                decoration: BoxDecoration(
                                                  color: appColours
                                                      .dustbinCardGreenColour1
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    100,
                                                  ),
                                                  border: Border.all(
                                                    color: appColours
                                                        .dustbinCardGreenColour2
                                                        .withOpacity(0.5),
                                                    width: 0.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: appColours
                                                          .mainGreyColour
                                                          .withOpacity(0.1),
                                                      spreadRadius: 1,
                                                      blurRadius: 2,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 2,
                                                    vertical: height * 0.004,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        fit: FlexFit.tight,
                                                        flex: 3,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: appColours
                                                                .dustbinCardGreenColour2,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: appColours
                                                                    .mainGreyColour
                                                                    .withOpacity(
                                                                        0.1),
                                                                spreadRadius: 1,
                                                                blurRadius: 2,
                                                                offset: Offset(
                                                                    0, 3),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        fit: FlexFit.tight,
                                                        flex: 8,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      4.0),
                                                          child: FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: Text(
                                                              'Available',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: appColours
                                                                    .dustbinCardGreenColour2,
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
                                            Spacer(
                                              flex: 7,
                                            ),
                                          ],
                                        ),
                                      ),
                                SizedBox(height: height * 0.01),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      bin.isClosed
                                          ? Flexible(
                                              fit: FlexFit.tight,
                                              flex: 5,
                                              child: Container(
                                                width: width * 0.17,
                                                decoration: BoxDecoration(
                                                  color: appColours.errorColour
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    100,
                                                  ),
                                                  border: Border.all(
                                                    color: appColours
                                                        .errorColour
                                                        .withOpacity(0.5),
                                                    width: 0.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: appColours
                                                          .mainGreyColour
                                                          .withOpacity(0.1),
                                                      spreadRadius: 1,
                                                      blurRadius: 2,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 2,
                                                    vertical: height * 0.004,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        fit: FlexFit.tight,
                                                        flex: 3,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: appColours
                                                                .dustbinCardRedColour2,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: appColours
                                                                    .mainGreyColour
                                                                    .withOpacity(
                                                                        0.1),
                                                                spreadRadius: 1,
                                                                blurRadius: 2,
                                                                offset: Offset(
                                                                    0, 3),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        fit: FlexFit.tight,
                                                        flex: 8,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10.7),
                                                          child: FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: Text(
                                                              'Closed',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: appColours
                                                                    .dustbinCardRedColour3
                                                                    .withOpacity(
                                                                        0.9),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Flexible(
                                              fit: FlexFit.tight,
                                              flex: 5,
                                              child: Container(
                                                width: width * 0.17,
                                                decoration: BoxDecoration(
                                                  color: appColours
                                                      .dustbinCardGreenColour1
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    100,
                                                  ),
                                                  border: Border.all(
                                                    color: appColours
                                                        .dustbinCardGreenColour2
                                                        .withOpacity(0.5),
                                                    width: 0.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: appColours
                                                          .mainGreyColour
                                                          .withOpacity(0.1),
                                                      spreadRadius: 1,
                                                      blurRadius: 2,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 2,
                                                    vertical: height * 0.004,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        fit: FlexFit.tight,
                                                        flex: 3,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: appColours
                                                                .dustbinCardGreenColour2,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: appColours
                                                                    .mainGreyColour
                                                                    .withOpacity(
                                                                        0.1),
                                                                spreadRadius: 1,
                                                                blurRadius: 2,
                                                                offset: Offset(
                                                                    0, 3),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        fit: FlexFit.tight,
                                                        flex: 8,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      14.2),
                                                          child: FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: Text(
                                                              'Open',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: appColours
                                                                    .dustbinCardGreenColour2,
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
                                      Spacer(
                                        flex: 7,
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Tooltip(
                                        message: 'View Bin',
                                        child: GestureDetector(
                                          onTap: () {
                                            RouterClass.router.push(
                                              '/bin',
                                              extra: binDetails,
                                            );
                                          },
                                          child: Container(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: appColours.mainGreyColour
                                                    .withOpacity(0.6),
                                                width: 1,
                                              ),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.arrow_forward,
                                                size: 15,
                                                color: appColours.mainGreyColour
                                                    .withOpacity(
                                                  0.6,
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
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
