import 'package:flutter/material.dart';
import '../models/filter.dart';
import 'filter_row_widget.dart';

class FilterPopup extends StatelessWidget {
  final List<Filter> selectedFilters;
  final void Function(Set<String>) onFiltersChanged;

  const FilterPopup({
    super.key,
    required this.selectedFilters,
    required this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filterRows = selectedFilters.map((filter) => FilterRowWidget(
          filter: filter,
          onFiltersChanged: (selectedOptions) {
            onFiltersChanged(selectedOptions);
          }
      )).toList();


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
  }
}
