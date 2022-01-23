import 'dart:io';
import 'package:intl/intl.dart';
import 'package:equatable/equatable.dart';
import 'dart:convert';
//import 'package:web_scraper/web_scraper.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';

import 'utils/feedbuilder.dart';
import 'utils/getlength.dart';
import 'utils/types.dart';

File krekDataOriginal = File("data/krek-data-original.json");
File krekData = File("data/krek-data.json");

File krekRss = File("docs/krek.rss");

void main(List<String> arguments) async {
  List<Istentisztelet> list = [];
  List<Istentisztelet> errors = [];

  print('Loading existing data from json');
  List jsonEntries = jsonDecode(krekData.readAsStringSync());
  for (Map entry in jsonEntries) {
    list.add(Istentisztelet(
        dateFormat.parse(entry["date"]),
        entry["title"],
        entry["pastor"],
        entry["bible"],
        entry["youtube"],
        entry["download"],
        entry["uuid"],
        entry["length"]));
  } //TODO dont add if download contains base url

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
        downloadLinks.last,
        null,
        null));
  }

  List<Istentisztelet> newIts =
      freshList.where((element) => (!list.contains(element))).toList();
  list.insertAll(0, newIts);

  save() {
    krekData.createSync();
    krekData.writeAsStringSync(jsonEncode(list.map((e) => e.toJson).toList()));
  }

  int i = 0;
  for (Istentisztelet item in list) {
    if (item.length == null) {
      item.length = await getLength(krekBase + item.download);
      print(
          "Length of ${item.date} | ${item.title} is\n   ${item.length ?? "NULL"} seconds");
      i++;
      if (i > 30) {
        print("\n\nThrottling and saving progress...\n\n");
        await Future.delayed(Duration(seconds: 5));
        i = 0;
        save();
        //exit(0);
      }

      if (item.length == null) {
        //! If length request failed
        errors.add(item);
        //break;
      }
    }
  }

  print("Building rss feed");
  krekRss.createSync();
  krekRss.writeAsStringSync(getFeed(list));

  print('Updating index page');
  File htmlFile = File("docs/index.html");
  String htmlString =
      """<h1>ScrapeCast</h1>
<b>Last update:</b> UTC ${DateTime.now().toIso8601String()}<br />
<b>Number of episodes:</b> ${list.length}<br />
<b>Last Added:</b><br />
<ul>
${newIts.fold("", (String previousValue, Istentisztelet element) => previousValue + "<li>${dateFormat.format(element.date)} | ${element.title} | ${element.pastor}</li>\n")}</ul>""";

  print(htmlString);
  htmlFile.writeAsStringSync(htmlString);
  print('Done!');
  print('Errors:');
  for (Istentisztelet item in errors) {
    print(
        "${item.uuid} | ${item.date} | ${item.title} | ${item.download} | ${item.length}");
  }
  exit(0);
}
