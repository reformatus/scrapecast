import 'dart:io';
import 'package:intl/intl.dart';
import 'package:equatable/equatable.dart';
import 'dart:convert';

File krekData = File("data/krek-data.json");

void main(List<String> arguments) {
  List<Istentisztelet> list = [];

  print('Loading existing data from json');
  DateFormat dateFormat = DateFormat("yyyy.MM.dd");
  List jsonEntries = jsonDecode(krekData.readAsStringSync());

  for (Map entry in jsonEntries) {
    list.add(Istentisztelet(
        dateFormat.parse(entry["date"]),
        entry["title"],
        entry["pastor"],
        entry["scripture"],
        (entry["links"].length > 1)
            ? entry["links"].first["letoltesek-href"]
            : null,
        entry["links"].last["letoltesek-href"]));
  }

  print('Scraping latest from krek.hu');

  print('Updating index page');
  File html = File("docs/index.html");
  html.writeAsString(
      "<h1>CrawlCast</h1>\nLast update: UTC ${DateTime.now().toIso8601String()}");
  print('Done!');
  exit(0);
}

class Istentisztelet extends Equatable {
  final DateTime date;
  final String title;
  final String pastor;
  final String bible;
  final String? youTube;
  final String download;

  Istentisztelet(this.date, this.title, this.pastor, this.bible, this.youTube,
      this.download);

  @override
  List<Object> get props => [title, pastor, date];
}
