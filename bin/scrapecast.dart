import 'dart:io';
import 'dart:convert';

import 'utils/feedbuilder.dart';
import 'utils/getlength.dart';
import 'utils/types.dart';
import 'podcasts.dart';

String statusMdString =
    "\n\nKészítette: [Fodor Benedek](https://github.com/redyau)\\\nKezelt Podcastek:\n\n---\n";

void main() async {
  for (Podcast podcast in podcasts) {
    await buildPodcast(podcast);
  }

  print('Updating index page');
  File mdFile = File("docs/index.md");
  mdFile.writeAsStringSync(statusMdString);
  print('Done!');
  exit(0); //Program just froze without this, weird
}

Future buildPodcast(Podcast podcast) async {
  print("\n\nBuilding ${podcast.properties.title}\n");

  List<Episode> episodes = [];
  List<Episode> errors = [];

  print('Loading existing data from json');
  if (!podcast.dataFile.existsSync()) {
    podcast.dataFile.createSync();
    podcast.dataFile.writeAsStringSync("[]");
  }
  List jsonEntries = jsonDecode(podcast.dataFile.readAsStringSync());
  for (Map entry in jsonEntries) {
    episodes.add(podcast.fromJson(entry));
  }

  List<Episode> newIts = (await podcast.scraper())
      .where((element) => (!episodes.contains(element)))
      .toList();
  episodes.insertAll(0, newIts);
  episodes.sort((a, b) => a.date.isBefore(b.date) ? 1 : -1);

  save() {
    print("Saving database");
    podcast.dataFile.createSync();
    podcast.dataFile.writeAsStringSync(JsonEncoder.withIndent('  ')
        .convert(episodes.map((e) => podcast.toJson(e)).toList()));
  }

  int i = 0;
  for (Episode item in episodes) {
    if (item.length == null || item.fileSize == null) {
      Uri downloadUri = Uri.parse(item.download);

      item.length ??= await getLength(
          (downloadUri.host.isEmpty ? podcast.properties.baseUrl : "") +
              item.download);
      item.fileSize ??= await getSize(
          (downloadUri.host.isEmpty ? podcast.properties.baseUrl : "") +
              item.download);
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

  episodes.removeWhere((element) => errors.contains(element));

  save();

  print("Building rss feed");
  podcast.rssFile.createSync();
  podcast.rssFile.writeAsStringSync(getFeed(episodes, podcast));

  print(errors.isNotEmpty ? 'Errors:' : '');
  for (Episode item in errors) {
    print(
        "${item.uuid} | ${item.date} | ${item.title} | ${item.download} | ${item.length}");
  }

  statusMdString +=
      """## [${podcast.properties.title}](${podcast.properties.link})
_${podcast.properties.description.replaceAll("\n", "\\\n")}_

✅ Legutóbb frissítve: ${getRfcDate(DateTime.now())}

Epizódok száma: ${episodes.length}

**Elérhető:**
""";
  for (String key in podcast.links.keys) {
    statusMdString += " - [$key](${podcast.links[key]})\n";
  }

  statusMdString += "\n**Legutóbbi epizódok:**\n";
  for (Episode episode in episodes.sublist(0, 6)) {
    statusMdString +=
        " - ${dateFormat.format(episode.date)} - ${episode.title} - ${episode.author}\n";
  }
  statusMdString += "\n---\n\n";
}
