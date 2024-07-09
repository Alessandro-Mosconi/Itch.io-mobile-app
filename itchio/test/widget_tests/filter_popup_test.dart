import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' as intl;
import 'package:itchio/models/filter.dart';
import 'package:itchio/models/option.dart';
import 'package:itchio/providers/page_provider.dart';
import 'package:itchio/widgets/filter_popup.dart';
import 'package:itchio/widgets/filter_row_widget.dart';

import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

void main() {
  final Logger logger = Logger(printer: PrettyPrinter());
  testWidgets('Filter model test', (WidgetTester tester) async {

    String filterJsonString = getFilterJsonString();

    Filter filter = Filter.fromJson(filterJsonString);

    String optionString = getOptionJsonString();
    Option option = Option.fromJson(optionString);

    expect(option.name, equals("accessibility-colorblind"));


    expect(filter.name, equals("accessibility"));
    expect(filter.toJson()['name'], equals("accessibility"));
    expect(filter.toJson()['options'][0]['name'], equals("accessibility-colorblind"));
  });
  testWidgets('Filter popup test with confirm', (WidgetTester tester) async {

    List<Filter> filters = getFiltersExample();

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: ChangeNotifierProvider<PageProvider>(
            create: (_) => PageProvider(),
            child: FilterPopup(selectedFilters: filters,),
          ),
        ),
      ),
    );

    for(Filter filter in filters){
      expect(find.text(filter.label!), findsOneWidget);
      for(Option option in filter.options){
        expect(find.text(option.label!), findsOneWidget);
      }
    }

    for (Filter filter in filters) {
      final filterRowWidgetFinder = find.descendant(
        of: find.byType(FilterRowWidget),
        matching: find.ancestor(
          of: find.text(filter.label!),
          matching: find.byType(Column),
        ),
      );
      for (Option option in filter.options) {
        final offset = tester.getTopLeft(find.text(option.label!));

        if (offset.dx > 550) {
          await tester.drag(find.descendant(
            of: filterRowWidgetFinder,
            matching: find.byType(SingleChildScrollView),
          ), const Offset(-550, 0));
          await tester.pump();

        }

        bool oldIsSelected = option.isSelected;
        await tester.tap(find.text(option.label!));
        await tester.pump();

        expect(option.isSelected, equals(!oldIsSelected));

        bool oldIsSelected2 = option.isSelected;
        await tester.tap(find.text(option.label!));
        await tester.pump();

        expect(option.isSelected, equals(!oldIsSelected2));
      }

    }

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });
  testWidgets('Close button filter popup', (WidgetTester tester) async {

    List<Filter> filters = getFiltersExample();

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: ChangeNotifierProvider<PageProvider>(
            create: (_) => PageProvider(),
            child: FilterPopup(selectedFilters: filters,),
          ),
        ),
      ),
    );


    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });
}

String getOptionJsonString(){
  return '''
        {
            "name":"accessibility-colorblind",
            "label":"Colorblind",
            "isSelected":true
         }
        ''';
}

String getFilterJsonString() {
  return '''
  {
      "name":"accessibility",
      "label":"Accessibility",
      "isAlternative":false,
      "options":[
         {
            "name":"accessibility-colorblind",
            "label":"Colorblind",
            "isSelected":true
         },
         {
            "name":"accessibility-subtitles",
            "label":"Subtitles",
            "isSelected":true
         },
         {
            "name":"accessibility-configurable-controls",
            "label":"Configurable Controls",
            "isSelected":false
         },
         {
            "name":"accessibility-highcontrast",
            "label":"High Contrast",
            "isSelected":false
         },
         {
            "name":"accessibility-tutorial",
            "label":"Tutorial",
            "isSelected":false
         },
         {
            "name":"accessibility-one-button",
            "label":"One Button",
            "isSelected":false
         },
         {
            "name":"accessibility-blind",
            "label":"Blind",
            "isSelected":false
         },
         {
            "name":"accessibility-textless",
            "label":"Textless",
            "isSelected":false
         }
      ]
   }''';
}

