import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swms_administration/constants/colours.dart';
import 'package:swms_administration/constants/text_styles.dart';

import 'package:swms_administration/models/bin_model.dart';
import 'package:swms_administration/services/bin_services.dart';
import 'package:swms_administration/widgets/reusable/dustbin_card.dart';

class DustbinInfoMobile extends StatefulWidget {
  const DustbinInfoMobile({Key? key}) : super(key: key);

  @override
  State<DustbinInfoMobile> createState() => _DustbinInfoMobileState();
}

class _DustbinInfoMobileState extends State<DustbinInfoMobile> {
  final TextEditingController _searchController = TextEditingController();
  late BinServices _binServices;
  List<Bin> _filteredBins = [];

  @override
  void initState() {
    super.initState();
    _binServices = BinServices();

    // Set up the initial filtered bins list
    _filteredBins = _binServices.allBins;

    // Add listener to the search controller
    _searchController.addListener(_filterBins);

    // Listen to changes from BinServices
    _binServices.addListener(_onBinsUpdated);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterBins);
    _searchController.dispose();
    _binServices.removeListener(_onBinsUpdated);
    _binServices.dispose();
    super.dispose();
  }

  // Update filtered bins when BinServices updates
  void _onBinsUpdated() {
    _filterBins();
  }

  // Filter bins based on search text
  void _filterBins() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredBins = _binServices.allBins;
      } else {
        _filteredBins = _binServices.searchBins(_searchController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColours = AppColours();
    final textStyles = AppTextStyles();
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: appColours.mainWhiteColour,
      appBar: AppBar(
        toolbarHeight: 110,
        backgroundColor: appColours.mainWhiteColour,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dustbin Info',
              style: textStyles.pageTitleStyleMobile,
            ),
            const SizedBox(height: 6),
            Text(
              'Monitor your bins Individually',
              style: textStyles.pageHeadlineStyleMobile,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: appColours.mainTextColour),
            onPressed: () {
              _binServices.refreshBins();
            },
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0.075 * height),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Container(
              height: 0.048 * height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: appColours.mainTextColour.withOpacity(0.04),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Icon(
                      Icons.search_rounded,
                      size: 22,
                      color: appColours.valueColour.withOpacity(0.6),
                    ),
                  ),
                  filled: true,
                  fillColor: appColours.mainWhiteColour,
                  hintText: 'Search bins, types...',
                  hintStyle: textStyles.hintTextStyle,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: appColours.containerShadowColour,
                      width: 1.2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: appColours.containerShadowColour,
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: appColours.mainThemeColour.withOpacity(0.2),
                      width: 1.4,
                    ),
                  ),
                ),
                style: textStyles.inputTextStyle,
              ),
            ),
          ),
        ),
      ),
      body: _binServices.isLoading
          ? Center(
              child:
                  CircularProgressIndicator(color: appColours.mainThemeColour))
          : _binServices.error != null
              ? _buildErrorWidget()
              : _filteredBins.isEmpty
                  ? _buildEmptyResultsWidget()
                  : RefreshIndicator(
                      elevation: 2,
                      displacement:
                          MediaQuery.of(context).size.height * 0.44 / 4,
                      color: appColours.mainThemeColour,
                      backgroundColor: appColours.mainThemeColour,
                      onRefresh: () async {
                        _binServices.refreshBins();
                      },
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  childAspectRatio: 1.95,
                                ),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                itemCount: _filteredBins.length,
                                itemBuilder: (context, index) {
                                  final Bin bin = _filteredBins[index];
                                  final Map<String, String> binDetails = {
                                    'id': bin.id,
                                    'name': bin.name,
                                    'location': bin.location,
                                    'latitude': bin.latitude.toString(),
                                    'longitude': bin.longitude.toString(),
                                    'imageUrl': bin.imageUrl,
                                    'type': bin.type,
                                    'fillLevel': bin.fillLevel.toString(),
                                    'gasLevel': bin.gasLevel.toString(),
                                    'humidity': bin.humidity.toString(),
                                    'temperature': bin.temperature.toString(),
                                    'precipitation':
                                        bin.precipitation.toString(),
                                    'fillStatus': bin.fillStatus.toString(),
                                    'isClosed': bin.isClosed.toString(),
                                    'isControllerOnClosed':
                                        bin.isControllerOnClosed.toString(),
                                    'capacity': bin.capacity.toString(),
                                    'isSub': bin.isSub.toString(),
                                    'networkStatus':
                                        bin.networkStatus.toString(),
                                    'isManual': bin.isManual.toString(),
                                    'mainBin': bin.mainBin!,
                                  };
                                  return DustbinCard(
                                    bin: bin,
                                    binDetails: binDetails,
                                    context: context,
                                    isDesktop: false,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
    );
  }

  Widget _buildErrorWidget() {
    final textStyles = AppTextStyles();
    final appColours = AppColours();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: appColours.errorColour),
          SizedBox(height: 16),
          Text(
            'Error loading dustbins',
            style: textStyles.buttonTextStyle,
          ),
          SizedBox(height: 8),
          Text(
            _binServices.error ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: textStyles.buttonTextStyle,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _binServices.refreshBins();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: appColours.mainThemeColour,
            ),
            child: Text('Retry', style: textStyles.buttonTextStyle),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResultsWidget() {
    final textStyles = AppTextStyles();
    final appColours = AppColours();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: appColours.valueColour),
          SizedBox(height: 16),
          Text(
            'No Dustbins Found !',
            style: textStyles.bodyTextStyle,
          ),
          SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try a different search term'
                : 'No dustbins available in the system.',
            textAlign: TextAlign.center,
            style: textStyles.buttonTextStyle.copyWith(
              color: appColours.valueColour,
            ),
          ),
          _searchController.text.isNotEmpty
              ? SizedBox(height: 0)
              : SizedBox(height: 2),
          Text(
            _searchController.text.isNotEmpty
                ? ''
                : 'Please check your Internet Connection and try again !',
            textAlign: TextAlign.center,
            style: textStyles.bodyTextStyle.copyWith(
              color: appColours.valueColour,
            ),
          ),
          if (_searchController.text.isNotEmpty) SizedBox(height: 24),
          if (_searchController.text.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: appColours.mainWhiteColour,
                backgroundColor: appColours.mainThemeColour,
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12), // Padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Rounded corners
                ),
                elevation: 5, // Shadow effect
              ),
              child: Text(
                'Clear Search',
                style: textStyles.buttonTextStyle,
              ),
            ),
        ],
      ),
    );
  }
}
