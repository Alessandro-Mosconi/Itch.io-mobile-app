import 'package:flutter/material.dart';

class FilterRowWidget extends StatefulWidget {
  final String label;
  final List<Map<String, String>> options;
  final Set<String> selectedFilters;
  final void Function(Set<String>) onFiltersChanged;

  const FilterRowWidget({super.key, 
    required this.label,
    required this.options,
    required this.selectedFilters,
    required this.onFiltersChanged,
  });

  @override
  _FilterRowWidgetState createState() => _FilterRowWidgetState();
}

class _FilterRowWidgetState extends State<FilterRowWidget> {
  late Set<String> _selectedFilters;

  @override
  void initState() {
    super.initState();
    _selectedFilters = Set.from(widget.selectedFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.options.map((option) {
              final isSelected = _selectedFilters.contains(option['name']);
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(option['label']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedFilters.add(option['name']!);
                      } else {
                        _selectedFilters.remove(option['name']);
                      }
                      widget.onFiltersChanged(_selectedFilters);
                    });
                  },
                  selectedColor: isSelected ? Colors.blue : null,
                  backgroundColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : null),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
