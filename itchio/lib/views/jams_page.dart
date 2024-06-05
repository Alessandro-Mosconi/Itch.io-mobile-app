import 'dart:async';
import 'dart:convert';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../helperClasses/Jam.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/jam_card.dart';

class JamsPage extends StatefulWidget {
  @override
  _JamsPageState createState() => _JamsPageState();
}

class _JamsPageState extends State<JamsPage> {
  final Logger logger = Logger(printer: PrettyPrinter());
  TextEditingController _searchController = TextEditingController();
  List<Jam> _allJams = [];
  List<Jam> _filteredJams = [];
  bool _isSearching = false;

  // Filter variables
  DateTime? _startDateAfterFilter;
  DateTime? _startDateBeforeFilter;
  DateTime? _endDateAfterFilter;
  DateTime? _endDateBeforeFilter;
  DateTime? _votingEndDateAfterFilter;
  DateTime? _votingEndDateBeforeFilter;

  @override
  void initState() {
    super.initState();
    fetchJams(false).then((jams) {
      setState(() {
        _allJams = jams;
        _filteredJams = jams;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Jam>> fetchJams(bool? includeDetails) async {
    includeDetails ??= false;
    final prefs = await SharedPreferences.getInstance();
    var key = includeDetails ? "saved_jams_details" : "saved_jams";

    if (prefs.getString(key) != null && checkTimestamp(prefs.getInt("${key}_timestamp"))) {
      return _getCachedJams(prefs, key);
    }

    return _fetchJamsFromNetwork(key, includeDetails, prefs);
  }

  Future<List<Jam>> _getCachedJams(SharedPreferences prefs, String key) async {
    String body = prefs.getString(key)!;
    List<dynamic>? results = json.decode(body);
    return results?.map((r) => Jam(r)).toList() ?? [];
  }

  Future<List<Jam>> _fetchJamsFromNetwork(String key, bool includeDetails, SharedPreferences prefs) async {
    final response = await http.get(Uri.parse('https://us-central1-itchioclientapp.cloudfunctions.net/fetch_jams?include_details=$includeDetails'));

    if (response.statusCode == 200) {
      List<dynamic>? results = json.decode(response.body);
      prefs.setString(key, response.body);
      prefs.setInt("${key}_timestamp", DateTime.now().millisecondsSinceEpoch);
      return results?.map((r) => Jam(r)).toList() ?? [];
    } else {
      throw Exception('Failed to load saved jams results');
    }
  }

  bool checkTimestamp(int? timestamp) {
    if (timestamp == null) return false;
    final cacheDuration = Duration(hours: 24);
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - timestamp < cacheDuration.inMilliseconds;
  }

  void _applyFilters() {
    setState(() {
      _filteredJams = _allJams.where((jam) {
        bool matchesSearch = jam.title!.toLowerCase().contains(_searchController.text.toLowerCase());
        bool matchesStartDate = (_startDateAfterFilter == null || (jam.startDate != null && jam.startDate!.isAfter(_startDateAfterFilter!))) &&
            (_startDateBeforeFilter == null || (jam.startDate != null && jam.startDate!.isBefore(_startDateBeforeFilter!)));
        bool matchesEndDate = (_endDateAfterFilter == null || (jam.endDate != null && jam.endDate!.isAfter(_endDateAfterFilter!))) &&
            (_endDateBeforeFilter == null || (jam.endDate != null && jam.endDate!.isBefore(_endDateBeforeFilter!)));
        bool matchesVotingEndDate = (_votingEndDateAfterFilter == null || (jam.votingEndDate != null && jam.votingEndDate!.isAfter(_votingEndDateAfterFilter!))) &&
            (_votingEndDateBeforeFilter == null || (jam.votingEndDate != null && jam.votingEndDate!.isBefore(_votingEndDateBeforeFilter!)));
        return matchesSearch && matchesStartDate && matchesEndDate && matchesVotingEndDate;
      }).toList();
    });
  }

  Future<void> _selectDate(BuildContext context, ValueChanged<DateTime> onDateSelected) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) onDateSelected(picked);
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _startDateAfterFilter = null;
      _startDateBeforeFilter = null;
      _endDateAfterFilter = null;
      _endDateBeforeFilter = null;
      _votingEndDateAfterFilter = null;
      _votingEndDateBeforeFilter = null;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for jams...',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.search),
                            onPressed: _applyFilters,
                          ),
                          IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: _clearFilters,
                          ),
                          IconButton(
                            icon: Icon(Icons.filter_list),
                            onPressed: () => _showFilterDialog(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isSearching
                ? Center(child: CircularProgressIndicator())
                : _buildJamListOrGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildJamListOrGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_filteredJams.isEmpty) {
          return Center(child: Text('No jams found'));
        }

        if (constraints.maxWidth > 600) {
          var orientation = MediaQuery.of(context).orientation;
          bool isPortrait = orientation == Orientation.portrait;
          return _buildJamGrid(_filteredJams, isPortrait);
        } else {
          // Phone layout: ListView
          return _buildJamList(_filteredJams);
        }
      },
    );
  }

  ListView _buildJamList(List<Jam> jams) {
    return ListView.builder(
      itemCount: jams.length,
      itemBuilder: (context, index) {
        return JamCard(
          jam: jams[index],
          isTablet: false,
        );
      },
    );
  }

  GridView _buildJamGrid(List<Jam> jams, bool isPortrait) {
    double itemWidth = 500.0;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: itemWidth,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 16 / 9,
      ),
      itemCount: jams.length,
      itemBuilder: (context, index) {
        return JamCard(jam: jams[index], isTablet: !isPortrait);
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Jams'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("Start Date After"),
                trailing: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, (date) {
                    setState(() {
                      _startDateAfterFilter = date;
                      _applyFilters();
                    });
                  }),
                ),
              ),
              ListTile(
                title: Text("Start Date Before"),
                trailing: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, (date) {
                    setState(() {
                      _startDateBeforeFilter = date;
                      _applyFilters();
                    });
                  }),
                ),
              ),
              ListTile(
                title: Text("End Date After"),
                trailing: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, (date) {
                    setState(() {
                      _endDateAfterFilter = date;
                      _applyFilters();
                    });
                  }),
                ),
              ),
              ListTile(
                title: Text("End Date Before"),
                trailing: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, (date) {
                    setState(() {
                      _endDateBeforeFilter = date;
                      _applyFilters();
                    });
                  }),
                ),
              ),
              ListTile(
                title: Text("Voting End Date After"),
                trailing: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, (date) {
                    setState(() {
                      _votingEndDateAfterFilter = date;
                      _applyFilters();
                    });
                  }),
                ),
              ),
              ListTile(
                title: Text("Voting End Date Before"),
                trailing: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, (date) {
                    setState(() {
                      _votingEndDateBeforeFilter = date;
                      _applyFilters();
                    });
                  }),
                ),
              ),
              ElevatedButton(
                onPressed: _clearFilters,
                child: Text('Clear Filters'),
              ),
            ],
          ),
        );
      },
    );
  }
}
