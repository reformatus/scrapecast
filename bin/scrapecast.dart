import 'dart:io';
import 'dart:convert';
//import 'package:web_scraper/web_scraper.dart';

import 'utils/feedbuilder.dart';
import 'utils/getlength.dart';
import 'utils/types.dart';
import 'scrapers/krekscraper.dart';
import 'podcasts.dart';

String statusMdString = "Készítette: [Fodor Benedek](https://github.com/redyau)\n\nKezelt Podcastek:\n\n---\n";

void main() async {
  for (Podcast podcast in podcasts) {
    await buildPodcast(podcast);
  }

  print('Updating index page');
  File mdFile = File("docs/index.md");
  mdFile.writeAsStringSync(statusMdString);
  print('Done!');
}

Future buildPodcast(Podcast podcast) async {
  print("\n\nBuilding ${podcast.properties.title}\n");

  List<Episode> list = [];
  List<Episode> errors = [];

  print('Loading existing data from json');
  List jsonEntries = jsonDecode(podcast.dataFile.readAsStringSync());
  for (Map entry in jsonEntries) {
    list.add(Episode(
        dateFormat.parse(entry["date"]),
        entry["title"],
        entry["pastor"],
        entry["bible"],
        entry["youtube"],
        entry["download"],
        entry["uuid"],
        entry["length"],
        entry["size"]));
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

  List<Episode> newIts = (await krekScrape())
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
  for (Episode item in list) {
    if (item.length == null || item.fileSize == null) {
      item.length ??= await getLength(krekBase + item.download);
      item.fileSize ??= await getSize(krekBase + item.download);
      print(
          "Properties of ${item.date} | ${item.title} is\n   Length: ${item.length ?? "!!! NULL"} seconds\n   Size: ${item.fileSize ?? "!!! NULL"} bytes");
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

  print(errors.isNotEmpty ? 'Errors:' : '');
  for (Episode item in errors) {
    print(
        "${item.uuid} | ${item.date} | ${item.title} | ${item.download} | ${item.length}");
  }

  statusMdString +=
      """## [${podcast.properties.title}](${podcast.properties.link})
_${podcast.properties.description}_

✅ Legutóbb frissítve: ${DateTime.now().toIso8601String()} (UTC)

**Elérhető:**
""";
  for (String key in podcast.links.keys) {
    statusMdString += " - [$key](${podcast.links[key]})\n";
  }
  statusMdString += "**Legutóbbi epizódok:**\n";
  for (Episode episode in list.sublist(0, 6)) {
    statusMdString +=
        " - ${dateFormat.format(episode.date)} - ${episode.title} - ${episode.pastor}\n";
  }
  statusMdString += "\n---";
}
