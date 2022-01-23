import 'dart:io';
import 'package:intl/intl.dart';
import 'package:equatable/equatable.dart';
import 'dart:convert';
//import 'package:web_scraper/web_scraper.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

File krekDataOriginal = File("data/krek-data-original.json");
File krekData = File("data/krek-data.json");

DateFormat dateFormat = DateFormat("yyyy.MM.dd");

void main(List<String> arguments) async {
  List<Istentisztelet> list = [];

  print('Loading existing data from json');
  List jsonEntries = jsonDecode(krekData.readAsStringSync());
  for (Map entry in jsonEntries) {
    list.add(Istentisztelet(dateFormat.parse(entry["date"]), entry["title"],
        entry["pastor"], entry["bible"], entry["youtube"], entry["download"]));
  }

/* //? Loader from original json
  List jsonEntries = jsonDecode(krekDataOriginal.readAsStringSync());
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
 */
  print('Scraping latest from krek.hu');

  var httpClient = Client();
  var resp = await httpClient.get(
    Uri.parse(//post(
        'https://www.krek.hu/sources/webshop/product_list.php'), //body: {'prod_page': '12'}
  );
  var document = parse(resp.body);
  var rows = document.querySelectorAll('div.data');

  List<Istentisztelet> freshList = [];

  for (var row in rows) {
    List<String> downloadLinks = [];
    row.querySelector('div.dwnld')!.querySelectorAll('a').forEach((element) {
      downloadLinks.add(element.attributes.values.first);
    });

    freshList.add(Istentisztelet(
        dateFormat.parse(row.querySelector('div.datum')!.text),
        row.querySelector('div.cim')!.text,
        row.querySelector('div.hirdeto')!.text,
        row.querySelector('div.igeresz')!.text,
        (downloadLinks.length > 1) ? downloadLinks.first : null,
        downloadLinks.last));
  }

  List<Istentisztelet> newIts =
      freshList.where((element) => (!list.contains(element))).toList();
  list.insertAll(0, newIts);

  krekData.createSync();
  krekData.writeAsStringSync(jsonEncode(list.map((e) => e.toJson).toList()));

  print("Done");

  print('Updating index page');
  File htmlFile = File("docs/index.html");
  String htmlString = """<h1>ScrapeCast</h1>
<b>Last update:</b> UTC ${DateTime.now().toIso8601String()}<br />
<b>Number of episodes:</b> ${list.length}<br />
<b>Last Added:</b><br />
<ul>
${newIts.fold("", (String previousValue, Istentisztelet element) => previousValue + "<li>${dateFormat.format(element.date)} | ${element.title} | ${element.pastor}</li>\n")}</ul>""";

  print(htmlString);
  htmlFile.writeAsStringSync(htmlString);
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

  get toJson => {
        "title": title,
        "bible": bible,
        "date": dateFormat.format(date),
        "pastor": pastor,
        "youtube": youTube,
        "download": download
      };

  @override
  List<Object> get props => [title, pastor, date];
}
