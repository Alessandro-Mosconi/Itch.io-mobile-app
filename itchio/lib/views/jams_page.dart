import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/jam.dart';
import '../widgets/custom_app_bar.dart';
import 'package:badges/badges.dart' as badges;
import 'package:intl/intl.dart';
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
              title: Text(
                'Filter Jams',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDateRangePicker(
                      context,
                      "Start Date",
                      tempStartDateAfterFilter,
                      tempStartDateBeforeFilter,
                          (after, before) {
                        setState(() {
                          tempStartDateAfterFilter = after;
                          tempStartDateBeforeFilter = before;
                        });
                      },
                    ),
                    _buildDateRangePicker(
                      context,
                      "End Date",
                      tempEndDateAfterFilter,
                      tempEndDateBeforeFilter,
                          (after, before) {
                        setState(() {
                          tempEndDateAfterFilter = after;
                          tempEndDateBeforeFilter = before;
                        });
                      },
                    ),
                    _buildDateRangePicker(
                      context,
                      "Voting End Date",
                      tempVotingEndDateAfterFilter,
                      tempVotingEndDateBeforeFilter,
                          (after, before) {
                        setState(() {
                          tempVotingEndDateAfterFilter = after;
                          tempVotingEndDateBeforeFilter = before;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
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
                  child: Text('Apply Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDateRangePicker(
      BuildContext context,
      String title,
      DateTime? startDate,
      DateTime? endDate,
      Function(DateTime?, DateTime?) onDateRangeSelected,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildDateChip(
                context,
                "From",
                startDate,
                    () async {
                  final date = await _selectDate(context, startDate);
                  if (date != null) {
                    onDateRangeSelected(date, endDate);
                  }
                },
                    () => onDateRangeSelected(null, endDate),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildDateChip(
                context,
                "To",
                endDate,
                    () async {
                  final date = await _selectDate(context, endDate);
                  if (date != null) {
                    onDateRangeSelected(startDate, date);
                  }
                },
                    () => onDateRangeSelected(startDate, null),
              ),
            ),
          ],
        ),
        Divider(height: 24),
      ],
    );
  }

  Widget _buildDateChip(
      BuildContext context,
      String label,
      DateTime? date,
      VoidCallback onTap,
      VoidCallback onClear,
      ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).chipTheme.backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null ? DateFormat('MMM d, y').format(date) : label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (date != null)
              InkWell(
                onTap: onClear,
                child: Icon(Icons.clear, size: 18, color: Theme.of(context).colorScheme.onSurface),
              ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _selectDate(BuildContext context, DateTime? initialDate) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
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

