import 'dart:io';
import 'package:intl/intl.dart';
import 'package:equatable/equatable.dart';
import 'dart:convert';
//import 'package:web_scraper/web_scraper.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

import 'utils/feedbuilder.dart';
import 'utils/types.dart';

File krekDataOriginal = File("data/krek-data-original.json");
File krekData = File("data/krek-data.json");

File krekRss = File("docs/krek.rss");

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

  print("Building rss feed");
  krekRss.createSync();
  krekRss.writeAsStringSync(getFeed(list));

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
