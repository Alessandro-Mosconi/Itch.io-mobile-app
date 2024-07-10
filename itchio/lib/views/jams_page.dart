import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/jam.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/jam_card.dart';
import 'package:badges/badges.dart' as badges;

import '../widgets/responsive_grid_list_jams.dart';

class JamsPage extends StatefulWidget {
  const JamsPage({super.key});

  @override
  _JamsPageState createState() => _JamsPageState();
}

class _JamsPageState extends State<JamsPage> {
  final Logger logger = Logger(printer: PrettyPrinter());
  final TextEditingController _searchController = TextEditingController();
  List<Jam> _allJams = [];
  List<Jam> _filteredJams = [];
  final bool _isSearching = false;
  int _activeFiltersCount = 0;

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
    const cacheDuration = Duration(hours: 24);
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - timestamp < cacheDuration.inMilliseconds;
  }

  void _applyFilters() {
    setState(() {
      _activeFiltersCount = _countActiveFilters();
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

  int _countActiveFilters() {
    int count = 0;
    if (_searchController.text.isNotEmpty) count++;
    if (_startDateAfterFilter != null) count++;
    if (_startDateBeforeFilter != null) count++;
    if (_endDateAfterFilter != null) count++;
    if (_endDateBeforeFilter != null) count++;
    if (_votingEndDateAfterFilter != null) count++;
    if (_votingEndDateBeforeFilter != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
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
                            icon: const Icon(Icons.search),
                            onPressed: _applyFilters,
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearFilters,
                          ),
                          IconButton(
                            icon: badges.Badge(
                              showBadge: _activeFiltersCount > 0,
                              badgeContent: Text('$_activeFiltersCount', style: const TextStyle(color: Colors.white)),
                              badgeStyle: const badges.BadgeStyle(),
                              badgeAnimation: const badges.BadgeAnimation.slide(),
                              child: const Icon(Icons.filter_list),
                            ),
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
                ? const Center(child: CircularProgressIndicator())
                : ResponsiveGridListJam(jams: _filteredJams),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    DateTime? tempStartDateAfterFilter = _startDateAfterFilter;
    DateTime? tempStartDateBeforeFilter = _startDateBeforeFilter;
    DateTime? tempEndDateAfterFilter = _endDateAfterFilter;
    DateTime? tempEndDateBeforeFilter = _endDateBeforeFilter;
    DateTime? tempVotingEndDateAfterFilter = _votingEndDateAfterFilter;
    DateTime? tempVotingEndDateBeforeFilter = _votingEndDateBeforeFilter;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Jams'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: MediaQuery.of(context).size.width > 600
                    ? GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 6,
                  shrinkWrap: true,
                  children: [
                    _buildDateSelector(
                      context,
                      "Start Date After",
                      tempStartDateAfterFilter,
                          (date) {
                        setState(() {
                          tempStartDateAfterFilter = date;
                        });
                      },
                          () {
                        setState(() {
                          tempStartDateAfterFilter = null;
                        });
                      },
                    ),
                    _buildDateSelector(
                      context,
                      "Start Date Before",
                      tempStartDateBeforeFilter,
                          (date) {
                        setState(() {
                          tempStartDateBeforeFilter = date;
                        });
                      },
                          () {
                        setState(() {
                          tempStartDateBeforeFilter = null;
                        });
                      },
                    ),
                    _buildDateSelector(
                      context,
                      "End Date After",
                      tempEndDateAfterFilter,
                          (date) {
                        setState(() {
                          tempEndDateAfterFilter = date;
                        });
                      },
                          () {
                        setState(() {
                          tempEndDateAfterFilter = null;
                        });
                      },
                    ),
                    _buildDateSelector(
                      context,
                      "End Date Before",
                      tempEndDateBeforeFilter,
                          (date) {
                        setState(() {
                          tempEndDateBeforeFilter = date;
                        });
                      },
                          () {
                        setState(() {
                          tempEndDateBeforeFilter = null;
                        });
                      },
                    ),
                    _buildDateSelector(
                      context,
                      "Voting End Date After",
                      tempVotingEndDateAfterFilter,
                          (date) {
                        setState(() {
                          tempVotingEndDateAfterFilter = date;
                        });
                      },
                          () {
                        setState(() {
                          tempVotingEndDateAfterFilter = null;
                        });
                      },
                    ),
                    _buildDateSelector(
                      context,
                      "Voting End Date Before",
                      tempVotingEndDateBeforeFilter,
                          (date) {
                        setState(() {
                          tempVotingEndDateBeforeFilter = date;
                        });
                      },
                          () {
                        setState(() {
                          tempVotingEndDateBeforeFilter = null;
                        });
                      },
                    ),
                  ],
                )
                    : ListView(
                  shrinkWrap: true,
                  children: [
                    _buildDateSelector(
                      context,
                      "Start Date After",
                      tempStartDateAfterFilter,
                          (date) {
                        setState(() {
                          tempStartDateAfterFilter = date;
                        });
                      },
                          () {
                        setState(() {
                          tempStartDateAfterFilter = null;
                        });
                      },
                    ),
                    _buildDateSelector(
                      context,
                      "Start Date Before",
                      tempStartDateBeforeFilter,
                          (date) {
                        setState(() {
                          tempStartDateBeforeFilter = date;
                        });
                      },
                          () {
                        setState(() {
                          tempStartDateBeforeFilter = null;
                        });
                      },
                    ),
                    _buildDateSelector(
                      context,
                      "End Date After",
                      tempEndDateAfterFilter,
                          (date) {
                        setState(() {
                          tempEndDateAfterFilter = date;
                        });
                      },
                          () {
                        setState(() {
                          tempEndDateAfterFilter = null;
                        });
                      },
                    ),
                    _buildDateSelector(
                      context,
                      "End Date Before",
                      tempEndDateBeforeFilter,
                          (date) {
                        setState(() {
                          tempEndDateBeforeFilter = date;
                        });
                      },
                          () {
                        setState(() {
                          tempEndDateBeforeFilter = null;
                        });
                      },
                    ),
                    _buildDateSelector(
                      context,
                      "Voting End Date After",
                      tempVotingEndDateAfterFilter,
                          (date) {
                        setState(() {
                          tempVotingEndDateAfterFilter = date;
                        });
                      },
                          () {
                        setState(() {
                          tempVotingEndDateAfterFilter = null;
                        });
                      },
                    ),
                    _buildDateSelector(
                      context,
                      "Voting End Date Before",
                      tempVotingEndDateBeforeFilter,
                          (date) {
                        setState(() {
                          tempVotingEndDateBeforeFilter = date;
                        });
                      },
                          () {
                        setState(() {
                          tempVotingEndDateBeforeFilter = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    _startDateAfterFilter = tempStartDateAfterFilter;
                    _startDateBeforeFilter = tempStartDateBeforeFilter;
                    _endDateAfterFilter = tempEndDateAfterFilter;
                    _endDateBeforeFilter = tempEndDateBeforeFilter;
                    _votingEndDateAfterFilter = tempVotingEndDateAfterFilter;
                    _votingEndDateBeforeFilter = tempVotingEndDateBeforeFilter;
                    _applyFilters();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Confirm'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Widget _buildDateSelector(BuildContext context, String title, DateTime? selectedDate, Function(DateTime) onDateSelected, Function() onDelete) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: selectedDate != null ? Text(selectedDate.toIso8601String().split('T')[0]) : const Text("Not selected"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context, (date) {
              onDateSelected(date);
            }),
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              onDelete();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, ValueChanged<DateTime> onDateSelected) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) onDateSelected(DateTime(picked.year, picked.month, picked.day));
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
      _activeFiltersCount = 0; // Resetta il contatore dei filtri attivi
    });
    _applyFilters();
  }
}