List<Filter> getFiltersExample() {

  const String jsonStringFilters = '''[
   {
      "name":"accessibility",
      "label":"Accessibility",
      "isAlternative":false,
      "options":[
         {
            "name":"accessibility-colorblind",
            "label":"Colorblind",
            "isSelected":true
         },
         {
            "name":"accessibility-subtitles",
            "label":"Subtitles",
            "isSelected":true
         },
         {
            "name":"accessibility-configurable-controls",
            "label":"Configurable Controls",
            "isSelected":false
         },
         {
            "name":"accessibility-highcontrast",
            "label":"High Contrast",
            "isSelected":false
         },
         {
            "name":"accessibility-tutorial",
            "label":"Tutorial",
            "isSelected":false
         },
         {
            "name":"accessibility-one-button",
            "label":"One Button",
            "isSelected":false
         },
         {
            "name":"accessibility-blind",
            "label":"Blind",
            "isSelected":false
         },
         {
            "name":"accessibility-textless",
            "label":"Textless",
            "isSelected":false
         }
      ]
   },
   {
      "name":"avg_session_length",
      "label":"Average Session Length",
      "isAlternative":true,
      "options":[
         {
            "name":"duration-seconds",
            "label":"Seconds",
            "isSelected":false
         },
         {
            "name":"duration-minutes",
            "label":"Minutes",
            "isSelected":false
         },
         {
            "name":"duration-half-hour",
            "label":"Half Hour",
            "isSelected":false
         },
         {
            "name":"duration-hour",
            "label":"Hour",
            "isSelected":false
         },
         {
            "name":"duration-hours",
            "label":"Hours",
            "isSelected":false
         },
         {
            "name":"duration-days",
            "label":"Days",
            "isSelected":false
         }
      ]
   },
   {
      "name":"genre",
      "label":"Genre",
      "isAlternative":false,
      "options":[
         {
            "name":"genre-action",
            "label":"Action",
            "isSelected":false
         },
         {
            "name":"genre-adventure",
            "label":"Adventure",
            "isSelected":false
         },
         {
            "name":"tag-card-game",
            "label":"Card Game",
            "isSelected":false
         },
         {
            "name":"tag-survival",
            "label":"Survival",
            "isSelected":false
         },
         {
            "name":"tag-educational",
            "label":"Educational",
            "isSelected":false
         },
         {
            "name":"tag-fighting",
            "label":"Fighting",
            "isSelected":false
         },
         {
            "name":"tag-interactive-fiction",
            "label":"Interactive Fiction",
            "isSelected":false
         },
         {
            "name":"genre-platformer",
            "label":"Platformer",
            "isSelected":false
         },
         {
            "name":"genre-puzzle",
            "label":"Puzzle",
            "isSelected":false
         },
         {
            "name":"tag-racing",
            "label":"Racing",
            "isSelected":false
         },
         {
            "name":"tag-rhythm",
            "label":"Rhythm",
            "isSelected":false
         },
         {
            "name":"genre-rpg",
            "label":"RPG",
            "isSelected":false
         },
         {
            "name":"genre-shooter",
            "label":"Shooter",
            "isSelected":false
         },
         {
            "name":"genre-simulation",
            "label":"Simulation",
            "isSelected":false
         },
         {
            "name":"genre-strategy",
            "label":"Strategy",
            "isSelected":false
         },
         {
            "name":"genre-other",
            "label":"Other",
            "isSelected":false
         },
         {
            "name":"genre-visual-novel",
            "label":"Visual Novel",
            "isSelected":false
         }
      ]
   }
]
  ''';

  List<dynamic> jsonFilters = json.decode(jsonStringFilters);

  List<Filter> filters = jsonFilters.map((f) => Filter(f)).toList();

  return filters;
}
