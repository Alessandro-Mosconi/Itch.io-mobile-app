import 'package:flutter/material.dart';
import 'filter_row_widget.dart';

class FilterPopup extends StatelessWidget {
  final Map<String, Set<String>> selectedFilters;
  final void Function(Map<String, Set<String>>) onFiltersChanged;
  final Future<Map<String, List<Map<String, String>>>> fetchFilters;

  const FilterPopup({super.key, 
    required this.selectedFilters,
    required this.onFiltersChanged,
    required this.fetchFilters,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<Map<String, String>>>>(
      future: fetchFilters,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          final filtersData = snapshot.data!;
          final filterRows = filtersData.entries.map((entry) {
            return FilterRowWidget(
              label: entry.key,
              options: entry.value,
              selectedFilters: selectedFilters[entry.key] ?? {},
              onFiltersChanged: (filters) {
                selectedFilters[entry.key] = filters;
                onFiltersChanged(Map<String, Set<String>>.from(selectedFilters));
              },
            );
          }).toList();

          return AlertDialog(
            title: const Text('Filter'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: filterRows,
              ),
            ),
            actions: <Widget>[
            ElevatedButton(
                child: const Text('Confirm'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        } else {
          return const Center(child: Text("No data available"));
        }
      },
    );
  }
}
