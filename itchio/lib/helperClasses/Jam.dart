import 'dart:convert';

import 'Game.dart';
import 'JamGame.dart';

class Jam {
  int? hue;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? votingEndDate;
  int? featured;
  int? id;
  String? title;
  bool? highlight;
  int? joined;
  String? url;
  double? generatedOn;
  List<JamGame> jamGames = [];

  Jam(Map<String, dynamic> data) {
    hue = data['hue'];
    startDate = data['start_date'] == null ? null : DateTime.parse(data['start_date']);
    endDate = data['end_date'] == null ? null : DateTime.parse(data['end_date']);
    votingEndDate = data['voting_end_date'] == null ? null : DateTime.parse(data['voting_end_date']);
    featured = data['featured'];
    id = data['id'];
    title = data['title'];
    highlight = data['highlight'];
    joined = data['joined'];
    url = data['url'];
    generatedOn = data['detail']?['generated_on'];

    jamGames = (data['detail']?['jam_games'] as List<dynamic>?)
        ?.map((d) => JamGame(d as Map<String, dynamic>))
        .toList() ?? [];

  }

  Jam.fromJson(String jsonJam) {
    var data = json.decode(jsonJam);
    hue = data['hue'];
    startDate = DateTime.parse(data['start_date']);
    endDate = DateTime.parse(data['end_date']);
    votingEndDate = DateTime.parse(data['voting_end_date']);
    featured = data['featured'];
    id = data['id'];
    title = data['title'];
    highlight = data['highlight'];
    joined = data['joined'];
    url = data['url'];
    generatedOn = data['detail']['generated_on'];
    jamGames = (data['detail']['jam_games'] as List<dynamic>?)
        ?.map((d) => JamGame(d as Map<String, dynamic>))
        .toList() ?? [];
  }
}
