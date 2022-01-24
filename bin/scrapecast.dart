import 'dart:io';
import 'dart:convert';
//import 'package:web_scraper/web_scraper.dart';

import 'utils/feedbuilder.dart';
import 'utils/getlength.dart';
import 'utils/types.dart';
import 'scrapers/krekscraper.dart';
import 'podcasts.dart';

void main() async {
  for (Podcast podcast in podcasts) {
    await buildPodcast(podcast);
  }
}

Future buildPodcast(Podcast podcast) async {
  print("\n\nBuilding ${podcast.properties.title}\n");

  List<Istentisztelet> list = [];
  List<Istentisztelet> errors = [];

  print('Loading existing data from json');
  List jsonEntries = jsonDecode(podcast.dataFile.readAsStringSync());
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

  List<Istentisztelet> newIts = (await krekScrape())
      .where((element) => (!list.contains(element)))
      .toList();
  list.insertAll(0, newIts);

  save() {
    print("Saving database");
    podcast.dataFile.createSync();
    podcast.dataFile.writeAsStringSync(JsonEncoder.withIndent('  ')
        .convert(list.map((e) => e.toJson).toList()));
  }

  int i = 0;
  for (Istentisztelet item in list) {
    if (item.length == null) {
      item.length = await getLength(krekBase + item.download);
      print(
          "Length of ${item.date} | ${item.title} is\n   ${item.length ?? "!!! NULL"} seconds");
      i++;
      if (i > 30) {
        print("\n\nThrottling and saving progress...\n\n");
        await Future.delayed(Duration(seconds: 5));
        i = 0;
        save();
      }

      if (item.length == null) {
        //! If length request failed
        print("##> Error while getting length!\n");
        errors.add(item);
      }
    }
  }

  save();

  print("Building rss feed");
  podcast.rssFile.createSync();
  podcast.rssFile.writeAsStringSync(getFeed(list, podcast.properties));

  print('Updating index page');
  File htmlFile = File("docs/index.html");
  String htmlString = """<h1>ScrapeCast</h1>
<b>Last update:</b> UTC ${DateTime.now().toIso8601String()}<br />
<b>Number of episodes:</b> ${list.length}<br />
<b>Last Added:</b><br />
<ul>
${newIts.fold("", (String previousValue, Istentisztelet element) => previousValue + "<li>${dateFormat.format(element.date)} | ${element.title} | ${element.pastor}</li>\n")}</ul>""";

  htmlFile.writeAsStringSync(htmlString);
  print('Done!');
  print(errors.isNotEmpty ? 'Errors:' : '');
  for (Istentisztelet item in errors) {
    print(
        "${item.uuid} | ${item.date} | ${item.title} | ${item.download} | ${item.length}");
  }
}
