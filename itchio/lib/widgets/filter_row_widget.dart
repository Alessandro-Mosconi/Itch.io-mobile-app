import 'package:flutter/material.dart';

import '../models/filter.dart';

class FilterRowWidget extends StatefulWidget {
  final Filter filter;
  final void Function(Set<String>) onFiltersChanged;

  const FilterRowWidget({
    super.key,
    required this.filter,
    required this.onFiltersChanged,
  });

  @override
  _FilterRowWidgetState createState() => _FilterRowWidgetState();
}

class _FilterRowWidgetState extends State<FilterRowWidget> {
  late Set<String> selectedOptions;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.filter.label ?? ''),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.filter.options.map((option) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(option.label ?? ''),
                  selected: option.isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedOptions.add(option.name ?? '');
                      } else {
                        selectedOptions.remove(option.name ?? '');
                      }
                      widget.onFiltersChanged(selectedOptions);
                    });
                  },
                  selectedColor: option.isSelected ? Colors.blue : null,
                  backgroundColor: option.isSelected ? Colors.blue.withOpacity(0.1) : null,
                  labelStyle: TextStyle(color: option.isSelected ? Colors.white : null),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
