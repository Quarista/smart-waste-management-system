import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swms_administration/constants/colours.dart';

import 'package:swms_administration/models/bin_model.dart';
import 'package:swms_administration/services/bin_services.dart';
import 'package:swms_administration/widgets/reusable/dustbin_card.dart';

class DustbinInfoDesktop extends StatefulWidget {
  const DustbinInfoDesktop({Key? key}) : super(key: key);

  @override
  State<DustbinInfoDesktop> createState() => _DustbinInfoDesktopState();
}

class _DustbinInfoDesktopState extends State<DustbinInfoDesktop> {
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
    double height = MediaQuery.of(context).size.height;
    final appColours = AppColours();
    return Scaffold(
      backgroundColor: appColours.scaffoldColour,
      appBar: AppBar(
        toolbarHeight: height * 0.15,
        backgroundColor: appColours.scaffoldColour,
        title: SizedBox(
          height: height * 0.15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Spacer(),
              Flexible(
                fit: FlexFit.tight,
                flex: 3,
                child: AutoSizeText(
                  'Dustbin Info',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: appColours.mainTextColour,
                  ),
                  maxLines: 1,
                  minFontSize: 25,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                fit: FlexFit.tight,
                flex: 2,
                child: AutoSizeText(
                  'Overview of bin statuses and fill levels',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: appColours.textColour2,
                  ),
                  maxLines: 1,
                  minFontSize: 10,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _binServices.refreshBins();
            },
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(80), // Fixed height for desktop
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  right: 20,
                ),
                child: SizedBox(
                  width: 500, // Optimal width for desktop
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 12),
                          child: Icon(
                            Icons.search_rounded, // Modern rounded icon
                            size: 24,
                            color: appColours.mainGreyColour,
                          ),
                        ),
                        filled: true,
                        fillColor: appColours.mainWhiteColour,
                        hintText: 'Search bins, types...', // Descriptive hint
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: appColours.mainGreyColour.withOpacity(0.5),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: appColours.mainGreyColour.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: appColours.mainGreyColour.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: appColours.searchBarFocusColour
                                .withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: appColours.mainGreyColour.withOpacity(1),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _binServices.isLoading
          ? Center(child: CircularProgressIndicator())
          : _binServices.error != null
              ? _buildErrorWidget()
              : _filteredBins.isEmpty
                  ? _buildEmptyResultsWidget()
                  : RefreshIndicator(
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
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
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
                                    'imageUrl': bin.imageUrl,
                                    'type': bin.type,
                                    'fillLevel': bin.fillLevel.toString(),
                                    'latitude': bin.latitude.toString(),
                                    'longitude': bin.longitude.toString(),
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
                                    isDesktop: true,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColours().errorColour),
          SizedBox(height: 16),
          Text(
            'Error loading dustbins',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _binServices.error ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _binServices.refreshBins();
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResultsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: AppColours().mainGreyColour),
          SizedBox(height: 16),
          Text(
            'No Dustbins Found !',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try a different search term'
                : 'No dustbins available in the system.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
            ),
          ),
          _searchController.text.isNotEmpty
              ? SizedBox(height: 0)
              : SizedBox(height: 2),
          Text(
            _searchController.text.isNotEmpty
                ? ''
                : 'Please ckeck your Internet Connection and try again !',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
            ),
          ),
          if (_searchController.text.isNotEmpty) SizedBox(height: 24),
          if (_searchController.text.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColours().mainWhiteColour,
                backgroundColor: AppColours().mainThemeColour, // Text color
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12), // Padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Rounded corners
                ),
                elevation: 5, // Shadow effect
              ),
              child: Text(
                'Clear Search',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w300),
              ),
            ),
        ],
      ),
    );
  }
}
